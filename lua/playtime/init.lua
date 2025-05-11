local window_ui = require("playtime.window_ui")
local utils = require("playtime.utils")
local data = require("playtime.data")

local M = {}

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

    -- NOTE: this is a refrence to the playtime_data_cache
    local playtime_data = data.get_playtime_data()

    -- default config for Playtime plugin
    local default_opts = {
        window = {
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
        },
        win_visible_on_startup = true, -- should the window be visible by default
    }
    local config_opts = opts and opts or default_opts
    local win_data =
        window_ui.create_window(playtime_data.projects[utils.cwd()], config_opts)
    win_data.win_is_visible = config_opts.win_visible_on_startup

    -- Update clock every second and draws the window if it doesn't exit
    vim.fn.timer_start(1000, function()
        vim.schedule(function()
            window_ui.update_window_timer(win_data, playtime_data, config_opts.window)
        end)
    end, { ["repeat"] = -1 })

    -- On every buffer write save the data to json file
    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
            data.save_playtime_data_to_file()
        end,
        group = playtime_group,
    })

    -- Reposition window on resize
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            window_ui.handle_reposition_on_resize(
                win_data,
                config_opts.window,
                playtime_data,
                { row = config_opts.window.row, col = config_opts.window.col }
            )
        end,
        group = playtime_group,
    })

    ------------------- USER COMMANDS -------------------
    vim.api.nvim_create_user_command("PlaytimeToggle", function(args)
        if win_data.win_is_visible then
            vim.api.nvim_win_hide(win_data.win_id)
            win_data.win_id = -1
            win_data.win_is_visible = false
        else
            win_data.win_is_visible = true
            window_ui.handle_invalid_window_data(
                win_data,
                playtime_data.projects[utils.cwd()],
                config_opts.window
            )
        end
    end, {})
end

return M
