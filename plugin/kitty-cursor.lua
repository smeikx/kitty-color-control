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

local options = {
	on_stdout =
		function (_, colors, _)
			local cursor_color = table.concat(colors, ' '):match('cursor_text_color%s+#([a-f0-9]+)')
			if cursor_color then
				set(cursor_color)
			end
		end,
	stdout_buffered = true,
	detach = true
}
function restore ()
	-- XXX: This does not work when nvim is closed, as the callback will never be executed.
	-- TODO: Maybe do it with shell script only.
	vim.fn.jobstart(kitty_cmd..' get-colors -c', options)
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
