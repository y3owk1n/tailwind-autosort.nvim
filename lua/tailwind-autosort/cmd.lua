local M = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

---@param name string
---@return integer
M.create_augroup = function(name)
	return augroup("tailwind-autosort_" .. name, { clear = true })
end

---@param config TailwindAutoSort.Config
M.create_user_command = function(config)
	usercmd("TailwindAutoSortRun", function()
		vim.schedule(function()
			require("tailwind-autosort.lsp").run_sort(config)
		end)
	end, {})

	usercmd(
		"TailwindAutoSortResetCache",
		require("tailwind-autosort.cache").reset_cache,
		{}
	)
end

---@param config TailwindAutoSort.Config
M.create_autocmd = function(config)
	autocmd("BufWritePre", {
		group = M.create_augroup("sort_write_pre"),
		pattern = { "*.tsx", "*.jsx", "*.css" },
		callback = function()
			require("tailwind-autosort.lsp").run_sort(config)
		end,
	})
end

return M
