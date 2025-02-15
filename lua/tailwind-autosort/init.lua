local M = {}

local config = require("tailwind-autosort.config")
local cmd = require("tailwind-autosort.cmd")

---@param options TailwindAutoSort.Option
M.setup = function(options)
	config.options = vim.tbl_deep_extend("keep", options, config.options)

	cmd.create_user_command()
	cmd.create_autocmd(config.options)
end

return M
