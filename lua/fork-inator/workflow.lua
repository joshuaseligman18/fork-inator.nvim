local Path = require("plenary.path")
local ScanDir = require("plenary.scandir")
local FIUtil = require("fork-inator.util")

---@class ForkInatorWorkflowDefinititon
---@field name string Name of the workflow
---@field access string[] Array of NeoVim buffers (absolute paths) which the workflow can be called from (default global if not provided)
---@field workDir string Working directory of the script
---@field script string Script to run

---@class ForkInatorWorkflow
---@field definition ForkInatorWorkflowDefinititon
---@field sourceFile string
---@field scriptFile string
---@field stdoutFile string
---@field stderrFile string
---@field status ForkInatorStatus
---@field job any
---@field exitCode number

---@enum ForkInatorStatus
ForkInatorStatus = {
    NOT_STARTED = "Not started",
    RUNNING = "Running",
    DEAD = "Dead",
}

local GLOBAL_WORKFLOW_DIR = vim.fn.stdpath("config")
    .. "/lua/fork-inator-workflows"

local M = {}

---@type ForkInatorWorkflow[]
M.workflows = {}

---@param session any The parent session
function M:loadWorkflows(session)
    self.session = session
    local globalWorkflowPath = Path.new(GLOBAL_WORKFLOW_DIR)
    if globalWorkflowPath:exists() and globalWorkflowPath:is_dir() then
        self:_readWorkflowFiles(globalWorkflowPath:absolute())
        self:_createWorkflowScripts()
    else
        error("Missing workflow directory: " .. GLOBAL_WORKFLOW_DIR, 1)
    end
end

---@param loadPath string
function M:_readWorkflowFiles(loadPath)
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
            table.insert(self.workflows, {
                definition = def,
                sourceFile = requireModule .. ".lua",
                status = ForkInatorStatus.NOT_STARTED,
            })
        end
    end
end

function M:_createWorkflowScripts()
    for _, workflow in ipairs(self.workflows) do
        local workflowFilePrefix = self.session.dataFolder
            .. "/"
            .. string.gsub(string.sub(workflow.sourceFile, 1, -5), "/", "-")
        local scriptFileName = workflowFilePrefix .. "-script.sh"
        local file = io.open(scriptFileName, "w")
        assert(file ~= nil, "Failed to create script " .. scriptFileName)
        file:write("#!/bin/sh\n")
        file:write(workflow.definition.script)
        file:close()

        local res = vim.system(
            { "chmod", "544", scriptFileName },
            { text = true }
        )
            :wait()
        assert(
            res.code == 0,
            "Failed to update permission of " .. scriptFileName
        )
        workflow.scriptFile = scriptFileName

        local stdoutFileName = workflowFilePrefix .. "-stdout.log"
        local stdoutFile = io.open(stdoutFileName, "w")
        assert(
            stdoutFile ~= nil,
            "Failed to create stdout log file " .. stdoutFileName
        )
        stdoutFile:close()
        workflow.stdoutFile = stdoutFileName

        local stderrFileName = workflowFilePrefix .. "-stderr.log"
        local stderrFile = io.open(stderrFileName, "w")
        assert(
            stderrFile ~= nil,
            "Failed to create stderr log file " .. stderrFileName
        )
        stderrFile:close()
        workflow.stderrFile = stderrFileName
    end
end

---@param index number Index of the workflow to start
function M:startWorkflow(index)
    if index <= 0 or index > #self.workflows then
        return
    end

    local selectedWorkflow = self.workflows[index]
    if selectedWorkflow.status == ForkInatorStatus.RUNNING then
        print(
            "Workflow "
                .. selectedWorkflow.definition.name
                .. " is already running"
        )
        return
    end

    assert(
        selectedWorkflow.scriptFile ~= nil,
        "Script file for "
            .. selectedWorkflow.definition.name
            .. " should not be nil"
    )
    assert(
        selectedWorkflow.stdoutFile ~= nil,
        "Stdout log file for "
            .. selectedWorkflow.definition.name
            .. " should not be nil"
    )
    assert(
        selectedWorkflow.stderrFile ~= nil,
        "Stderr log file for "
            .. selectedWorkflow.definition.name
            .. " should not be nil"
    )

    local stdoutFile = io.open(selectedWorkflow.stdoutFile, "a")
    assert(stdoutFile ~= nil, "Failed to open " .. selectedWorkflow.stdoutFile)
    local stderrFile = io.open(selectedWorkflow.stderrFile, "a")
    assert(stderrFile ~= nil, "Failed to open " .. selectedWorkflow.stderrFile)

    stdoutFile:write("Starting workflow on " .. os.date() .. "\n")

    selectedWorkflow.status = ForkInatorStatus.RUNNING

    selectedWorkflow.job = vim.system({ selectedWorkflow.scriptFile }, {
        cwd = selectedWorkflow.definition.workDir,
        text = true,
        stdout = function(err, data)
            if data ~= nil and err == nil then
                stdoutFile:write(data)
                stdoutFile:flush()
                self.session.window:requestLogUpdate(index)
            end
        end,
        stderr = function(err, data)
            if data ~= nil and err == nil then
                stderrFile:write(data)
                stderrFile:flush()
            end
        end,
    }, function(obj)
        stdoutFile:write(
            "Exited with status code "
                .. obj.code
                .. " on "
                .. os.date()
                .. "\n\n"
        )
        stdoutFile:close()
        stderrFile:close()
        selectedWorkflow.status = ForkInatorStatus.DEAD
        selectedWorkflow.exitCode = obj.code
        self.session.window:requestStatusUpdate(index)
        self.session.window:requestLogUpdate(index)
    end)
    self.session.window:requestStatusUpdate(index)
end

---@param index number Index of the workflow to kill
function M:killWorkflow(index)
    if index <= 0 or index > #self.workflows then
        return
    end

    local selectedWorkflow = self.workflows[index]
    if selectedWorkflow.status ~= ForkInatorStatus.RUNNING then
        print(
            "Workflow " .. selectedWorkflow.definition.name .. " is not running"
        )
        return
    end

    selectedWorkflow.job:wait(0)
end
return M
