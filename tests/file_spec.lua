---@module 'luassert'

-- tests/tailwind_autosort_spec.lua
-- This test suite is meant to be run in headless Neovim.
--
-- To run with plenary.nvim's test runner, for example:
--   nvim --headless -c 'PlenaryBustedDirectory tests' -c 'qa'

local file_fn = require("tailwind-autosort.file")
local cache = require("tailwind-autosort.cache").cache

-- Helper: create a temporary directory (using vim.fn.tempname and mkdir)
local function create_temp_dir()
	local tmp = vim.fn.tempname()
	vim.fn.mkdir(tmp, "p")
	return tmp
end

describe("tailwind-autosort module integration tests", function()
	local tmp_dir

	before_each(function()
		tmp_dir = create_temp_dir()
		-- Clear the cache before each test.
		cache.prettier_root_dir = nil
		cache.has_tw_prettier_plugin = nil
	end)

	after_each(function()
		-- Recursively delete the temporary directory.
		vim.fn.delete(tmp_dir, "rf")
		vim.cmd("enew")
	end)

	describe("find_root", function()
		it("returns the first found file in an upward search", function()
			-- Create a directory structure:
			--   tmp_dir/
			--     .prettierrc
			--     subdir/
			--       file.txt
			local prettier_path = tmp_dir .. "/.prettierrc"
			local subdir = tmp_dir .. "/subdir"
			vim.fn.mkdir(subdir, "p")
			vim.fn.writefile({}, prettier_path) -- create an empty .prettierrc
			local file_in_subdir = subdir .. "/file.txt"
			vim.fn.writefile({ "dummy content" }, file_in_subdir)

			local ctx = { filename = file_in_subdir }
			local patterns = { ".prettierrc" }
			local found = file_fn.find_root(ctx, patterns)
			assert.are.equal(prettier_path, found)
		end)
	end)

	describe("current_file_path_absolute", function()
		it("returns an absolute path for a given file", function()
			local file = "somefile.txt"
			local abs = file_fn.current_file_path_absolute(file)
			local expected = vim.fn.fnamemodify(file, ":p")
			assert.are.equal(expected, abs)
		end)
	end)

	describe("find_text_in_file", function()
		it("returns a count > 0 when the text is found in the file", function()
			-- Create a file containing the text within quotes.
			local test_file = tmp_dir .. "/test.txt"
			local content = {
				'This file contains "prettier-plugin-tailwindcss" in quotes.',
			}
			vim.fn.writefile(content, test_file)
			local count = file_fn.find_text_in_file(
				"prettier-plugin-tailwindcss",
				test_file
			)
			assert.is_true(count > 0)
		end)

		it("returns 0 when the text is not found", function()
			local test_file = tmp_dir .. "/test.txt"
			local content = { "This file does not have the expected text." }
			vim.fn.writefile(content, test_file)
			local count = file_fn.find_text_in_file(
				"prettier-plugin-tailwindcss",
				test_file
			)
			assert.are.equal(0, count)
		end)
	end)

	describe("set_prettier_root", function()
		it(
			"sets cache.prettier_root_dir to false if no prettier file is found",
			function()
				-- Create a file that does not have any prettier config in its parent directories.
				local file_path = tmp_dir .. "/file.txt"
				vim.fn.writefile({ "dummy content" }, file_path)
				vim.cmd("edit " .. file_path) -- make this the current buffer
				file_fn.set_prettier_root()
				assert.are.equal(false, cache.prettier_root_dir)
			end
		)

		it(
			"sets cache.prettier_root_dir when a prettier file is found",
			function()
				-- Create a directory structure where a prettier config exists:
				--   tmp_dir/
				--     .prettierrc
				--     subdir/
				--       file.txt
				local prettier_path = tmp_dir .. "/.prettierrc"
				vim.fn.writefile({}, prettier_path)
				local subdir = tmp_dir .. "/subdir"
				vim.fn.mkdir(subdir, "p")
				local file_path = subdir .. "/file.txt"
				vim.fn.writefile({ "dummy content" }, file_path)
				vim.cmd("edit " .. file_path) -- open file as current buffer

				file_fn.set_prettier_root()
				local expected =
					file_fn.current_file_path_absolute(prettier_path)
				assert.are.equal(expected, cache.prettier_root_dir)
			end
		)
	end)

	describe("set_prettier_tw_plugin", function()
		it(
			"sets cache.has_tw_prettier_plugin to true if plugin text is found",
			function()
				-- Create a temporary file that contains the plugin text.
				local test_file = tmp_dir .. "/plugin.txt"
				local content = {
					'This file contains "prettier-plugin-tailwindcss" inside.',
				}
				vim.fn.writefile(content, test_file)
				cache.prettier_root_dir = test_file
				file_fn.set_prettier_tw_plugin()
				assert.is_true(cache.has_tw_prettier_plugin)
			end
		)

		it(
			"sets cache.has_tw_prettier_plugin to false if plugin text is not found",
			function()
				local test_file = tmp_dir .. "/plugin.txt"
				local content = { "This file does not mention the plugin." }
				vim.fn.writefile(content, test_file)
				cache.prettier_root_dir = test_file
				file_fn.set_prettier_tw_plugin()
				assert.is_false(cache.has_tw_prettier_plugin)
			end
		)
	end)
end)
