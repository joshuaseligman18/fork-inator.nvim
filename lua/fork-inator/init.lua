local Config = require("fork-inator.config")
local Workflow = require("fork-inator.workflow")

local M = {}

---@param opts ForkInatorConfig
function M:setup(opts)
    if not opts then
        opts = Config.getDefaultConfig()
    end
    Workflow:loadWorkflows()
end

return M
