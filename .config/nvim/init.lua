pcall(require, "impatient")

--- define augroup with autocmd
---@param name string aurgoup name
---@param autocmds autocmd[]
---@param opts? table augroup options
function _G.aug(name, autocmds, opts)
  vim.api.nvim_create_augroup(name, opts or {})
  for _, autocmd in pairs(autocmds) do
    autocmd.define(name)
  end
end

--- define autocmd
---@param event string event
---@param opts table autocmd options
---@return autocmd
function _G.au(event, opts)
  --- @class autocmd
  --- @field define fun(group:string)
  local _au = {}
  _au.define = function(augroup)
    if augroup ~= nil then
      opts.group = augroup
    end
    vim.api.nvim_create_autocmd(event, opts)
  end
  return _au
end

vim.o.splitright = true
vim.o.termguicolors = true
vim.o.updatetime = 100
vim.g.mapleader = " "
vim.o.signcolumn = "yes"
vim.o.helplang = "ja,en"
vim.o.number = true
vim.o.relativenumber = true
vim.o.laststatus = 3
vim.o.cmdheight = 1
vim.o.showmatch = true
vim.o.helpheight = 999
vim.o.list = true
vim.o.hls = true
vim.o.showmode = false
vim.opt.listchars = {
  space = "⋅",
  trail = "⋅",
  eol = "↲",
  extends = "❯",
  precedes = "❮",
  tab = "▸ ",
}

vim.opt.backspace = { "indent", "eol", "start" }
vim.o.whichwrap = "b,s,h,l,<,>,[,]"
vim.o.scrolloff = 999
vim.o.sidescrolloff = 16
vim.o.sidescroll = 1
vim.o.wrap = false
-- fold
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevelstart = 99

-- files
vim.o.confirm = true
vim.o.hidden = true
vim.o.autoread = true
vim.o.backup = false
vim.o.swapfile = false

-- replace / search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = true
vim.o.gdefault = true
vim.o.inccommand = "split"

-- vim.o.shellslash = true

-- commandline
vim.o.wildoptions = "pum"
vim.o.history = 10000

-- disable sound
vim.o.visualbell = false
vim.o.errorbells = false

-- diff settings
vim.g.DiffExpr = 0
vim.o.diffopt = "vertical,internal,filler,algorithm:histogram,indent-heuristic"

-- gui settings
vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait100-blinkoff450-blinkon450-Cursor/lCursor"
  .. ",sm:block-blinkwait175-blinkoff250-blinkon400P"
vim.o.ambiwidth = "single"
vim.o.mouse = ""
vim.o.mousemodel = ""
vim.o.mousefocus = false
-- vim.go.mousehide = false

vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1
-- vim.g.did_load_filetypes = 0
-- vim.g.do_filetype_lua = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1
-------------------------------------------------------------------------
-- files
vim.o.fileformats = "unix,dos,mac"
vim.o.fileencodings = "utf-8,sjis,iso-2022-jp,euc-jp"
vim.g.scriptencoding = "utf-8"
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.api.nvim_create_autocmd("FileType", {
  pattern = "toml",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

-------------------------------------------------------------------------
-- key settings
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "<Up>", "<Cmd>wincmd +<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "<Cmd>wincmd -<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "<Cmd>wincmd ><CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "<Cmd>wincmd <<CR>", { noremap = true, silent = true })

-------------------------------------------------------------------------
-- plugins
vim.cmd [[command! PackerInstall packadd packer.nvim | lua require'plugins'.install()]]
vim.cmd [[command! PackerUpdate packadd packer.nvim | lua require'plugins'.update()]]
vim.cmd [[command! PackerSync packadd packer.nvim | lua require'plugins'.sync()]]
vim.cmd [[command! PackerClean packadd packer.nvim | lua require'plugins'.clean()]]
vim.cmd [[command! -nargs=* PackerCompile packadd packer.nvim | lua require'plugins'.compile(<q-args>)]]
vim.cmd [[command! PackerProfile lua require('plugins').profile_output()]]
