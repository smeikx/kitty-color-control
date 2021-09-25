# Kitt Color Control

This simple plugin is made for usage in Neovim’s TUI inside kitty, it does two things:

- set the cursor’s foreground color according to the active color scheme
- increase efficiency by setting the window’s background and foreground colors to the ones of the `Normal` highlight group, and setting the group’s colors to `NONE`

## Prerequesites

You have to enable [remote control](https://sw.kovidgoyal.net/kitty/remote-control/). Optionally, also specify an address, if you [have configured one](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-listen-on), just set `kitty_address` in your init file, like this:

	let g:kitty_address = 'unix:/tmp/hellokitty'

Or with lua:

	vim.g.kitty_address = 'unix:/tmp/hellokitty'


## Quirks & Flaws

As this plugin is a scratch to my personal itch, it does not cover all possible scenarios.

- This plugin depends on a POSIX compliant shell, `grep`, `sed` and `tr`.
- When extracting colors from a set highlight only `guibg` and `guifg` are considered.
- When the `Cursor`’s `guifg` is not a hex color, `Normal`’s `guibg` is used.
- There is more inline shell script than I like.

If you have an idea and the skills to improve this thing, you are more than welcome to do so.
