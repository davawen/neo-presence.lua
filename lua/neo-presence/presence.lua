local M = {}

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

ffi.cdef [[ void printf(const char *fmt, ...); ]]
ffi.cdef [[
	void init();
	void set_activity(struct DiscordActivity *activity);
	void run_callbacks();
	void clear();
]]

local presence = ffi.load(top_directory .. "libpresence.so")
local activity = ffi.new("struct DiscordActivity[1]")

local available_filetypes = require('neo-presence.available_filetypes')

local function set_buffer_state()
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
		activity[0].state = "Editing " .. filename

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
	presence.set_activity(activity)
end

local function set_project_state()
	local dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
	activity[0].details = "In: " .. dir

	presence.set_activity(activity)
end

local function create_autocommands()
	local autocmd = vim.api.nvim_create_autocmd
	autocmd({ "BufEnter" }, { callback = set_buffer_state })
	autocmd({ "DirChanged" }, { callback = set_project_state })
end

local callback_timer = nil
local function run_callback()
	presence.run_callbacks()

	callback_timer = vim.defer_fn(run_callback, 1000)
end

function M.start()
	presence.init()

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

	create_autocommands()
	set_buffer_state()
	set_project_state()

	run_callback()
end

function M.stop()
	-- TODO: Clear autocommands

	if callback_timer then
		callback_timer:close()
		callback_timer = nil
	end

	presence.clear()
	presence.run_callbacks()
end

return M
