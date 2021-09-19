-- TODO: make this customisable
local kitty_cmd = 'kitty @ --to=unix:@hellokitty'

function set (hexColor)
	vim.fn.jobstart(string.format('%s set-colors cursor_text_color=\\#%s', kitty_cmd, hexColor))
end

function match ()
	local guifg =
		vim.api.nvim_exec('hi Cursor', true):match('guifg=#([a-f0-9]+)')
		or vim.api.nvim_exec('hi Normal', true):match('guibg=#([a-f0-9]+)')
	set(guifg)
end

function restore ()
	vim.fn.jobstart(([[
		%s set-colors cursor_text_color='#'$( \
			%s get-colors -c \
			| sed -nE 's/.*cursor_text_color\s+#([a-f0-9]{6}).*/\1/p' \
		)
	]]):format(kitty_cmd, kitty_cmd), {detach = true})
end

_G.kittyCursorColor = {
	--set = set, -- uncomment if needed
	match = match,
	restore = restore
}

vim.cmd([[
	aug kitty_cursor
		au!
		au ColorScheme * call v:lua.kittyCursorColor.match()
		au VimEnter,VimResume * call v:lua.kittyCursorColor.match()
		au VimLeavePre,VimSuspend * call v:lua.kittyCursorColor.restore()
	aug END
]])
