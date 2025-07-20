local M = {}

---@brief [[
---*tailwind-autosort.nvim.txt*
---
---Format tailwind classes without `prettier-plugin-tailwindcss` in `class`, `className`, `cn`, `cva`, `clsx` and `twMerge`
---@brief ]]

---@toc tailwind-autosort.nvim.toc

---@mod tailwind-autosort.nvim.api API

---Entry point to setup the plugin
---@type fun(user_config?: TailwindAutoSort.Config)
M.setup = require("tailwind-autosort.config").setup

return M
