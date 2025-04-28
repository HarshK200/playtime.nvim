local Path = require("plenary.path")

local data = {}
local project_data_cache

-- reads the file from the specified path
-- If the file is not found throws an error
function data.read_json_file(file_path)
    return vim.json.decode(Path:new(file_path):read())
end

function data.write_table_as_json(file_path, table)
    Path:new(file_path):write(vim.json.encode(table))
end

-- returns the project_data.
-- NOTE: this function caches the project data to local variable after first call
-- if you want to read project data from file use data.read_json_file() instead
function data.get_project_data()
    if project_data_cache then
        return project_data_cache
    end

    local nvim_data_path = vim.fn.stdpath("data")
    local playtime_data_file_path = string.format("%s/playtime_data.json", nvim_data_path)

    local ok, project_data_cache = pcall(data.read_json_file, playtime_data_file_path)
    if not ok then
        print("no local cache file found")
    end
end

return data
