local Path = require("plenary.path")
local ScanDir = require("plenary.scandir")

---@class ForkInatorWorkflowDefinititon
---@field name string
---@field workDir string
---@field script string

---@class ForkInatorWorkflow
---@field definition ForkInatorWorkflowDefinititon
---@field status ForkInatorStatus

---@enum ForkInatorStatus
ForkInatorStatus = {
    RUNNING = 0,
    DEAD = 1,
}

local WORKFLOW_DIR = vim.fn.stdpath("config") .. "/lua/fork-inator-workflows"

local M = {}

function M.listDefinitions()
    local workflowPath = Path.new(WORKFLOW_DIR)
    if not workflowPath:exists() then
        workflowPath:mkdir()
    end

    local workflowFiles = ScanDir.scan_dir(workflowPath:absolute(), {
        add_dirs = false,
        search_pattern = function(file)
            return string.find(file, ".lua", -4, true) ~= nil
        end,
    })

    for _, file in pairs(workflowFiles) do
        local start = string.find(file, "fork-inator-workflows", 1, true)
        assert(start ~= nil)
        local requireModule = string.sub(file, start, -5)

        ---@type ForkInatorWorkflowDefinititon
        local def = require(requireModule)
        print(def.name)
    end
end

return M
