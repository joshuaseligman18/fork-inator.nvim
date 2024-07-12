local FIConfig = require("fork-inator.config")
local FIWorkflow = require("fork-inator.workflow")

local M = {}

---@param opts ForkInatorConfig
function M:setup(opts)
    if opts == nil then
        opts = FIConfig.getDefaultConfig()
    end
    FIWorkflow:loadWorkflows()
end

return M
