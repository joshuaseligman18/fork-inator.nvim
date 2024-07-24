# fork-inator.nvim

![inator](./resources/inator.jpg)

Fork-inator is a plugin for Neovim that handles the problem of having many
terminal sessions open at once to run various tools and scripts while developing.
Fork-inator fixes this problem by managing the execution of shell scripts in the
background of a Neovim session. All scripts are managed internally by Neovim and
exit automatically when the Neovim session exits. Additionally, logs from each
script are stored in respective stdout and stderr log files in the Neovim data
folder for access after the session closes without having to painfully scroll
through the terminal to find a specific log.

## Configuration
Add fork-inator.nvim through your plugin manager. Below is an example using
lazy.nvim. In your config function, make sure to call setup() and set a Vim
key binding for toggling the Fork-inator UI.

```lua
return {
    "joshuaseligman18/fork-inator.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        local forkInator = require("fork-inator")

        forkInator.setup()
        vim.keymap.set("n", "<leader>fi", function() forkInator.toggle() end)
    end,
}
```

The setup function can take in a table of configurations. Any property that is
not provided will be set at the default. A description of all configuration
properties and their default values are listed below and can also be found
in the config.lua source file.

```lua
---@class ForkInatorConfig
---@field logRetention number Retention time for logs in seconds (default 10800)
---@field keyMap ForkInatorKeymaps Table of keymaps for interacting with workflows

---@class ForkInatorKeymaps
---@field startWorkflow string Keymap to start a workflow
---@field killWorkflow string Keymap to kill a workflow
---@field toggleLogs string Keymap to toggle the log view

---@type ForkInatorConfig
local defaultConfig = {
    logRetention = 10800,
    keyMap = {
        startWorkflow = "<leader>fs",
        killWorkflow = "<leader>fk",
        toggleLogs = "<leader>fl",
    },
}
```

## Defining Workflows
In the /lua folder of your Neovim configuration, add a /fork-inator-workflows
folder. This is the home of all workflow files. Organization of workflow files
in this folder is up to the user as the plugin recursively reads through all
lua files in the folder. Each lua file in the /fork-inator-workflows file
should represent an individual workflow as shown below.

```lua
-- Sample workflow file
return {
    name = 'hello world',
    access = nil,
    workDir = '/Users/my-computer/Documents',
    script = [[
        echo "Hello fork-inator";
        sleep 5;
        echo "Hello after sleeping" >&2;
    ]]
}
```

The table returned by a workflow file should match the following type definition.

```lua
---@class ForkInatorWorkflowDefinititon
---@field name string Name of the workflow
---@field access string[] Array of Neovim buffers (absolute paths) which the workflow can be called from (default global if not provided)
---@field workDir string Working directory of the script
---@field script string Script to run
```

*Note: The script should be a valid shell script as a .sh file gets created with
the provided script.*

## Using Fork-inator
Once the plugin is set up, you can access the workflows by running the
toggle function. Once opened, multiple windows will appear, including a list
of all workflows, the status of the workflow the cursor is on, and the logs of
the workflow (accessible by toggling the logs). Moving the workflow between these
windows can be done with the built-in key bindings for navigating multiple windows
(see corresponding [Neovim docs](https://neovim.io/doc/user/windows.html#_4.-moving-cursor-to-other-windows)).
All logs are persisted in files, which you can always access in the Neovim data
directory (~/.local/share/nvim/fork-inator).
