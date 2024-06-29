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

local GLOBAL_WORKFLOW_DIR = vim.fn.stdpath("config")
    .. "/lua/fork-inator-workflows"
local LOCAL_WORKFLOW_DIR = vim.api.nvim_buf_get_name(0)
    .. "/fork-inator-workflows"

local M = {}

function M:loadWorkflows()
    ---@param loadPath string
    local function readWorkflowFiles(loadPath)
        local workflowFiles = ScanDir.scan_dir(loadPath, {
            add_dirs = false,
            searc__pattern = function(file)
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

    local globalWorkflowPath = Path.new(GLOBAL_WORKFLOW_DIR)
    if globalWorkflowPath:exists() and globalWorkflowPath:is_dir() then
        readWorkflowFiles(globalWorkflowPath:absolute())
    end

    local localWorkflowPath = Path.new(LOCAL_WORKFLOW_DIR)
    if localWorkflowPath:exists() and localWorkflowPath:is_dir() then
        readWorkflowFiles(localWorkflowPath:absolute())
    end
end

return M
