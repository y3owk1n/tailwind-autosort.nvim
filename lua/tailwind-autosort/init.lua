local M = {}

local config = require("tailwind-autosort.config")
local state = require("tailwind-autosort.state")
local cmd = require("tailwind-autosort.cmd")

---@param options TailwindAutoSort.Option
M.setup = function(options)
	config.options = vim.tbl_deep_extend("keep", options, config.options)

	state.state.autosort_on_save = {
		enabled = config.options.autosort_on_save.enabled,
		notify_after_save = config.options.autosort_on_save.notify_after_save,
	}

	cmd.create_user_command()
	cmd.create_autocmd()
end

return M
