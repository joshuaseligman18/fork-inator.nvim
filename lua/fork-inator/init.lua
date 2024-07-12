local FIConfig = require("fork-inator.config")
local FIWorkflow = require("fork-inator.workflow")
local FISession = require("fork-inator.session")

local M = {}

---@param opts ForkInatorConfig
function M:setup(opts)
    self.config = FIConfig.generateCompleteConfig(opts)
    print(self.config.logRetention)
    FISession:initializeSession()
    FIWorkflow:loadWorkflows()
end

return M
