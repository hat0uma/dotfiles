local M = {}

--- @class VscodeNeovim
--- @field action fun(name:string,opts?:table) asynchronously executes a vscode command.
--- @field call fun(name:string,opts?:table):any synchronously executes a vscode command.
--- @field on fun(event:string,callback:function) defines a handler for some Nvim UI events.
--- @field has_config fun(name:string | string[]):boolean|boolean[] checks if a vscode setting exists.
--- @field get_config fun(name:string | string[]):unknown|unknown[]: gets a vscode setting value.
--- @field update_config fun(name:string| string[],value :unknown|unknown[],target: "global"|"workspace") sets a vscode setting.
--- @field notify fun(msg:string,level: integer|nil, opts:table|nil) shows a vscode message (see also Nvim's vim.notify).
--- @field to_op fun(function) A helper for map-operator. See code_actions.lua for the usage
--- @field get_status_item fun(id:string) Gets a vscode statusbar item. Properties can be assigned, which magically updates the statusbar item.
--- @field eval fun(code:string,opts?:table,timeout?:number):any evaluate javascript synchronously in vscode and return the result
--- @field eval_async fun(code:string,opts?:table) evaluate javascript asynchronously in vscode
local vscode = require "vscode-neovim"

---@param ... string
---@return function
local function bind_action(...)
  local names = { ... }
  return function()
    for _, name in ipairs(names) do
      vscode.action(name)
    end
  end
end

---@param ... string
---@return function
local function bind_call(...)
  local names = { ... }
  return function()
    for _, name in ipairs(names) do
      vscode.call(name)
    end
  end
end

local function setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- basic commands
  vim.keymap.set("n", "<Leader>w", "<cmd>Write<CR>", opts)
  vim.keymap.set("n", "u", bind_call "undo", opts)
  vim.keymap.set("n", "<C-r>", bind_call "redo", opts)

  -- telescope alternative
  local quickopen = bind_action("workbench.action.quickOpen", "workbench.action.quickOpenSelectNext")
  vim.keymap.set("n", "<leader>o", quickopen, opts)
  vim.keymap.set("n", "<leader>f", quickopen, opts)

  -- lsp
  vim.keymap.set("n", "<leader>rn", bind_action "editor.action.rename", opts)
  vim.keymap.set("n", "gd", bind_action "editor.action.revealDefinition", opts)
  vim.keymap.set("n", "gh", bind_action "editor.action.showHover", opts)
  vim.keymap.set("n", "gr", bind_action "editor.action.goToReferences", opts)
  vim.keymap.set("n", "<leader>a", bind_action "editor.action.quickFix", opts)
end

local function setup_opts()
  vim.notify = vscode.notify
end

function M.setup()
  setup_opts()
  setup_keymaps()
end

return M
