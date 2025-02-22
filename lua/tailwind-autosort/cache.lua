local M = {}

---@type TailwindAutoSort.Cache
M.cache = {
	prettier_root_dir = nil,
	has_tw_prettier_plugin = nil,
}

M.reset_cache = function()
	M.cache.prettier_root_dir = nil
	M.cache.has_tw_prettier_plugin = nil
end

return M
