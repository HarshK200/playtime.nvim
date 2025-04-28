local Path = require("plenary.path")
local utils = require("playtime.utils")

local data = {}
local playtime_data_cache
local nvim_data_path = vim.fn.stdpath("data")
local playtime_data_file_path = string.format("%s/playtime_data.json", nvim_data_path)

-- reads the file from the specified path
-- If the file is not found throws an error
function data.read_json_file(file_path)
    return vim.json.decode(Path:new(file_path):read())
end

function data.write_table_as_json(file_path, table)
    Path:new(file_path):write(vim.json.encode(table))
end

-- returns the playtime_data.
-- NOTE: this function caches the project data to local variable after first call
-- if you want to read project data from file use data.read_json_file() instead
function data.get_playtime_data()
    if playtime_data_cache then
        return playtime_data_cache
    end

    local ok, playtime_data = pcall(data.read_json_file, playtime_data_file_path)
    -- if the playtime_data.json file doesn't exists
    if not ok then
        playtime_data_cache = {
            projects = {},
        }
    else
        assert(
            type(playtime_data) == "table",
            "Error in get_playtime_data() read invalid playtime data from json file"
        )
        playtime_data_cache = playtime_data
    end

    if playtime_data_cache.projects[utils.cwd()] == nil then
        playtime_data_cache.projects[utils.cwd()] = 0
    end

    return playtime_data_cache
end

function data.save_playtime_data_to_file()
    if not playtime_data_cache or type(playtime_data_cache) ~= "table" then
        error("Cannot write invalid playtime data to json", 1)
    end

    Path:new(playtime_data_file_path):write(vim.json.encode(playtime_data_cache), "w")
end

return data
