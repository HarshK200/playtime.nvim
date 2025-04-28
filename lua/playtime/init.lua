local window_ui = require("playtime.window_ui")
local utils = require("playtime.utils")
local data = require("playtime.data")

local M = {}

local function handle_write()
    data.save_playtime_data_to_file()
end

function M.setup(opts)
    local playtime_group = vim.api.nvim_create_augroup("PLAYTIME_GROUP", { clear = true })

    -- IMPORTANT: Structure of the json file that will store playtime_user_data
    -- Time is stored in seconds
    -- local playtime_data = {
    --     projects = {
    --             { "/home/harsh/Desktop/jae-commerce/"= 2340123 },
    --             { "/home/harsh/Desktop/wallmart-excalidraw/"= 120 },
    --     },
    -- }
    local playtime_data = data.get_playtime_data()

    -- window config options
    local default_opts = {
        relative = "editor",
        width = 8,
        height = 1,
        row = 0,
        col = vim.o.columns,
        style = "minimal",
        focusable = false,
        noautocmd = true,
        border = "rounded",
        anchor = "NW", -- which cornor to play at row, col
        zindex = 150,
    }
    local window_opts = opts and opts or default_opts
    local win_data =
        window_ui.create_window(playtime_data.projects[utils.cwd()], window_opts)

    -- Update clock every second
    vim.fn.timer_start(1000, function()
        vim.schedule(function()
            window_ui.update_window_timer(win_data, playtime_data, window_opts)
        end)
    end, { ["repeat"] = -1 })

    -- On every save
    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = handle_write,
        group = playtime_group,
    })

    -- Reposition window on resize
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            window_ui.handle_reposition_on_resize(
                win_data,
                window_opts,
                playtime_data,
                { row = window_opts.row, col = window_opts.col }
            )
        end,
        group = playtime_group,
    })
end

return M
