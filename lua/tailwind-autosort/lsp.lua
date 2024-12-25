local M = {}

local log = require("tailwind-autosort.log")
local treesitter = require("tailwind-autosort.treesitter")
local state = require("tailwind-autosort.state")
local file = require("tailwind-autosort.file")
local cache = require("tailwind-autosort.cache")

---@return vim.lsp.Client|nil
M.get_tw_lsp_client = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ name = "tailwindcss", bufnr = bufnr })

	local tw_client = clients[1]

	if not tw_client then
		log.warn("Required tailwind-language-server is not running")
		return
	end

	return tw_client
end

M.run_sort = function()
	local enabled_autosort_onsave = state.state.autosort_on_save.enabled
	local write_on_sort = state.state.autosort_on_save.enable_write

	-- Check if auto format is enabled
	if not enabled_autosort_onsave then
		log.info(
			"Auto format for TailwindSort is disabled, run :TailwindSortEnable to enable auto format"
		)

		return
	end

	-- Set prettier root into cache
	file.set_prettier_root()

	-- Set has prettier tailwind plugin into cache
	file.set_prettier_tw_plugin()

	-- Check if prettier tailwind plugin is installed
	if cache.cache.has_tw_prettier_plugin then
		log.warn("Has prettier tailwind plugin, abort!")

		return
	end

	local client = M.get_tw_lsp_client()

	if not client then
		return
	end

	-- start running sorting and replace
	local bufnr = vim.api.nvim_get_current_buf()
	local params = vim.lsp.util.make_text_document_params(bufnr)
	local class_nodes = treesitter.get_class_nodes(bufnr, true)

	if not class_nodes then
		return
	end

	local class_text = {}
	local class_ranges = {}

	for _, node in pairs(class_nodes) do
		local start_row, start_col, end_row, end_col =
			treesitter.get_class_range(node, bufnr)
		local text = vim.api.nvim_buf_get_text(
			bufnr,
			start_row,
			start_col,
			end_row,
			end_col,
			{}
		)

		class_text[#class_text + 1] = table.concat(text, "\n")
		class_ranges[#class_ranges + 1] =
			{ start_row, start_col, end_row, end_col }
	end

	params.classLists = class_text
	client.request(
		"@/tailwindCSS/sortSelection",
		params,
		function(err, result, _, _)
			if err then
				return log.error(err.message)
			end
			if result.error then
				return log.error(result.error)
			end
			if not result or not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			local total_lines_sorted = 0

			for i, edit in pairs(result.classLists) do
				local lines = vim.split(edit, "\n")
				local original_lines = vim.split(class_text[i], "\n")

				for j, line in ipairs(lines) do
					-- Split the line into individual classNames
					local classNames = {}
					for className in line:gmatch("%S+") do
						table.insert(classNames, className)
					end

					-- Remove duplicates
					local seen = {}
					local uniqueClassNames = {}
					for _, className in ipairs(classNames) do
						if not seen[className] then
							seen[className] = true
							table.insert(uniqueClassNames, className)
						end
					end

					-- Join unique classNames back together with single spaces
					lines[j] = table.concat(uniqueClassNames, " ")
				end

				for k, line in ipairs(lines) do
					-- Remove extra spaces between class names
					line = line:gsub("%s+", " ")
					-- Trim leading and trailing spaces
					line = line:gsub("^%s*(.-)%s*$", "%1")
					lines[k] = line
				end

				local start_row, start_col, end_row, end_col =
					unpack(class_ranges[i])

				-- Only replace the lines if they are different
				local lines_changed = false
				for k, line in ipairs(lines) do
					if line ~= original_lines[k] then
						lines_changed = true
						break
					end
				end

				if lines_changed then
					total_lines_sorted = total_lines_sorted + 1
					local set_text = function()
						vim.api.nvim_buf_set_text(
							bufnr,
							start_row,
							start_col,
							end_row,
							end_col,
							lines
						)
					end

					pcall(set_text)
				end
			end

			if
				total_lines_sorted > 0
				and state.state.autosort_on_save.notify_after_save
			then
				log.info(
					"Tailwind class sorted for "
						.. total_lines_sorted
						.. " lines"
				)

				if vim.bo.modified and write_on_sort then
					vim.cmd("write")
				end
			end
		end,
		bufnr
	)
end

return M
