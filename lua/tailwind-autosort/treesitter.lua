local M = {}

local parsers = require("nvim-treesitter.parsers")
local log = require("tailwind-autosort.log")

local supported_filetypes = {
	"javascriptreact",
	"typescriptreact",
}

---@param bufnr number
---@param all boolean?
M.get_class_nodes = function(bufnr, all)
	local ft = vim.bo[bufnr].ft
	local filetypes = vim.tbl_extend("keep", {}, supported_filetypes)
	local results = {}

	if not vim.tbl_contains(filetypes, ft) then
		return
	end

	local parser = parsers.get_parser(bufnr)

	if not parser then
		local message = string.format("No parser available for %s", ft)
		return log.warn(message)
	end

	if all and vim.version().minor == 10 then
		parser:parse(true)
	end

	parser:for_each_tree(function(tree, lang_tree)
		local root = tree:root()
		local lang = lang_tree:lang()

		local queries = { "class", "cva", "cn" }

		local class_table = {
			tailwind = true,
			cva_class = true,
			variant_class = true,
			cn_class = true,
		}

		for _, query_name in ipairs(queries) do
			local query = vim.treesitter.query.get(lang, query_name)

			if query then
				for id, node in
					query:iter_captures(root, bufnr, 0, -1, { all = true })
				do
					if class_table[query.captures[id]] then
						results[#results + 1] = node
					end
				end
			end
		end
	end)

	return results
end

---@param node TSNode
---@param bufnr number
M.get_class_range = function(node, bufnr)
	local start_row, start_col, end_row, end_col = node:range()
	local children = node:named_children()

	-- A special case for extracting postcss class range
	if
		children[1]
		and vim.treesitter.get_node_text(children[1], bufnr) == "@apply"
	then
		start_row, start_col, _, _ = children[2]:range()
		_, _, end_row, end_col = children[#children]:range()
	end

	return start_row, start_col, end_row, end_col
end

return M
