local utils = {}

-- Format seconds into hh:mm:ss
function utils.format_time(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- write/updates the content of a buffer with the provided content_str
function utils.set_buffer_content(buf_id, content_str)
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { content_str })
end

function utils.cwd()
    return vim.fn.getcwd()
end

return utils
