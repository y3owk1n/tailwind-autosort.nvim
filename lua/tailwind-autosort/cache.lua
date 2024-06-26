local M = {}

---@class TailwindAutoSort.Cache
---@field prettier_root_dir string|nil|false
---@field has_tw_prettier_plugin boolean|nil
M.cache = {
	prettier_root_dir = nil,
	has_tw_prettier_plugin = nil,
}

M.reset_cache = function()
	M.cache.prettier_root_dir = nil
	M.cache.has_tw_prettier_plugin = nil
end

return M
