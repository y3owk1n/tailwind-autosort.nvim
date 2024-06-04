local M = {}

---@param message string
---@param level integer?
M.notify = function(message, level)
	level = level or vim.log.levels.INFO
	return vim.notify("[tailwind-autosort] " .. message, level)
end

return M
