local M = {}

local state = require("tailwind-autosort.state")
local lsp = require("tailwind-autosort.lsp")
local log = require("tailwind-autosort.log")
local file = require("tailwind-autosort.file")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

---@param name string
---@return integer
M.create_augroup = function(name)
	return augroup("tailwind-autosort_" .. name, { clear = true })
end

M.create_user_command = function()
	usercmd("TailwindAutoSortRun", function()
		vim.schedule(lsp.run_sort)
	end, {})

	usercmd("TailwindAutoSortGetState", state.get, {})

	usercmd("TailwindAutoSortEnable", state.enable, {})

	usercmd("TailwindAutoSortDisable", state.disable, {})
end

M.create_autocmd = function()
	autocmd("BufWritePre", {
		group = M.create_augroup("format_on_save"),
		pattern = { "*.tsx", "*.jsx" },
		callback = function()
			local enabled_autosave = state.state.autosort_on_save.enabled

			-- Check if auto format is enabled
			if not enabled_autosave then
				log.notify(
					"Auto format for TailwindSort is disabled, run :TailwindSortEnable to enable auto format",
					vim.log.levels.INFO
				)

				return
			end
			local has_prettier_tw_plugin = file.check_prettier_tw_plugin()

			-- Check if prettier tailwind plugin is installed
			if has_prettier_tw_plugin then
				log.notify(
					"Has prettier tailwind plugin, abort!",
					vim.log.levels.WARN
				)

				return
			end

			vim.schedule(function()
				lsp.run_sort(true)
			end)
		end,
	})
end

return M
