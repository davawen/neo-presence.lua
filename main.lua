local ffi = require('ffi')

local function read_file(path)
	local f = assert(io.open(path, "r"))
	local s = f:read("*a")
	f:close()
	return s
end

-- load discord headers for struct and enum definitions
local header = read_file("./discord_game_sdk_processed.h")
ffi.cdef(header)

ffi.cdef [[ void printf(const char *fmt, ...); ]]
ffi.cdef [[
	void init();
	void set_activity(struct DiscordActivity *activity);
	void run_callbacks();
	void quit();
]]

local presence = ffi.load("./libpresence.so")

presence.init()

local activity = ffi.new("struct DiscordActivity[1]")
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
		large_text = "Hyperextensible Vim-based text editor",
		small_image = "lua",
		small_text = "Editing a lua file"
	},
	instance = false
}

local n = 0

while true do
	activity[0].details = "smol" .. tostring(n)
	activity[0].state = tostring(n)
	n = n + 1

	presence.set_activity(activity)
	presence.run_callbacks()

	if os.execute("sleep 1") ~= true then break end -- sleep captures ^C
end

presence.quit()
