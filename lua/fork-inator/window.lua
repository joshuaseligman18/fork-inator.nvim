local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

local M = {}

---@param session any The parent session
function M:init(session)
    self.isOpen = false
    self.areLogsOpen = false
    self.session = session
end

function M:toggle()
    if self.isOpen then
        self.layout:unmount()
    else
        self:_createPopup()
    end
    self.isOpen = not self.isOpen
end

function M:toggleLogs()
    if not self.isOpen then
        return
    end

    self.areLogsOpen = not self.areLogsOpen
    if self.areLogsOpen then
        self.layout:update(self.logBox)
        self:_setLogBufnr(self.workflowIndex)
    else
        self.layout:update(self.statusBox)
        self:_setStatusBufnr(self.workflowIndex)
    end
end

---@param sourceIndex number The workflow index requesting a status buffer update
function M:requestStatusUpdate(sourceIndex)
    if not self.areLogsOpen and self.workflowIndex == sourceIndex then
        vim.schedule(function()
            self:_setStatusBufnr(sourceIndex)
        end)
    end
end

---@param sourceIndex number The workflow index requesting a log buffer update
function M:requestLogUpdate(sourceIndex)
    if self.areLogsOpen and self.workflowIndex == sourceIndex then
        vim.schedule(function()
            self:_setLogBufnr(sourceIndex)
        end)
    end
end

function M:_createPopup()
    self.workflowPopup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Fork-inator workflows",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = true,
        },
    })
    self:_setWorkflowBufnr()

    self.statusPopup = Popup({
        enter = false,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Workflow status",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = true,
        },
    })

    self.stdoutPopup = Popup({
        enter = false,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Workflow logs (stdout)",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = true,
        },
    })

    self.stderrPopup = Popup({
        enter = false,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Workflow logs (stderr)",
                top_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = true,
        },
    })

    self.statusBox = Layout.Box({
        Layout.Box(self.workflowPopup, { size = "30%" }),
        Layout.Box(self.statusPopup, { size = "70%" }),
    }, { dir = "row" })

    self.logBox = Layout.Box({
        Layout.Box(self.workflowPopup, { size = "30%" }),
        Layout.Box({
            Layout.Box(self.stdoutPopup, { size = "50%" }),
            Layout.Box(self.stderrPopup, { size = "50%" }),
        }, { size = "70%", dir = "col" }),
    }, { dir = "row" })

    self.areLogsOpen = false
    self.layout = Layout({
        position = "50%",
        size = {
            width = 100,
            height = "60%",
        },
    }, self.statusBox)
    self.layout:mount()

    self.workflowPopup:on(event.CursorMoved, function()
        self.workflowIndex = vim.api.nvim_win_get_cursor(0)[1]
        if self.areLogsOpen then
            self:_setLogBufnr(self.workflowIndex)
        else
            self:_setStatusBufnr(self.workflowIndex)
        end
    end)

    self.workflowPopup:map("n", "<esc>", function()
        self:toggle()
    end, {})

    self.workflowPopup:map(
        "n",
        self.session.config.keyMap.startWorkflow,
        function()
            self.session.workflow:startWorkflow(self.workflowIndex)
        end,
        {}
    )

    self.workflowPopup:map(
        "n",
        self.session.config.keyMap.killWorkflow,
        function()
            self.session.workflow:killWorkflow(self.workflowIndex)
        end,
        {}
    )

    self.workflowPopup:map(
        "n",
        self.session.config.keyMap.toggleLogs,
        function()
            self:toggleLogs()
        end,
        {}
    )

    self.statusPopup:map("n", "<esc>", function()
        self:toggle()
    end, {})

    self.stdoutPopup:map("n", "<esc>", function()
        self:toggle()
    end, {})

    self.stderrPopup:map("n", "<esc>", function()
        self:toggle()
    end, {})
end

function M:_setWorkflowBufnr()
    local bufnrContents = {}
    for i, workflow in ipairs(self.session.workflow.workflows) do
        table.insert(bufnrContents, "" .. i .. ". " .. workflow.definition.name)
    end
    vim.api.nvim_buf_set_lines(
        self.workflowPopup.bufnr,
        0,
        -1,
        true,
        bufnrContents
    )
end

function M:_setStatusBufnr(workflowIdx)
    if #self.session.workflow.workflows == 0 then
        return
    end

    local selectedWorkflow = self.session.workflow.workflows[workflowIdx]
    local bufnrContents = {
        "Name: " .. selectedWorkflow.definition.name,
        "Source file: " .. selectedWorkflow.sourceFile,
        "Work directory: " .. selectedWorkflow.definition.workDir,
        "Status: " .. selectedWorkflow.status,
    }
    if selectedWorkflow.status == ForkInatorStatus.DEAD then
        table.insert(bufnrContents, "Exit code: " .. selectedWorkflow.exitCode)
    end

    vim.api.nvim_buf_set_lines(
        self.statusPopup.bufnr,
        0,
        -1,
        true,
        bufnrContents
    )
end

function M:_setLogBufnr(workflowIdx)
    if #self.session.workflow.workflows == 0 then
        return
    end

    local selectedWorkflow = self.session.workflow.workflows[workflowIdx]

    local outFile = io.open(selectedWorkflow.stdoutFile)
    assert(outFile ~= nil)

    local outBufnrContents = {}
    for line in outFile:lines() do
        table.insert(outBufnrContents, line)
    end

    vim.api.nvim_buf_set_lines(
        self.stdoutPopup.bufnr,
        0,
        -1,
        true,
        outBufnrContents
    )

    local errFile = io.open(selectedWorkflow.stderrFile)
    assert(errFile ~= nil)

    local errBufnrContents = {}
    for line in errFile:lines() do
        table.insert(errBufnrContents, line)
    end

    vim.api.nvim_buf_set_lines(
        self.stderrPopup.bufnr,
        0,
        -1,
        true,
        errBufnrContents
    )
end

return M
