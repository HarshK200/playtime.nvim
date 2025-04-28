local utils = require("playtime.utils")

local window_ui = {}

function window_ui.window_data_is_valid(win_data)
    return vim.api.nvim_win_is_valid(win_data.win_id)
        and vim.api.nvim_buf_is_valid(win_data.buf_id)
end

-- this function checks if the current win_data i.e. win_id & buf_id is valid
-- if it is then returns the win_data as is
-- else creates one or the either which is required
function window_ui.handle_invalid_window_data(win_data, playtime, win_opts)
    -- return the previous win_data if it is valid
    if window_ui.window_data_is_valid(win_data) then
        return win_data
    end

    if not vim.api.nvim_win_is_valid(win_data.win_id) then
        -- if both window and buffer are invalid
        if not vim.api.nvim_buf_is_valid(win_data.buf_id) then
            win_data = window_ui.create_window(playtime, win_opts)
        else
            -- if the window is invalid but buffer is valid
            win_data.win_id = vim.api.nvim_open_win(win_data.buf_id, false, win_opts)
            -- for tranparency
            vim.api.nvim_win_set_option(win_data.win_id, "winblend", 70)

            local playtime_str = utils.format_time(playtime)
            utils.set_buffer_content(win_data.buf_id, playtime_str)
        end
    end

    -- if buffer is invalid then create new buffer and update the win_data table
    if not vim.api.nvim_buf_is_valid(win_data.buf_id) then
        win_data.buf_id = vim.api.nvim_create_buf(false, true)
    end
end

-- Returns the the window id of created window and
-- buffer id of created sratch buffer the window utilizes
function window_ui.create_window(inital_playtime, opts)
    -- creating the scratch buffer
    local buffer_id = vim.api.nvim_create_buf(false, true)

    -- creating the window
    local window_id = vim.api.nvim_open_win(buffer_id, false, opts)
    -- for tranparency
    vim.api.nvim_win_set_option(window_id, "winblend", 70)

    local playtime_str = utils.format_time(inital_playtime)
    utils.set_buffer_content(buffer_id, playtime_str)

    return { win_id = window_id, buf_id = buffer_id }
end

-- updates the playtime counter of the provided window id if valid.
-- NOTE: if playtime_data is not valid or nil throws an error
-- also if win_id is invalid it internally calls playtime.window_ui.create_window()
function window_ui.update_window_timer(win_data, playtime_data, win_opts)
    -- handle invalid window_data
    if not window_ui.window_data_is_valid(win_data) then
        window_ui.handle_invalid_window_data(
            win_data,
            playtime_data.projects[utils.cwd()],
            win_opts
        )
    end

    if not playtime_data.projects[utils.cwd()] then
        error(
            "\nError occured while updating window timer\nError: win_id or project playtime invalid",
            1
        )
    end

    local updated_playtime = playtime_data.projects[utils.cwd()] + 1
    playtime_data.projects[utils.cwd()] = updated_playtime
    local playtime_str = utils.format_time(updated_playtime)

    utils.set_buffer_content(win_data.buf_id, playtime_str)
end

function window_ui.handle_reposition_on_resize(
    win_data,
    win_opts,
    playtime_data,
    updated_position
)
    -- handle invalid window_data
    if not window_ui.window_data_is_valid(win_data) then
        window_ui.handle_invalid_window_data(
            win_data,
            playtime_data.projects[utils.cwd()],
            win_opts
        )
    end

    vim.api.nvim_win_set_config(win_data.win_id, {
        relative = "editor",
        row = updated_position.row,
        col = updated_position.col,
    })
end

return window_ui
