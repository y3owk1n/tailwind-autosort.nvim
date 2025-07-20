---@mod tailwind-autosort.nvim.config Configurations
---@brief [[
---
---Example Configuration:
---
--->
---{
---	enable_autocmd = true,
---	notify_line_changed = true,
---}
---<
---
---@brief ]]

local M = {}

---@type TailwindAutoSort.Config
M.config = {}

---@private
---@type TailwindAutoSort.Config
local defaults = {
	enable_autocmd = true,
	notify_line_changed = true,
}

---@private
---@param user_config? TailwindAutoSort.Config
M.setup = function(user_config)
	M.config = vim.tbl_deep_extend("force", defaults, user_config or {})

	require("tailwind-autosort.cmd").create_user_command()

	if M.config.enable_autocmd then
		require("tailwind-autosort.cmd").create_autocmd()
	end
end

return M
