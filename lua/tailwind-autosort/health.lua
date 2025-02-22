local M = {}

--- Reports a status message using vim.health.
--- Supports boolean values (true for OK, false for error) and string levels ("ok", "warn", "error").
--- @param level "ok"|"warn"|"error" The status level.
--- @param msg string The message to display.
local function report_status(level, msg)
	local health = vim.health or {}
	if level == "ok" then
		health.ok(msg)
	elseif level == "warn" then
		if health.warn then
			health.warn(msg)
		else
			-- Fallback if vim.health.warn isn't defined
			health.ok("WARN: " .. msg)
		end
	elseif level == "error" then
		health.error(msg)
	else
		error("Invalid level: " .. level)
	end
end

--- Prints a separator header for a new section.
--- @param title string The section title.
local function separator(title)
	vim.health.start(title)
end

function M.check()
	-- Neovim Version Check (requires v0.9 or later)
	separator("Neovim Version Check")
	if vim.fn.has("nvim-0.9") == 1 then
		report_status("ok", "Neovim version is sufficient.")
	else
		report_status("error", "Neovim v0.9 or higher is required!")
	end

	-- Dependency Checks
	separator("Dependency Checks")

	-- Check for ripgrep (rg)
	if vim.fn.executable("rg") == 1 then
		report_status("ok", "ripgrep (rg) is installed.")
	else
		report_status(
			"error",
			"ripgrep (rg) is not installed. It is required for searching Tailwind config files."
		)
	end

	-- Check for nvim-treesitter
	local ts_ok, _ = pcall(require, "nvim-treesitter")
	if ts_ok then
		report_status("ok", "nvim-treesitter is available.")
	else
		report_status(
			"warn",
			"nvim-treesitter not found. Class sorting based on Treesitter queries may not work correctly."
		)
	end

	-- Check for tailwindcss-language-server
	if vim.fn.executable("tailwindcss-language-server") == 1 then
		report_status("ok", "tailwindcss-language-server is available.")
	else
		report_status(
			"warn",
			"tailwindcss-language-server not found. For enhanced Tailwind CSS support (autocompletion, diagnostics, etc.), please install it via Mason or your package manager."
		)
	end
end

return M
