local M = {}

local log = require("tailwind-autosort.log")

M.state = {
	autosort_on_save = {
		enabled = false,
	},
}

M.get = function()
	log.notify("State: " .. vim.inspect(M.state))
end

M.enable = function()
	M.state.autosort_on_save.enabled = true
	log.notify("Auto sort on save enabled")
end

M.disable = function()
	M.state.autosort_on_save.enabled = false
	log.notify("Auto sort on save disabled")
end

return M
