---@class ForkInatorConfig
---@field logRetention number Retention time for logs in seconds (default 10800)

local M = {}

---@param opts ForkInatorConfig
---@return ForkInatorConfig
function M.generateCompleteConfig(opts)
    local defaultConfig = M.getDefaultConfig()

    if opts == nil then
        return defaultConfig
    end

    ---@type ForkInatorConfig
    local completeConfig = {
        logRetention = opts.logRetention or defaultConfig.logRetention
    }

    return completeConfig
end

---@return ForkInatorConfig
function M.getDefaultConfig()
    ---@type ForkInatorConfig
    local defaultConfig = {
        logRetention = 10800,
    }
    return defaultConfig
end

return M
