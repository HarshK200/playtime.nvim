local utils = require("playtime.utils")

local M = {}

-- TODO: read start_time from a file
local start_time = nil
local project_path = nil
local buf_id = nil
local win_id = nil

local function create_window()
	buf_id = vim.api.nvim_create_buf(false, true)

	local opts = {
		relative = "editor",
		width = 10,
		height = 1,
		row = 0,
		col = vim.o.columns,
		style = "minimal",
		focusable = false,
		noautocmd = true,
		border = "rounded",
	}

	win_id = vim.api.nvim_open_win(buf_id, false, opts)
	vim.api.nvim_win_set_option(win_id, "winblend", 20) -- for transparency
end

local function update_clock()
	if not start_time then
		return
	end

	-- if the window doesn't exists create it
	if not win_id or not buf_id or not vim.api.nvim_win_is_valid(win_id) then
		create_window()
	end

	local time_elapsed = os.time() - start_time
	local time_str = utils.format_time(time_elapsed)

	if not buf_id then
		return
	end

	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { time_str })
end

local function handle_float_location_on_resize()
	if not win_id then
		create_window()
		return
	end

	vim.api.nvim_win_set_config(win_id, {
		relative = "editor",
		row = 0,
		col = vim.o.columns,
	})
end

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
	local playtime_group = vim.api.nvim_create_augroup("PLAYTIME_GROUP", { clear = true })
	-- On every save
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = on_write,
		group = playtime_group,
	})

	-- recalculates the clocks position after window resize
	vim.api.nvim_create_autocmd("VimResized", {
		callback = handle_float_location_on_resize,
		group = playtime_group,
	})

	-- Update clock every second
	vim.fn.timer_start(1000, function()
		vim.schedule(update_clock)
	end, { ["repeat"] = -1 })
end

return M
