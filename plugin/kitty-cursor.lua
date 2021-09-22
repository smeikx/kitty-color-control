-- TODO: make this customisable
local kitty_cmd = 'kitty @ --to=unix:@hellokitty'

function setCursor (hexColor)
	vim.fn.jobstart(string.format('%s set-colors cursor_text_color=\\#%s', kitty_cmd, hexColor))
end

function matchCursor ()
	local guifg =
		vim.api.nvim_exec('hi Cursor', true):match('guifg=#([a-f0-9]+)')
		or vim.api.nvim_exec('hi Normal', true):match('guibg=#([a-f0-9]+)')
	setCursor(guifg)
end

function restoreCursor ()
	vim.fn.jobstart(([[
		%s set-colors cursor_text_color='#'$( \
			%s get-colors -c \
			| sed -nE 's/.*cursor_text_color\s+#([a-f0-9]{6}).*/\1/p' \
		)
	]]):format(kitty_cmd, kitty_cmd), {detach = true})
end

local normal = {
	bg = '',
	fg = ''
}
function setNormal ()
	vim.fn.jobstart(string.format(
		'%s set-colors background=\\#%s foreground=\\#%s',
		kitty_cmd, normal.bg, normal.fg)
	)
end

function matchNormal ()
	local scheme_colors = vim.api.nvim_exec('hi Normal', true)
	normal.fg = scheme_colors:match('guifg=#([a-f0-9]+)')
	normal.bg = scheme_colors:match('guibg=#([a-f0-9]+)')
	vim.cmd('hi Normal NONE')
	setNormal()
end

function restoreNormal ()
end

function restore ()
	vim.fn.jobstart(([[
		%s get-colors -c \
		| grep -e 'cursor_text_color' -e '^background' -e '^foreground'
		| sed -nE 's/.+#([a-f0-9]{6}).*/\1/p' \
		| read bg cursor fg; %s set-colors cursor_text_color='#'$( \
		)
	]]):format(kitty_cmd, kitty_cmd), {detach = true})
end

_G.kcc = {
	--set = setCursor, -- uncomment if needed
	cursor = {
		match = matchCursor,
		restore = restoreCursor
	},
	normal = {
		match = matchNormal,
		restore = restoreNormal
	}
}

vim.cmd([[
	aug kitty_cursor
		au!
		au ColorScheme * call v:lua.kcc.match()
		au VimEnter,VimResume * call v:lua.kcc.match()
		au VimLeavePre,VimSuspend * call v:lua.kcc.restore()
	aug END
]])
