local M = {}

---@brief [[
---*tailwind-autosort.nvim.txt*
---
---Keep all your notes, todos, and journals inside Neovim without ever leaving the editor.
---@brief ]]

---@toc tailwind-autosort.nvim.toc

---@mod tailwind-autosort.nvim.api API

---Entry point to setup the plugin
---@type fun(user_config?: TailwindAutoSort.Config)
M.setup = require("tailwind-autosort.config").setup

return M
