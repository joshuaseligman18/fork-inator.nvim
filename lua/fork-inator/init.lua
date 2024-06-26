local Config = require('fork-inator.config')

local M = {}

---@param opts ForkInatorConfig
function M:setup(opts)
    if not opts then
        opts = Config.getDefaultConfig()
    end
end

return M
