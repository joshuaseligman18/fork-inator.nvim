local Popup = require("nui.popup")
local Layout = require("nui.layout")
local FIWorkflow = require("fork-inator.workflow")

local M = {}
M.layout = nil

local workflowBufnr = vim.api.nvim_create_buf(false, true)
local statusBufnr = vim.api.nvim_create_buf(false, true)

local function setWorkflowBufnr()
    local bufnrContents = {}
    for _, workflow in ipairs(FIWorkflow.workflows) do
        table.insert(bufnrContents, workflow.definition.name)
    end
    vim.api.nvim_buf_set_lines(workflowBufnr, 0, -1, true, bufnrContents)
end

local function createPopup()
    setWorkflowBufnr()

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
            modifiable = false,
            readonly = true,
        },
        bufnr = M.statusBufnr,
    })

    M.layout = Layout(
        {
            position = "50%",
            size = {
                width = 100,
                height = "60%",
            },
        },
        Layout.Box({
            Layout.Box(workflowPopup, { size = "40%" }),
            Layout.Box(statusPopup, { size = "60%" }),
        }, { dir = "row" })
    )

    M.layout:mount()
end

function M:toggle()
    if self.layout == nil then
        createPopup()
    else
        self.layout:unmount()
        self.layout = nil
    end
end

return M
