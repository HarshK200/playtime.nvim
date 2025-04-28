local utils = require("playtime.utils")

local W = {}

-- Returns the the window id of created window and buffer id of created sratch buffer the window utilizes
-- NOTE: a scratch buffer is just a temp buffer for where we draw our timer
function W.create_window(inital_playtime, opts)
    -- creating the scratch buffer
    local buf_id = vim.api.nvim_create_buf(false, true)

    -- creating the window
    local win_id = vim.api.nvim_open_win(buf_id, false, opts)
    -- for tranparency
    vim.api.nvim_win_set_option(win_id, "winblend", 70)

    local playtime_str = utils.format_time(inital_playtime)
    utils.set_buffer_content(buf_id, playtime_str)

    return win_id, buf_id
end

-- updates the playtime counter of the provided window id if valid.
-- NOTE: if window id or project_data is not valid or nil throws an error
function W.update_window_counter(win_id, buf_id, project_data, win_opts)
    -- if window_doesn't exist just create it
    if not win_id or not vim.api.nvim_win_is_valid(win_id) then
        W.create_window(project_data.playtime, win_opts)
    end
    if not project_data.playtime then
        error(
            "\nError occured while updating window counter\nError: win_id or project playtime invalid",
            1
        )
    end

    local updated_playtime = project_data.playtime + 1
    project_data.playtime = updated_playtime
    local playtime_str = utils.format_time(updated_playtime)

    utils.set_buffer_content(buf_id, playtime_str)
end

function W.handle_reposition_on_resize(win_id, updated_position)
    if not win_id then
        error("Invalid window id", 1)
    end

    vim.api.nvim_win_set_config(win_id, {
        relative = "editor",
        row = updated_position.row,
        col = updated_position.col,
    })
end

return W
