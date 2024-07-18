local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event
local FIWorkflow = require("fork-inator.workflow")

local M = {}

local workflowBufnr = vim.api.nvim_create_buf(false, true)
local statusBufnr = vim.api.nvim_create_buf(false, true)

local function setWorkflowBufnr()
    local bufnrContents = {}
    for i, workflow in ipairs(FIWorkflow.workflows) do
        table.insert(bufnrContents, "" .. i .. ". " .. workflow.definition.name)
    end
    vim.api.nvim_buf_set_lines(workflowBufnr, 0, -1, true, bufnrContents)
end

local function setStatusBufnr(workflowIdx)
    if #FIWorkflow.workflows == 0 then
        return
    end

    local selectedWorkflow = FIWorkflow.workflows[workflowIdx]
    local bufnrContents = {
        "Name: " .. selectedWorkflow.definition.name,
        "File: " .. selectedWorkflow.file,
        "WorkDir: " .. selectedWorkflow.definition.workDir,
        "Status: " .. selectedWorkflow.status,
    }
    vim.api.nvim_buf_set_lines(statusBufnr, 0, -1, true, bufnrContents)
end

function M:createPopup()
    local workflowPopup = Popup({
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
        bufnr = workflowBufnr,
    })

    local statusPopup = Popup({
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
        bufnr = statusBufnr,
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
            Layout.Box(workflowPopup, { size = "30%" }),
            Layout.Box(statusPopup, { size = "70%" }),
        }, { dir = "row" })
    )

    workflowPopup:on(event.CursorMoved, function()
        local index = vim.api.nvim_win_get_cursor(0)[1]
        setStatusBufnr(index)
    end)

    workflowPopup:on(event.BufLeave, function()
        self:toggle()
    end)

    workflowPopup:map("n", "<esc>", function()
        self:toggle()
    end, {})
end

function M:init()
    setWorkflowBufnr()
    self:createPopup()
    self.isOpen = false
    self.mounted = false
end

function M:toggle()
    if self.isOpen then
        self.layout:hide()
    elseif not self.mounted then
        self.layout:mount()
        self.mounted = true
    else
        self.layout:show()
    end
    self.isOpen = not self.isOpen
end

return M
