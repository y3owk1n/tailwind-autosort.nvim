---@module 'luassert'

local lsp_fn = require("tailwind-autosort.lsp")

-- We'll capture log messages here.
local log_msgs = { warn = {}, info = {}, error = {} }

describe("tailwind-autosort.lsp module", function()
	local original_get_clients

	before_each(function()
		-- Reset captured log messages.
		log_msgs.warn = {}
		log_msgs.info = {}
		log_msgs.error = {}

		-- Override the logging module.
		package.loaded["tailwind-autosort.log"] = {
			warn = function(msg)
				table.insert(log_msgs.warn, msg)
			end,
			info = function(msg)
				table.insert(log_msgs.info, msg)
			end,
			error = function(msg)
				table.insert(log_msgs.error, msg)
			end,
		}

		-- Override the file module with no-ops.
		package.loaded["tailwind-autosort.file"] = {
			set_prettier_root = function() end,
			set_prettier_tw_plugin = function() end,
		}

		-- Prepare the cache module.
		package.loaded["tailwind-autosort.cache"] = { cache = {} }

		-- Override treesitter functions with dummy implementations.
		package.loaded["tailwind-autosort.treesitter"] = {
			-- Return one dummy node.
			get_class_nodes = function(bufnr, _)
				return { {} }
			end,
			-- Return a range covering the entire first line of the buffer.
			get_class_range = function(_node, bufnr)
				local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
					or ""
				return 0, 0, 0, #line
			end,
		}

		-- Save original vim.lsp.get_clients to restore later.
		original_get_clients = vim.lsp.get_clients
	end)

	after_each(function()
		-- Clean up overrides.
		package.loaded["tailwind-autosort.log"] = nil
		package.loaded["tailwind-autosort.file"] = nil
		package.loaded["tailwind-autosort.cache"] = nil
		package.loaded["tailwind-autosort.treesitter"] = nil

		vim.lsp.get_clients = original_get_clients
	end)

	describe("get_tw_lsp_client", function()
		it("returns a tailwindcss lsp client if available", function()
			local dummy_client =
				{ name = "tailwindcss", request = function() end }
			vim.lsp.get_clients = function(opts)
				return { dummy_client }
			end

			local client = lsp_fn.get_tw_lsp_client()
			assert.are.equal(dummy_client, client)
		end)

		it(
			"logs a warning and returns nil if no tailwindcss lsp client is available",
			function()
				vim.lsp.get_clients = function(opts)
					return {}
				end

				local client = lsp_fn.get_tw_lsp_client()
				assert.is_nil(client)
				assert.is_true(#log_msgs.warn > 0)
				assert.is_true(
					log_msgs.warn[1]:find(
						"Required tailwind%-language%-server is not running"
					) ~= nil
				)
			end
		)
	end)

	describe("run_sort", function()
		it("aborts if prettier tailwind plugin is installed", function()
			local cache = require("tailwind-autosort.cache").cache
			cache.has_tw_prettier_plugin = true

			local config = { notify_line_changed = true }
			lsp_fn.run_sort(config)
			assert.is_true(#log_msgs.warn > 0)
			assert.is_true(
				log_msgs.warn[1]:find("Has prettier tailwind plugin, abort!")
					~= nil
			)
		end)

		it("aborts if no tailwindcss lsp client is available", function()
			local cache = require("tailwind-autosort.cache").cache
			cache.has_tw_prettier_plugin = false

			vim.lsp.get_clients = function(opts)
				return {} -- simulate no client available
			end

			local config = { notify_line_changed = true }
			lsp_fn.run_sort(config)
			-- Since no client is found, no sorting is performed (and no info log).
			assert.are.equal(0, #log_msgs.info)
		end)

		it("performs sorting when conditions are met", function()
			local cache = require("tailwind-autosort.cache").cache
			cache.has_tw_prettier_plugin = false

			-- Create a new temporary buffer with unsorted class list "b c a".
			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "b c a" })
			vim.api.nvim_set_current_buf(bufnr)

			-- Create a dummy lsp client that simulates a sorting request.
			local dummy_client = {
				name = "tailwindcss",
				request = function(self, method, params, callback, bufnr_arg)
					-- For our test, assume params.classLists = {"b c a"}.
					-- Simulate sorting to "a b c".
					callback(nil, { classLists = { "a b c" } }, nil, nil)
				end,
			}
			vim.lsp.get_clients = function(opts)
				return { dummy_client }
			end

			local config = { notify_line_changed = true }
			lsp_fn.run_sort(config)

			-- run_sort waits until the LSP request callback sets its internal "done" flag.
			-- We wait a little longer than the 1000ms built‐in wait.
			vim.wait(1500, function()
				return true
			end)

			local new_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
			assert.are.equal("a b c", new_line)

			assert.is_true(#log_msgs.info > 0)
			assert.is_true(
				log_msgs.info[1]:find("Tailwind class sorted for 1 lines")
					~= nil
			)

			-- Clean up our temporary buffer.
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end)
	end)
end)
