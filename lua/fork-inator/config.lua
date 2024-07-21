---@class ForkInatorConfig
---@field logRetention number Retention time for logs in seconds (default 10800)
---@field keyMap ForkInatorKeymaps Table of keymaps for interacting with workflows

---@class ForkInatorKeymaps
---@field startWorkflow string Keymap to start a workflow

local M = {}

---@return ForkInatorConfig
local function getDefaultConfig()
    ---@type ForkInatorConfig
    local defaultConfig = {
        logRetention = 10800,
        keyMap = {
            startWorkflow = "<leader>s",
        },
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

    ---@type ForkInatorKeymaps
    local finalKeymap = {
        startWorkflow = opts.keyMap.startWorkflow
            or defaultConfig.keyMap.startWorkflow,
    }

    ---@type ForkInatorConfig
    local completeConfig = {
        logRetention = opts.logRetention or defaultConfig.logRetention,
        keyMap = finalKeymap,
    }

    self.config = completeConfig
end

return M
