vim.env.NVIM_TESTING = "1"

local deps_dir = vim.fn.getcwd() .. "/.tests/deps"
for _, name in ipairs({ "nvim-treesitter" }) do
	vim.opt.rtp:prepend(deps_dir .. "/" .. name)
end
vim.opt.rtp:prepend(vim.fn.getcwd())

require("tailwind-autosort").setup()
