local M = {}

local cache = require("tailwind-autosort.cache")

M.find_root = function(ctx, file_patterns)
	return vim.fs.find(file_patterns, { path = ctx.filename, upward = true })[1]
end

---@param file string
---@return string
M.current_file_path_absolute = function(file)
	return vim.fn.fnamemodify(file, ":p")
end

---@param search_text string
---@param path string
M.find_text_in_file = function(search_text, path)
	local find_command =
		string.format("rg --count '\\\"%s\\\"' %s", search_text, path)

	local result = vim.fn.system(find_command)

	result = result:gsub("%s+", "")

	-- Convert the result to a number
	local count = tonumber(result)

	-- Return the count
	return count or 0 -- If the conversion fails, return 0
end

M.set_tw_root = function()
	local tw_file_pattern = {
		"tailwind.config.ts",
		"tailwind.config.js",
	}

	if cache.cache.tw_root_dir == nil then
		local ctx = {}
		ctx.filename = vim.fn.expand("%:p")

		local tw_root = M.find_root(ctx, tw_file_pattern)

		if not tw_root then
			cache.cache.tw_root_dir = false
			return
		end

		cache.cache.tw_root_dir = M.current_file_path_absolute(tw_root)
	end
end

M.set_prettier_root = function()
	local prettier_file_pattern = {
		"prettier",
		".prettierrc",
		".prettierrc.json",
		".prettierrc.yml",
		".prettierrc.yaml",
		".prettierrc.json5",
		".prettierrc.js",
		"prettier.config.js",
		".prettierrc.mjs",
		"prettier.config.mjs",
		".prettierrc.cjs",
		"prettier.config.cjs",
		".prettierrc.toml",
	}

	if cache.cache.prettier_root_dir == nil then
		local ctx = {}
		ctx.filename = vim.fn.expand("%:p")

		local prettier_root = M.find_root(ctx, prettier_file_pattern)

		if not prettier_root then
			cache.cache.prettier_root_dir = false
			return
		end

		cache.cache.prettier_root_dir =
			M.current_file_path_absolute(prettier_root)
	end
end

M.set_prettier_tw_plugin = function()
	if
		cache.cache.has_tw_prettier_plugin == nil
		and (
			cache.cache.prettier_root_dir ~= false
			or cache.cache.prettier_root_dir == nil
		)
	then
		local result = M.find_text_in_file(
			"prettier-plugin-tailwindcss",
			cache.cache.prettier_root_dir
		)

		if not result then
			cache.cache.has_tw_prettier_plugin = false
		end

		cache.cache.has_tw_prettier_plugin = result > 0
	else
		cache.cache.has_tw_prettier_plugin = false
	end
end

return M
