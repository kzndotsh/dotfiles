"""Patch kiro-gateway source for Cursor compatibility."""
import re
import pathlib
import sys

out = sys.argv[1]

# 1. Patch MODEL_ALIASES in config.py
cfg = pathlib.Path(f'{out}/kiro/config.py')
text = cfg.read_text()

aliases = '''MODEL_ALIASES: Dict[str, str] = {
    "auto-kiro": "claude-sonnet-4.6-1m",
    "auto": "claude-sonnet-4.6-1m",
    "gpt-4": "claude-sonnet-4.6-1m",
    "gpt-4o": "claude-sonnet-4.6-1m",
    "gpt-4o-mini": "claude-sonnet-4.5",
    "gpt-4-turbo": "claude-sonnet-4.6-1m",
    "gpt-3.5-turbo": "claude-haiku-4.5",
    "o1": "claude-sonnet-4.6-1m",
    "o1-mini": "claude-sonnet-4.5",
    "o1-preview": "claude-sonnet-4.6-1m",
    "o3": "claude-sonnet-4.6-1m",
    "o3-mini": "claude-sonnet-4.5",
    "cursor-small": "claude-haiku-4.5",
    "cursor-fast": "claude-sonnet-4.5",
    "claude-3-opus": "claude-sonnet-4.6-1m",
    "claude-3.5-sonnet": "claude-sonnet-4.5",
    "claude-3-haiku": "claude-haiku-4.5",
    "claude-3-5-sonnet-20241022": "claude-sonnet-4.5",
    "claude-3-5-haiku-20241022": "claude-haiku-4.5",
}'''

pattern = r'MODEL_ALIASES: Dict\[str, str\] = \{[^}]+\}'
text = re.sub(pattern, aliases, text)
cfg.write_text(text)

# 2. Patch get_model_id_for_kiro to resolve aliases
mr = pathlib.Path(f'{out}/kiro/model_resolver.py')
text = mr.read_text()

# Replace the function body
old = '    normalized = normalize_model_name(model_name)\n    internal = hidden_models.get(normalized, normalized)\n    return to_runtime_model_id(internal)'
new = '    from kiro.config import MODEL_ALIASES\n    resolved = MODEL_ALIASES.get(model_name, model_name)\n    normalized = normalize_model_name(resolved)\n    internal = hidden_models.get(normalized, normalized)\n    return to_runtime_model_id(internal)'

text = text.replace(old, new, 1)
mr.write_text(text)

# 3. Patch converters_core.py to flatten nested objects/arrays in tool schemas
#    Kiro API rejects nested object properties and arrays of objects.
#    Flatten them to JSON strings so the model can still use them.
cc = pathlib.Path(f'{out}/kiro/converters_core.py')
text = cc.read_text()

# Add a schema flattening helper after imports
flatten_helper = '''

def _flatten_tool_schema(schema: dict) -> dict:
    """Flatten nested objects and arrays-of-objects to string type for Kiro API compatibility."""
    if not isinstance(schema, dict) or "properties" not in schema:
        return schema
    import json as _json
    ALLOWED_PROP_KEYS = {"type", "description", "enum", "items", "required"}
    props = schema.get("properties", {})
    new_props = {}
    for name, prop in props.items():
        ptype = prop.get("type")
        if ptype == "object" and "properties" in prop:
            nested_desc = prop.get("description", "")
            shape = _json.dumps({k: v.get("type", "any") for k, v in prop.get("properties", {}).items()})
            new_props[name] = {
                "type": "string",
                "description": f"{nested_desc} (JSON object with shape: {shape})"
            }
        elif ptype == "object" and "properties" not in prop:
            bare_desc = prop.get("description", "")
            new_props[name] = {
                "type": "string",
                "description": f"{bare_desc} (JSON object as string)"
            }
        elif ptype == "array" and isinstance(prop.get("items"), dict) and prop["items"].get("type") == "object":
            arr_desc = prop.get("description", "")
            item_props = prop["items"].get("properties", {})
            shape = _json.dumps({k: v.get("type", "any") for k, v in item_props.items()})
            new_props[name] = {
                "type": "string",
                "description": f"{arr_desc} (JSON array of objects with shape: {shape})"
            }
        else:
            cleaned = {k: v for k, v in prop.items() if k in ALLOWED_PROP_KEYS}
            if not cleaned.get("type"):
                cleaned["type"] = "string"
            new_props[name] = cleaned
    return {"type": "object", "properties": new_props, "required": schema.get("required", [])}


'''

# Insert after the first import block
# Find a good insertion point - after the logger line
insert_marker = 'logger = logger_module.getLogger(__name__)'
if insert_marker not in text:
    insert_marker = 'from loguru import logger'
text = text.replace(insert_marker, insert_marker + flatten_helper, 1)

# Now patch convert_tools_to_kiro_format to call the flattener
old_schema = '        sanitized_params = sanitize_json_schema(tool.input_schema)'
new_schema = '        sanitized_params = _flatten_tool_schema(sanitize_json_schema(tool.input_schema))'
text = text.replace(old_schema, new_schema)

cc.write_text(text)

print("Patched MODEL_ALIASES, get_model_id_for_kiro, and tool schema flattening")

# 4. Patch converters_core.py to sanitize toolUseId (Cursor sends newlines in IDs)
text = cc.read_text()
# Replace all toolUseId assignments to strip newlines
text = text.replace(
    '"toolUseId": tr.get("tool_use_id", "")',
    '"toolUseId": tr.get("tool_use_id", "").replace("\\n", "_")'
)
text = text.replace(
    '"toolUseId": item.get("tool_use_id", "")',
    '"toolUseId": item.get("tool_use_id", "").replace("\\n", "_")'
)
text = text.replace(
    '"toolUseId": tc.get("id", "")',
    '"toolUseId": tc.get("id", "").replace("\\n", "_")'
)
text = text.replace(
    '"toolUseId": item.get("id", "")',
    '"toolUseId": item.get("id", "").replace("\\n", "_")'
)
cc.write_text(text)

print("Also patched toolUseId sanitization")
