local address = vim.g.kitty_address
local kitty_cmd = string.format('kitty @%s', address and ' --to='..address or '')

local cache = {
	background = '',
	foreground = '',
	cursor = ''
}

-- set kitty’s colors to the cached values
function set ()
	vim.fn.jobstart(string.format(
		"%s set-colors cursor_text_color='%s' background='%s' foreground='%s'",
		kitty_cmd, cache.cursor, cache.background, cache.foreground)
	)
end

-- determine and cache color values as defined in the scheme
function match ()
	local normal_colors = vim.api.nvim_get_hl_by_name('Normal', true)
	cache.background = string.format('#%06X', normal_colors.background)
	cache.foreground = string.format('#%06X', normal_colors.foreground)

	cache.cursor = string.format('#%06X', vim.api.nvim_get_hl_by_name('Cursor', true).foreground)

	vim.cmd('hi Normal NONE')
	set()
end

-- restore kitty’s colors
function restore ()
	-- TODO Try assimilating `tr | sed` into the first `sed`:
	-- https://stackoverflow.com/a/1252191
	-- TODO Maybe cache this (the string and/or the result).
	vim.fn.jobstart(([[
		%s get-colors -c \
		| grep -e 'cursor_t' -e '^back' -e '^fore' \
		| sed -nE 's/.+#([a-f0-9]{6}).*/\1/p' \
		| tr '\n' ' ' | sed 's/ $/\n/' \
		| { read c b f; %s set-colors cursor_text_color='#'$c background='#'$b foreground='#'$f; }
	]]):format(kitty_cmd, kitty_cmd), {detach=true})
end

-- call once, as the color scheme is usually loaded before this
match()

-- the above functions have to be added to the global environment to be callable in autocommands
_G.kcc = {
	set = set,
	match = match,
	restore = restore
}

vim.cmd([[
	aug kitty_cursor
		au!
		au ColorScheme * call v:lua.kcc.match()
		au VimEnter,VimResume * call v:lua.kcc.set()
		au VimLeavePre,VimSuspend * call v:lua.kcc.restore()
	aug END
]])
