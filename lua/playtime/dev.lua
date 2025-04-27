-- file only for development stuff don't include in the main file

local M = {}

function M.reload()
	require("plenary.reload").reload_module("playtime")
end

local log_levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local function get_log_level()
	local log_level = vim.env.PLAYTIME_LOG or vim.g.playtime_log_level

	for _, level in pairs(log_levels) do
		if level == log_level then
			return log_level
		end
	end

	return "warn" -- if not specified by user default log level is warn
end

local log_level = get_log_level()

-- exporting custom logger
M.log = require("plenary.log").new({
	plugin = "playtime",
	level = log_level,
})

local log_key = os.time()

return M
