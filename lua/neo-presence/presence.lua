local M = {}

local available_filetypes = require('neo-presence.available_filetypes')

local ffi = require('ffi')

local function read_file(path)
	local f = assert(io.open(path, "r"))
	local s = f:read("*a")
	f:close()
	return s
end

local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end
local top_directory = script_path() .. "../../"

-- load discord headers for struct and enum definitions
local header = read_file(top_directory .. "discord_game_sdk_processed.h")
ffi.cdef(header)

ffi.cdef [[
	enum EDiscordResult init();
	enum EDiscordResult run_callbacks();
	void quit();

	typedef void (*lua_callback_t)(enum EDiscordResult result);
	void set_activity(struct DiscordActivity *activity, lua_callback_t lua_callback);
]]

local presence = ffi.load(top_directory .. "libpresence.so")
local activity = ffi.new("struct DiscordActivity[1]")

local update_activity_callback = ffi.new("lua_callback_t", function (result)
	if result ~= "DiscordResult_Ok" then
		error("neo-presence.lua: failed to set activity, got: " .. tostring(result), vim.log.levels.ERROR)
	end
end)

--- @type uv_timer_t|nil
--- if callback timer is set to nil, the library is unloaded
local callback_timer = nil

local function callback_loop()
	local result = presence.run_callbacks()
	if result ~= "DiscordResult_Ok" then
		error(
			"neo-presence.lua: failed to run discord callbacks, got: " .. tostring(result),
			vim.log.levels.ERROR
		)
	end

	callback_timer = vim.defer_fn(callback_loop, 1000)
end

local function set_buffer_state()
	if not callback_timer then
		return
	end

	local bufname = vim.api.nvim_buf_get_name(0)

	local filename = vim.fn.fnamemodify(bufname, ':t')
	local extension = vim.fn.fnamemodify(bufname, ':e')

	if vim.bo.buftype == "terminal" then
		activity[0].state = "In terminal"
		activity[0].assets.small_image = "terminal"
		activity[0].assets.small_text = filename
	elseif vim.bo.buftype == "help" then
		activity[0].state = "Reading help pages"
		activity[0].assets.small_image = "txt"
		activity[0].assets.small_text = filename
	elseif vim.bo.buftype == "" then
		if filename == "" then
			activity[0].state = "Editing an unnamed buffer"
		else
			activity[0].state = "Editing " .. filename
		end

		local icon_text = "txt"

		-- Replace non-alphanumeric characters by underscores ( c++ -> c__ )
		if extension and available_filetypes[extension] == true then
			icon_text = extension
		elseif available_filetypes[vim.bo.filetype] == true then
			icon_text = vim.bo.filetype
		end

		local icon = icon_text:gsub("[^%w%s]", "_")
		activity[0].assets.small_image = icon
		activity[0].assets.small_text = icon_text
	end
	presence.set_activity(activity, update_activity_callback)
end

local function set_project_state()
	if not callback_timer then
		return
	end

	local dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
	activity[0].details = "In: " .. dir

	presence.set_activity(activity, update_activity_callback)
end

local function create_autocommands()
	local autocmd = vim.api.nvim_create_autocmd
	autocmd({ "BufEnter" }, { callback = set_buffer_state })
	autocmd({ "DirChanged" }, { callback = set_project_state })
end

function M.start()
	local result = presence.init()
	if result == "DiscordResult_InternalError" then
		print("neo-presence.lua: discord isn't launched")
		return
	elseif result ~= "DiscordResult_Ok" then
		error("neo-presence.lua: failed to start: " .. tostring(result), vim.log.levels.WARN)
		return
	end

	activity[0] = {
		type = "DiscordActivityType_Playing",
		name = "Neovim",
		status = "",
		details = "",
		timestamps = {
			start = os.time(),
			["end"] = 0
		},
		assets = {
			large_image = "neovim",
			large_text = "Hyperextensible Vim-based text editor"
		},
		instance = false
	}

	callback_loop()

	create_autocommands()
	set_buffer_state()
	set_project_state()
end

function M.stop()
	-- TODO: Clear autocommands

	if callback_timer then
		callback_timer:close()
		callback_timer = nil
	end

	presence.quit()
end

return M
