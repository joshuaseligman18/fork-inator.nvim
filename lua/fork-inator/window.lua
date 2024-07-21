local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event
local FIWorkflow = require("fork-inator.workflow")
local FIConfig = require("fork-inator.config")

local M = {}

function M:init()
    self.isOpen = false
end

function M:toggle()
    if self.isOpen then
        self.layout:unmount()
    else
        self:_createPopup()
    end
    self.isOpen = not self.isOpen
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
        focusable = false,
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

    self.layout = Layout(
        {
            position = "50%",
            size = {
                width = 100,
                height = "60%",
            },
        },
        Layout.Box({
            Layout.Box(self.workflowPopup, { size = "30%" }),
            Layout.Box(self.statusPopup, { size = "70%" }),
        }, { dir = "row" })
    )
    self.layout:mount()

    self.workflowPopup:on(event.CursorMoved, function()
        local index = vim.api.nvim_win_get_cursor(0)[1]
        self:_setStatusBufnr(index)
    end)

    self.workflowPopup:on(event.BufLeave, function()
        self:toggle()
    end)

    self.workflowPopup:map("n", "<esc>", function()
        self:toggle()
    end, {})

    self.workflowPopup:map("n", FIConfig.config.keyMap.startWorkflow, function()
        local index = vim.api.nvim_win_get_cursor(0)[1]
        print("Start workflow " .. index)
        FIWorkflow:startWorkflow(index)
    end, {})
end

function M:_setWorkflowBufnr()
    local bufnrContents = {}
    for i, workflow in ipairs(FIWorkflow.workflows) do
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
    if #FIWorkflow.workflows == 0 then
        return
    end

    local selectedWorkflow = FIWorkflow.workflows[workflowIdx]
    local bufnrContents = {
        "Name: " .. selectedWorkflow.definition.name,
        "Source file: " .. selectedWorkflow.sourceFile,
        "Work directory: " .. selectedWorkflow.definition.workDir,
        "Status: " .. selectedWorkflow.status,
    }
    vim.api.nvim_buf_set_lines(
        self.statusPopup.bufnr,
        0,
        -1,
        true,
        bufnrContents
    )
end

return M
