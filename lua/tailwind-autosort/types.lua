---@mod tailwind-autosort.nvim.types Types

local M = {}

---@class TailwindAutoSort.Config
---@field enable_autocmd? boolean
---@field notify_line_changed? boolean

---@class TailwindAutoSort.Cache
---@field prettier_root_dir string|nil|false
---@field has_tw_prettier_plugin boolean|nil

return M
