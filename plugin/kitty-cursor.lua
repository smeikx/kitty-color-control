-- TODO: make this customisable
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
	local normalColors = vim.api.nvim_exec('hi Normal', true)
	cache.background = normalColors:match('guibg=(#[a-f0-9]+)')
	cache.foreground = normalColors:match('guifg=(#[a-f0-9]+)')

	-- if it is not a color value, it is probably ‘bg’
	cache.cursor =
		vim.api.nvim_exec('hi Cursor', true):match('guifg=(#[a-f0-9]+)')
		or cache.background

	vim.cmd('hi Normal NONE')
	set()
end

-- restore kitty’s colors
function restore ()
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

-- they have to be part of the global environment to be callable in autocommands
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
