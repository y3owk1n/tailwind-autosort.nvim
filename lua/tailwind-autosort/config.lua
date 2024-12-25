local M = {}

---@class TailwindAutoSort.Option
---@field autosort_on_save {enabled: boolean, enable_write: boolean, notify_after_save: boolean}
M.options = {
	autosort_on_save = {
		enabled = true,
		enable_write = true,
		notify_after_save = true,
	},
}

return M
