-- local log = Dev.log

local M = {}

-- TODO: read start_time from a file
local start_time = nil
local project_path = nil
local buf = nil
local win = nil

-- Format seconds into hh:mm:ss
local function format_time(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function create_window()
	buf = vim.api.nvim_create_buf(false, true)

	local width = 10
	local height = 1
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = 0,
		col = vim.o.columns - width,
		style = "minimal",
		focusable = false,
		noautocmd = true,
	}

	win = vim.api.nvim_open_win(buf, false, opts)
	vim.api.nvim_win_set_option(win, "winblend", 20) -- for transparency
end

local function update_clock()
	if not start_time then
		return
	end

	-- if the window doesn't exists create it
	if not win or not buf or not vim.api.nvim_win_is_valid(win) then
		create_window()
	end

	local time_elapsed = os.time() - start_time
	local time_str = format_time(time_elapsed)

	if not buf then
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { time_str })
end

-- Display the clock
-- local function display_clock()
-- 	if not start_time then
-- 		return
-- 	end
-- 	local elapsed = os.time() - start_time -- time in seconds
-- 	local time_str = format_time(elapsed)
--
-- 	vim.api.nvim_echo({ { time_str, "Normal" } }, false, {})
-- end

-- Handle write
local function on_write()
	-- TODO: if not start_time read it from file (if exists)
	-- else set the start_time as os.time() i.e. now and write to file

	local cwd = vim.fn.getcwd()
	if not start_time or cwd ~= project_path then
		start_time = os.time()
		project_path = cwd
	end
end

function M.setup()
	-- On every save
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = on_write,
	})

	-- Update clock every second
	vim.fn.timer_start(1000, function()
		vim.schedule(update_clock)
	end, { ["repeat"] = -1 })
end

M.setup()

return M
