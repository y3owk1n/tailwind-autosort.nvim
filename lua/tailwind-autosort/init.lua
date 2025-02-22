local M = {}

---@class TailwindAutoSort.Config
---@field enable_autocmd? boolean
---@field notify_line_changed? boolean

---@class TailwindAutoSort.Cache
---@field prettier_root_dir string|nil|false
---@field has_tw_prettier_plugin boolean|nil

local cmd = require("tailwind-autosort.cmd")
M.config = require("tailwind-autosort.config")

---@param user_config? TailwindAutoSort.Config
M.setup = function(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	cmd.create_user_command(M.config)

	if M.config.enable_autocmd then
		cmd.create_autocmd(M.config)
	end
end

return M
