local address = vim.g.kitty_address
local kitty_cmd = string.format('kitty @%s', address and ' --to='..address or '')

-- It does not seem to matter if fd (file descriptor, the first argument) is either 0, 1 or 2.
local tty = vim.loop.new_tty(0, true)

-- OSC is an acronym of Operation System Command.
-- For further information about what is happening, see:
-- https://sw.kovidgoyal.net/kitty/faq/#how-do-i-change-the-colors-in-a-running-kitty-instance
local kitty_osc, scheme_osc

local osc_template = [[]10;%s\]11;%s\]12;%s\]]

do
	-- OSC for getting kitty’s current colors
	local osc = osc_template:format('?', '?', '?')
	function update_kitty_osc ()
		tty:write(osc, function (err)
			assert(not err, err)
			tty:read_start(function (err, data)
				assert(not err, err)

				-- data is expected to look like this (except ‘^[‘ is a real escape):
				-- ^[]10;rgb:efef/f0f0/ebeb^[\^[]11;rgb:2828/2a2a/3636^[\^[]12;rgb:f0f0/8e8e/4848^[\
				local foreground = data:sub(6, 23)
				local background = data:sub(31, 48)
				local cursor = data:sub(56, 73)
				kitty_osc = osc_template:format(foreground, background, cursor)

				-- XXX: According to the documentation, when reading with ‘stream:read_start()’:
				-- ‘the callback will be made several times until there is no more data to read or uv.read_stop() is called.‘
				-- (https://github.com/luvit/luv/blob/master/docs.md#uvread_startstream-callback)
				-- I do not know how ‘read_start’ decides how often it calls the callback and when to stop,
				-- but immediately calling read_stop() does the trick. ¯\_(ツ)_/¯
				tty:read_stop()
			end)
		end)
	end
end

function update_scheme_osc ()
	local normal_colors = vim.api.nvim_get_hl_by_name('Normal', true)
	-- TODO: Handle case when a hl is set to NONE, which results in nil.
	local foreground = string.format('#%06X', normal_colors.foreground)
	local background = string.format('#%06X', normal_colors.background)
	local cursor = string.format('#%06X', vim.api.nvim_get_hl_by_name('Cursor', true).foreground)
	scheme_osc = osc_template:format(foreground, background, cursor)
end

function match_colors ()
	vim.cmd('hi Normal NONE')
	tty:write(scheme_osc, function (err)
		assert(not err, err)
	end)
end

function restore_kitty_colors ()
	tty:write(kitty_osc, function (err)
		assert(not err, err)
	end)
end

function restore_scheme_colors ()
end


update_kitty_osc()
update_scheme_osc()
match_colors()

-- functions have to be added to the global environment to be callable in autocommands
_G.kcc = {
	on_scheme_update = function ()
		update_scheme_osc()
		match_colors()
	end,
	on_enter = function ()
		update_kitty_osc()
		match_colors()
	end,
	on_exit = restore_kitty_colors
}

vim.cmd([[
	aug kitty_cursor
		au!
		au ColorScheme * call v:lua.kcc.on_scheme_update()
		au VimEnter,VimResume * call v:lua.kcc.on_enter()
		au VimLeavePre,VimSuspend * call v:lua.kcc.on_exit()
	aug END
]])
