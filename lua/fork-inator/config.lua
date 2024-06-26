---@class ForkInatorConfig
---@field workflowDir string

local M = {}

---@return ForkInatorConfig
function M.getDefaultConfig()
    return {
        workflowDir = '~/fork-inator'
    }
end

return M
