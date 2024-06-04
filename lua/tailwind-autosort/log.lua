local M = {}

---@param message string
M.info = function(message)
	return vim.notify(message, vim.log.levels.INFO)
end

---@param message string
M.warn = function(message)
	return vim.notify(message, vim.log.levels.WARN)
end

---@param message string
M.error = function(message)
	return vim.notify(message, vim.log.levels.ERROR)
end

---@param message string
M.debug = function(message)
	return vim.notify(message, vim.log.levels.DEBUG)
end

return M
