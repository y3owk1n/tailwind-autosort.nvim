local M = {}

local config = require("tailwind-autosort.config")
local state = require("tailwind-autosort.state")
local lsp = require("tailwind-autosort.lsp")
local log = require("tailwind-autosort.log")
local file = require("tailwind-autosort.file")

---@param options TailwindAutoSort.Option
M.setup = function(options)
	config.options = vim.tbl_deep_extend("keep", options, config.options)

	state.state.autosort_on_save.enabled =
		config.options.autosort_on_save.enabled

	local format_on_save_au = vim.api.nvim_create_augroup(
		"tailwind-autosort_" .. "format_on_save",
		{ clear = true }
	)

	vim.api.nvim_create_user_command("TailwindAutoSortRun", function()
		vim.schedule(lsp.run_sort)
	end, {})

	vim.api.nvim_create_user_command("TailwindAutoSortGetState", state.get, {})

	vim.api.nvim_create_user_command("TailwindAutoSortEnable", state.enable, {})

	vim.api.nvim_create_user_command(
		"TailwindAutoSortDisable",
		state.disable,
		{}
	)

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = format_on_save_au,
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
