local FIConfig = require("fork-inator.config")
local FIWorkflow = require("fork-inator.workflow")
local FISession = require("fork-inator.session")
local FIWindow = require("fork-inator.window")

local M = {}

---@param opts ForkInatorConfig
function M.setup(opts)
    FIConfig:loadConfig(opts)
    FISession:initializeSession()
    FIWorkflow:loadWorkflows()
end

function M.toggle()
    FIWindow:toggle()
end

return M
