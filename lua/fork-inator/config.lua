---@class ForkInatorConfig
---@field logRetention number Retention time for logs in seconds (default 10800)

local M = {}

---@return ForkInatorConfig
local function getDefaultConfig()
    ---@type ForkInatorConfig
    local defaultConfig = {
        logRetention = 10800,
    }
    return defaultConfig
end

---@param opts ForkInatorConfig
function M:loadConfig(opts)
    local defaultConfig = getDefaultConfig()

    if opts == nil then
        self.config = defaultConfig
        return
    end

    ---@type ForkInatorConfig
    local completeConfig = {
        logRetention = opts.logRetention or defaultConfig.logRetention,
    }

    self.config = completeConfig
end

return M
