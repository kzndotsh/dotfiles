VERSION = "1.1.0"

local config = import("micro/config")
local util = import("micro/util")

function onBufferOpen(buf)
    local spaces, tabs = 0, 0
    local space_count, prev_space_count = 0, 0
    local tabsizes = {}
    local i = 0
    while spaces + tabs < 500 and i < 1000 and i < buf:LinesNum() do
        space_count = 0
        local line = buf:Line(i)
        local r = util.RuneAt(line, 0)
        if r == " " then
            space_count = string.len(util.GetLeadingWhitespace(line))
            -- for tab vs space detection, ignore space indents of 1
            --  which can be a false signal from C-style block comments
            if space_count > 1 then
                spaces = spaces + 1
            end

            -- treat whitespace-only lines as not changing the indent
            if string.len(line) == space_count then
                space_count = prev_space_count
            end
            -- look for an increasing number of spaces, ignoring increases of 1
            --  which can be a false signal from C-style block comments
            if space_count > prev_space_count + 1 then
                local t = space_count - prev_space_count
                if tabsizes[t] == nil then
                    tabsizes[t] = 1
                else
                    tabsizes[t] = tabsizes[t] + 1
                end
            end
        elseif r == "\t" then
            tabs = tabs + 1
            -- treat tabbed lines as not affecting spaced indentation
            space_count = prev_space_count
        elseif r == "" then
            -- treat empty lines as not changing the indent
            space_count = prev_space_count
        end
        prev_space_count = space_count
        i = i + 1
    end

    if spaces > tabs then
        buf.Settings["tabstospaces"] = true
        -- get the indentation change used for the largest number of lines
        local tabsize = -1
        local maxcount = 0
        for t, count in pairs(tabsizes) do
            if count > maxcount then
                maxcount = count
                tabsize = t
            end
        end
        if tabsize > 0 then
            buf.Settings["tabsize"] = tabsize
        end
    elseif tabs > spaces then
        buf.Settings["tabstospaces"] = false
    end
end

function init()
    config.AddRuntimeFile("detectindent", config.RTHelp, "help/detectindent.md")
end
