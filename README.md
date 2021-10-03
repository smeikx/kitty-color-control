# Kitty Color Control

This simple plugin is made for usage in neovim’s TUI inside kitty; it does two things:

- set the cursor’s foreground color according to neovim’s active color scheme
- increase efficiency by setting the window’s background and foreground colors to the ones of the `Normal` highlight group, and setting the group’s colors to `NONE`


## Prerequisites

You have to enable [remote control](https://sw.kovidgoyal.net/kitty/remote-control/). Optionally, also specify an address, if you [have configured one](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-listen-on), just set `kitty_address` in your init file, like this:

```vim
let g:kitty_address = 'unix:/tmp/hellokitty-$KITTY_PID'
```

Or with lua:

```lua
vim.g.kitty_address = 'unix:/tmp/hellokitty-$KITTY_PID'
```

Also, make sure to set `guicursor`, as [demonstrated in neovim’s FAQ](https://github.com/neovim/neovim/wiki/FAQ#how-to-change-cursor-color-in-the-terminal).


## Quirks & Room for Improvement

As this plugin is a scratch to my personal itch, it does not cover all possible scenarios. In its current state it is just _good enough_.

- This plugin depends on a POSIX compliant shell, `grep`, `sed` and `tr`.
- When extracting colors from a set highlight group only `guibg` and `guifg` are considered.
- The whole plugin is one single file. Maybe it should be more? (I don’t know about nvim plugin best practices).
- There is more inline shell script than I like.
- As it needs seven external commands and a subshell, all connected by pipe, to restore colors when leaving nvim, there is a noticable delay.
- This is bearly tested (so far only on Linux, might try macOS later).

If you have an idea for improvemnt please create an issue to discuss it. If you also have the skills to do the improving yourself you are more than welcome to do so by creating a pull request.
