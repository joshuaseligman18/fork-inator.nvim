local Path = require("plenary.path")
local ScanDir = require("plenary.scandir")
local FIUtil = require("fork-inator.util")
local FISession = require("fork-inator.session")

---@class ForkInatorWorkflowDefinititon
---@field name string Name of the workflow
---@field access string[] Array of NeoVim buffers (absolute paths) which the workflow can be called from (default global if not provided)
---@field workDir string Working directory of the script
---@field script string Script to run

---@class ForkInatorWorkflow
---@field definition ForkInatorWorkflowDefinititon
---@field status ForkInatorStatus

---@enum ForkInatorStatus
ForkInatorStatus = {
    NOT_STARTED = 0,
    RUNNING = 1,
    DEAD = 2,
}

local GLOBAL_WORKFLOW_DIR = vim.fn.stdpath("config")
    .. "/lua/fork-inator-workflows"

local M = {}

function M:loadWorkflows()
    ---@param loadPath string
    local function readWorkflowFiles(loadPath)
        local workflowFiles = ScanDir.scan_dir(loadPath, {
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
            if
                def.access == nil
                or FIUtil.hasValue(def.access, vim.api.nvim_buf_get_name(0))
            then
                print(def.name, def.script)
                print(FISession.dataFolder)
            end
        end
    end

    local globalWorkflowPath = Path.new(GLOBAL_WORKFLOW_DIR)
    if globalWorkflowPath:exists() and globalWorkflowPath:is_dir() then
        readWorkflowFiles(globalWorkflowPath:absolute())
    else
        error("Missing workflow directory: " .. GLOBAL_WORKFLOW_DIR, 1)
    end
end

return M
