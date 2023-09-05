local M = {}

--- @class NeoPresenceOptions
local defaults = {
	autostart = true, -- automatically load plugin on setup, otherwise call `require('neo-presence.presence').start` or `:Neopresence`
	autostop = true -- automatically create an autocommand on "VimLeave" to quit plugin, otherwise call `require('neo-presence.presence).stop` or `NeopresenceQuit`
}

--- @param opts? NeoPresenceOptions
function M.setup(opts)
	--- @type NeoPresenceOptions
	local options = vim.tbl_deep_extend("force", {}, defaults, opts or {})

	local presence = require('neo-presence.presence')

	if options.autostart then
		presence.start()
	end

	if options.autostop then
		vim.api.nvim_create_autocmd({ "VimLeave" }, {
			callback = function()
				presence.stop()
			end
		})
	end

	vim.api.nvim_create_user_command("Neopresence", function ()
		presence.start()
	end)

	vim.api.nvim_create_user_command("NeopresenceQuit", function ()
		presence.stop()
	end)

	-- TODO: implement idling
end

return M
