local M = {}

function M.setup(_)
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
