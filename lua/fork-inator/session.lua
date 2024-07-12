local Path = require("plenary.path")

local M = {}

function M:initializeSession()
    local fiDataPath = Path.new(vim.fn.stdpath('data') .. '/fork-inator')
    if not fiDataPath:exists() then
        fiDataPath:mkdir()
    end

    local sessionTime = os.time()
    local sessionDate = os.date("%Y-%m-%d-%H-%M-%S", sessionTime)
    local buf = string.gsub(vim.api.nvim_buf_get_name(0), "/", "-")

    self.dataFolder = fiDataPath:absolute() .. '/' .. sessionDate .. buf

    local dataPath = Path.new(self.dataFolder)
    assert(not dataPath:exists())
    -- dataPath:mkdir()
end

return M
