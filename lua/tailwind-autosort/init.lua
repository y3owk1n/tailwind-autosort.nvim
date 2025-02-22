local M = {}

---@class TailwindAutoSort.Config
---@field enable_autocmd boolean
---@field notify_line_changed boolean

---@class TailwindAutoSort.Cache
---@field prettier_root_dir string|nil|false
---@field has_tw_prettier_plugin boolean|nil

local config = require("tailwind-autosort.config")
local cmd = require("tailwind-autosort.cmd")

---@param options TailwindAutoSort.Config
M.setup = function(options)
	config.options = vim.tbl_deep_extend("keep", options, config.options)

	cmd.create_user_command()

	if config.options.enable_autocmd then
		cmd.create_autocmd()
	end
end

return M
