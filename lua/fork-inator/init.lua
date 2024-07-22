local FISession = require("fork-inator.session")

local M = {}

---@param opts ForkInatorConfig
function M.setup(opts)
    FISession:initializeSession(opts)
end

function M.toggle()
    FISession.window:toggle()
end

return M
