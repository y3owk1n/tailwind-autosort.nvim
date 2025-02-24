local M = {}

---@param ctx { filename: string}
---@param file_patterns table<string>
---@return string
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
---@return number
M.find_text_in_file = function(search_text, path)
	local find_command =
		string.format("rg --count '\\\"%s\\\"' %s", search_text, path)

	local result = vim.fn.system(find_command)

	result = result:gsub("%s+", "")

	local count = tonumber(result)

	-- If conversion fails, return 0
	return count or 0
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

	if require("tailwind-autosort.cache").cache.prettier_root_dir == nil then
		local ctx = {}
		ctx.filename = vim.fn.expand("%:p")

		local prettier_root = M.find_root(ctx, prettier_file_pattern)

		if not prettier_root then
			require("tailwind-autosort.cache").cache.prettier_root_dir = false
			return
		end

		require("tailwind-autosort.cache").cache.prettier_root_dir =
			M.current_file_path_absolute(prettier_root)
	end
end

M.set_prettier_tw_plugin = function()
	if
		require("tailwind-autosort.cache").cache.has_tw_prettier_plugin == nil
	then
		if
			require("tailwind-autosort.cache").cache.prettier_root_dir
				~= false
			or require("tailwind-autosort.cache").cache.prettier_root_dir
				== nil
		then
			local result = M.find_text_in_file(
				"prettier-plugin-tailwindcss",
				require("tailwind-autosort.cache").cache.prettier_root_dir
			)

			if not result then
				require("tailwind-autosort.cache").cache.has_tw_prettier_plugin =
					false
			end

			require("tailwind-autosort.cache").cache.has_tw_prettier_plugin = result
				> 0
		end
	end
end

return M
