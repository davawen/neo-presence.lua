local M = {}

--- @params opts? any Doesn't take any options
function M.setup(opts)
	local presence = require('neo-presence.presence')

	presence.start()

	vim.api.nvim_create_autocmd({ "VimLeave" }, {
		callback = function()
			presence.stop()
		end
	})

	-- TODO: expose user commands to start/stop/toggle presence
	-- TODO: implement idling
end

return M
