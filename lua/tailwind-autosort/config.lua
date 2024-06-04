local M = {}

---@class TailwindAutoSort.Option
---@field autosort_on_save {enabled: boolean, notify_after_save: boolean}
M.options = {
	autosort_on_save = {
		enabled = true,
		notify_after_save = true,
	},
}

return M
