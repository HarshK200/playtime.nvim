local window_ui = require("playtime.window_ui")

local M = {}

local function handle_write(win_id, project_data)
    local cwd = vim.fn.getcwd()
    if not project_data.playtime or cwd ~= project_data.path then
        error(
            "Error occured in handle_write() \nError: either project_path or project_playtime variables are missing",
            1
        )
    end
end

function M.setup(opts)
    local playtime_group = vim.api.nvim_create_augroup("PLAYTIME_GROUP", { clear = true })

    -- TODO: read this from ~/.local/share/nvim/playtime.json
    local project_data = { path = "", playtime = 0 }

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
    local win_id, buf_id = window_ui.create_window(project_data.playtime, window_opts)

    -- Update clock every second
    vim.fn.timer_start(1000, function()
        vim.schedule(function()
            window_ui.update_window_counter(win_id, buf_id, project_data, window_opts)
        end)
    end, { ["repeat"] = -1 })

    -- On every save
    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
            pcall(handle_write, win_id, project_data)
        end,
        group = playtime_group,
    })

    -- Reposition window on resize
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            window_ui.handle_reposition_on_resize(
                win_id,
                { row = window_opts.row, col = window_opts.col }
            )
        end,
        group = playtime_group,
    })
end

return M
