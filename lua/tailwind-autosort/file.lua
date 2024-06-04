local M = {}

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

---@return boolean
M.check_prettier_tw_plugin = function()
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

	local ctx = {}
	ctx.filename = vim.fn.expand("%:p")

	local prettier_root = M.find_root(ctx, prettier_file_pattern)

	if not prettier_root then
		return false
	end

	local prettier_root_path = M.current_file_path_absolute(prettier_root)

	local result =
		M.find_text_in_file("prettier-plugin-tailwindcss", prettier_root_path)

	if not result then
		return false
	end

	return true
end

return M
