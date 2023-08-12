# Quickfix plugin

Executes external command and shows the command output in qfix pane.
qfix pane allows to jump to the file location. 

qfix pane has incremental search as you type. Use backtick to reset the search.

Commands:

fexec [args]

    If args is not empty executes the arguments.
    Otherwise executes the current line.

Placeholders:

    {w} -- current word
    {s} -- current selection
    {o} -- byte offset
    {f} -- current file
    {l} -- current line
    {c} -- current position

fjump

    Jumps between qfix pane and file locations.

## Example bindings

Jump to the file and back to qfix pane:

	"F3": "command:fjump"

Exec current line:

	"F9": "command:fexec"

Grep for word under cursor:

	"Alt-i": "command:fexec grep {w} *.go"
