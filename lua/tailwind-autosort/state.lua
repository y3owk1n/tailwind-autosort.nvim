local M = {}

local log = require("tailwind-autosort.log")

---@type TailwindAutoSort.Option
M.state = {}

M.get = function()
	log.info("State: " .. vim.inspect(M.state))
end

M.enable = function()
	M.state.autosort_on_save.enabled = true
	log.info("Auto sort on save enabled")
end

M.disable = function()
	M.state.autosort_on_save.enabled = false
	log.info("Auto sort on save disabled")
end

return M
