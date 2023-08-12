# Quickfix plugin for micro editor

Quickfix is a plugin to speedup edit-make-edit development cycle.
It is similar to quickfix window in VIM editor.

You can execute an external command, examine the output in qfix pane
and toggle between list of positions and file locations.

qfix pane supports incremental search and jumps to the first match as you type.
Use backtick to cancel the search.

Plugin added to the micro plugin channel:
https://github.com/micro-editor/plugin-channel

## Installation

In micro editor press Ctrl+E and run command:

	plugin install quickfix

## Commands

### fexec [args]

If args list is empty fexec executes the current line.
Otherwise fexec replaces argument placeholders and executes the arguments.

Placeholders:

	{w} -- current word
	{s} -- current selection
	{o} -- byte offset
	{f} -- current file
    {l} -- current line
    {c} -- current position

Binding examples:

Run make:

	"F8": "command:fexec make"

Grep for word under cursor:

	"F7": "command:fexec grep -n {w} *.go"

Show go doc for selected pkgname.Entity:

	"F8": "command:fexec go doc {s}"

List all declarations in go file:

	"Alt-t": "command:fexec motion -file {f} -mode decls -include func -format text",

### fjump

**Set parsecursor=true in config to enable jumping to the file location.**

Jumps to the file under cursor and back.
