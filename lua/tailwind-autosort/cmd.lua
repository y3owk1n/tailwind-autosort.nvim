local M = {}

local state = require("tailwind-autosort.state")
local lsp = require("tailwind-autosort.lsp")
local cache = require("tailwind-autosort.cache")

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

	usercmd("TailwindAutoSortResetCache", cache.reset_cache, {})
end

M.create_autocmd = function()
	autocmd("BufWritePre", {
		group = M.create_augroup("format_on_save"),
		pattern = { "*.tsx", "*.jsx", "*.css" },
		callback = function()
			vim.schedule(function()
				lsp.run_sort()
			end)
		end,
	})
end

return M
