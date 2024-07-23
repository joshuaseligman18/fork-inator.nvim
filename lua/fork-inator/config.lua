---@class ForkInatorConfig
---@field logRetention number Retention time for logs in seconds (default 10800)
---@field keyMap ForkInatorKeymaps Table of keymaps for interacting with workflows

---@class ForkInatorKeymaps
---@field startWorkflow string Keymap to start a workflow
---@field killWorkflow string Keymap to kill a workflow
---@field toggleLogs string Keymap to toggle the log view

local M = {}

---@return ForkInatorConfig
local function getDefaultConfig()
    ---@type ForkInatorConfig
    local defaultConfig = {
        logRetention = 10800,
        keyMap = {
            startWorkflow = "<leader>fs",
            killWorkflow = "<leader>fk",
            toggleLogs = "<leader>fl",
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
        killWorkflow = opts.keyMap.killWorkflow
            or defaultConfig.keyMap.killWorkflow,
        toggleLogs = opts.keyMap.toggleLogs or defaultConfig.keyMap.toggleLogs,
    }

    ---@type ForkInatorConfig
    local completeConfig = {
        logRetention = opts.logRetention or defaultConfig.logRetention,
        keyMap = finalKeymap,
    }

    self.config = completeConfig
end

return M
