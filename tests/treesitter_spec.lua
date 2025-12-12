---@module 'luassert'

local treesitter_fn = require("tailwind-autosort.treesitter")

-- Save original functions so we can restore them.
local original_query_get = vim.treesitter.query.get
local original_get_node_text = vim.treesitter.get_node_text
local original_get_parser = vim.treesitter.get_parser
	or require("nvim-treesitter.parsers").get_parser
local original_version = vim.version

describe("tailwind-autosort.treesitter", function()
	local created_bufs = {}

	before_each(function()
		created_bufs = {}
		-- Override vim.treesitter.query.get to return a dummy query for our supported names.
		vim.treesitter.query.get = function(lang, query_name)
			if
				query_name == "class"
				or query_name == "cva"
				or query_name == "cn"
			then
				return {
					captures = { [1] = "tailwind" },
					iter_captures = function(self, root, bufnr, start, stop)
						local yielded = false
						return function()
							if not yielded then
								yielded = true
								-- Return id 1 and a dummy node.
								return 1, { dummy = true }
							else
								return nil
							end
						end
					end,
				}
			else
				return nil
			end
		end

		-- Override vim.treesitter.get_node_text: use node.text if available.
		vim.treesitter.get_node_text = function(node, bufnr)
			return node.text or ""
		end
	end)

	after_each(function()
		vim.treesitter.query.get = original_query_get
		vim.treesitter.get_node_text = original_get_node_text
		require("nvim-treesitter.parsers").get_parser = original_get_parser
		vim.version = original_version
		-- Clean up any buffers created.
		for _, bufnr in ipairs(created_bufs) do
			if vim.api.nvim_buf_is_valid(bufnr) then
				pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
			end
		end
	end)

	describe("get_class_nodes", function()
		it("returns nil when the buffer filetype is not supported", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			table.insert(created_bufs, bufnr)
			vim.bo[bufnr].ft = "python" -- unsupported filetype
			local results = treesitter_fn.get_class_nodes(bufnr)
			assert.is_nil(results)
		end)

		it("warns and returns nil when no parser is available", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			table.insert(created_bufs, bufnr)
			vim.bo[bufnr].ft = "css"
			-- Override get_parser to simulate no parser available.
			local parser = vim.treesitter.get_parser
				or require("nvim-treesitter.parsers").get_parser
			require("nvim-treesitter.parsers").get_parser = function(buf)
				return nil
			end
			vim.treesitter.get_parser = function(buf)
				return nil
			end

			local warned = false
			package.loaded["tailwind-autosort.log"] = {
				warn = function(msg)
					warned = true
				end,
			}
			local results = treesitter_fn.get_class_nodes(bufnr)
			assert.is_true(warned)
			assert.is_nil(results)
		end)

		it("returns nodes when parser and query are available", function()
			local bufnr = vim.api.nvim_create_buf(false, true)
			table.insert(created_bufs, bufnr)
			vim.bo[bufnr].ft = "javascriptreact"
			-- Create a dummy parser that calls the callback with a dummy tree.
			local dummy_tree = {
				root = function()
					return {} -- dummy root node
				end,
			}
			local dummy_lang_tree = {
				lang = function()
					return "javascriptreact"
				end,
			}
			local dummy_parser = {
				for_each_tree = function(self, callback)
					callback(dummy_tree, dummy_lang_tree)
				end,
				parse = function(self, force)
					-- no-op for this test
				end,
			}
			require("nvim-treesitter.parsers").get_parser = function(buf)
				return dummy_parser
			end
			vim.treesitter.get_parser = function(buf)
				return dummy_parser
			end

			local results = treesitter_fn.get_class_nodes(bufnr, false)
			assert.is_table(results)
			assert.are.equal(3, #results)
			---@diagnostic disable-next-line: need-check-nil
			local node = results[1]
			assert.is_table(node)
			assert.is_true(node.dummy)
		end)

		it(
			"calls parser:parse(true) when 'all' is true and vim.version().minor == 10",
			function()
				local bufnr = vim.api.nvim_create_buf(false, true)
				table.insert(created_bufs, bufnr)
				vim.bo[bufnr].ft = "css"
				local parse_called = false
				local dummy_tree = {
					root = function()
						return {}
					end,
				}
				local dummy_lang_tree = {
					lang = function()
						return "css"
					end,
				}
				local dummy_parser = {
					for_each_tree = function(self, callback)
						callback(dummy_tree, dummy_lang_tree)
					end,
					parse = function(self, force)
						if force then
							parse_called = true
						end
					end,
				}
				require("nvim-treesitter.parsers").get_parser = function(buf)
					return dummy_parser
				end
				vim.treesitter.get_parser = function(buf)
					return dummy_parser
				end

				-- Override vim.version to simulate minor version 10.
				vim.version = function()
					return { minor = 10 }
				end

				treesitter_fn.get_class_nodes(bufnr, true)
				assert.is_true(parse_called)
			end
		)
	end)

	describe("get_class_range", function()
		it("returns the original range if no special case applies", function()
			-- Create a dummy node with a range method and no children.
			local dummy_node = {
				range = function(self)
					return 1, 2, 3, 4
				end,
				named_children = function(self)
					return {}
				end,
			}
			local sr, sc, er, ec = treesitter_fn.get_class_range(dummy_node, 1)
			assert.are.equal(1, sr)
			assert.are.equal(2, sc)
			assert.are.equal(3, er)
			assert.are.equal(4, ec)
		end)

		it(
			"returns modified range if the first child's text is '@apply'",
			function()
				-- Create dummy child nodes.
				local child1 = {
					text = "@apply", -- triggers special case
					range = function()
						return 0, 0, 0, 0
					end,
					named_children = function()
						return {}
					end,
				}
				local child2 = {
					range = function()
						return 10, 0, 10, 5
					end,
					named_children = function()
						return {}
					end,
				}
				local child3 = {
					range = function()
						return 10, 0, 10, 15
					end,
					named_children = function()
						return {}
					end,
				}
				-- Create a dummy node whose named_children returns our children.
				local dummy_node = {
					range = function(self)
						return 1, 2, 3, 4 -- original range; will be replaced
					end,
					named_children = function(self)
						return { child1, child2, child3 }
					end,
				}
				local sr, sc, er, ec =
					treesitter_fn.get_class_range(dummy_node, 1)
				-- Expect start from child2 and end from child3.
				assert.are.equal(10, sr)
				assert.are.equal(0, sc)
				assert.are.equal(10, er)
				assert.are.equal(15, ec)
			end
		)
	end)
end)
