---@meta

---@class vim.lsp.Client
---@field name string
---@field request fun(self, method: string, params: any, callback: fun(err, result, ctx, config), bufnr: number?)

---@class TSNode
---@field range fun(self): integer, integer, integer, integer
---@field named_children fun(self): TSNode[]
