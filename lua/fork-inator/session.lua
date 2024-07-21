local Path = require("plenary.path")
local ScanDir = require("plenary.scandir")
local FIConfig = require("fork-inator.config")

local fiDataPath = Path.new(vim.fn.stdpath("data") .. "/fork-inator")

local M = {}

function M:initializeSession()
    if not fiDataPath:exists() then
        fiDataPath:mkdir()
    end

    self.sessionTime = os.time()
    local sessionDate = os.date("%Y-%m-%d-%H-%M-%S", self.sessionTime)
    local buf = string.gsub(vim.api.nvim_buf_get_name(0), "/", "-")

    self.dataFolder = fiDataPath:absolute() .. "/" .. sessionDate .. buf

    local dataPath = Path.new(self.dataFolder)
    assert(not dataPath:exists())
    dataPath:mkdir()

    self:cleanUpOldSessions()
end

function M:cleanUpOldSessions()
    local logFolders = ScanDir.scan_dir(fiDataPath:absolute(), {
        only_dirs = true,
    })

    for _, logFolder in ipairs(logFolders) do
        local lastSlash = string.find(logFolder, "/[^/]*$")
        assert(lastSlash ~= nil)
        local dateSub = string.sub(logFolder, lastSlash + 1, lastSlash + 19)

        local folderTime = os.time({
            year = string.sub(dateSub, 1, 4),
            month = string.sub(dateSub, 6, 7),
            day = string.sub(dateSub, 9, 10),
            hour = string.sub(dateSub, 12, 13),
            min = string.sub(dateSub, 15, 16),
            sec = string.sub(dateSub, 18, 19),
        })

        if self.sessionTime - folderTime > FIConfig.config.logRetention then
            Path.new(logFolder):rmdir()
        end
    end
end

return M