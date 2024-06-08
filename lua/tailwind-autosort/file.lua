local M = {}

local cache = require("tailwind-autosort.cache")
local log = require("tailwind-autosort.log")

M.find_root = function(ctx, file_patterns)
	return vim.fs.find(file_patterns, { path = ctx.filename, upward = true })[1]
end

M.find_root_dir = function(ctx, file_patterns)
	local found_file =
		vim.fs.find(file_patterns, { path = ctx.filename, upward = true })[1]
	if found_file then
		return vim.fn.fnamemodify(found_file, ":h")
	else
		return nil
	end
end

M.is_in_root_directory = function(ctx, file_patterns, cache_root_dir)
	local root_dir = M.find_root_dir(ctx, file_patterns)

	-- Compare the current directory with the root directory
	if cache_root_dir == root_dir then
		return true
	else
		return false
	end
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

	local ctx = {}
	ctx.filename = vim.fn.expand("%:p")

	if
		cache.cache.tw_root_dir == nil
		or M.is_in_root_directory(
				ctx,
				tw_file_pattern,
				cache.cache.tw_root_dir
			)
			== false
	then
		local tw_root = M.find_root_dir(ctx, tw_file_pattern)

		if not tw_root then
			cache.cache.tw_root_dir = false
			return
		end

		cache.cache.tw_root_dir = tw_root
		return
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
	if cache.cache.has_tw_prettier_plugin == nil then
		if
			cache.cache.prettier_root_dir ~= false
			or cache.cache.prettier_root_dir == nil
		then
			local result = M.find_text_in_file(
				"prettier-plugin-tailwindcss",
				cache.cache.prettier_root_dir
			)

			if not result then
				cache.cache.has_tw_prettier_plugin = false
			end

			cache.cache.has_tw_prettier_plugin = result > 0
		end
	end
end

return M
