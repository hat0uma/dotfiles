vim.o.splitright = true
vim.o.splitbelow = true
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
-- vim.o.helpheight = 999
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
vim.o.splitkeep = "screen"
vim.o.sidescrolloff = 16
vim.o.sidescroll = 1
vim.o.wrap = false
vim.o.cursorline = true
-- fold
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.o.foldlevelstart = 99

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "vim,lua",
  callback = function()
    -- vim.bo.keywordprg = ":vert help"
    vim.bo.keywordprg = ":abo help"
  end,
})

-- load workspace config
-- .nvim.lua, .nvimrc, and .exrc
vim.o.exrc = false
-------------------------------------------------------------------------
-- files
vim.o.fileformats = "unix,dos,mac"
vim.o.fileencodings = "utf-8,sjis,iso-2022-jp,euc-jp"
vim.g.scriptencoding = "utf-8"
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.api.nvim_create_autocmd("FileType", {
  pattern = "toml,yaml,json,lua,typescript,typescriptreact,javascript,javascriptreact,css",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})
-------------------------------------------------------------------------
-- key settings
vim.keymap.set("n", "<Leader>w", vim.cmd.write, { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-- abbrevs
vim.cmd.cabbrev("printt", "vim.pretty_print()<Left>")

-------------------------------------------------------------------------
-- plugins
require "config.lazy"
require("rc.terminal").setup()

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
if vim.env.NVIM_RESTART_ENABLE then
  local session_dir = vim.fn.stdpath "data" .. "/sessions"
  local session_path = session_dir .. "/last.vim"

  vim.api.nvim_create_user_command("Restart", function()
    local group = vim.api.nvim_create_augroup("my_restart_settings", {})
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function()
        if vim.fn.isdirectory(session_dir) ~= 1 then
          vim.loop.fs_mkdir(session_dir, 493) -- 755
        end
        vim.cmd.mksession { session_path, bang = true }
      end,
      group = group,
    })
    vim.cmd.cquit()
  end, {})
  vim.api.nvim_create_user_command("RestoreSession", function()
    vim.cmd.source(session_path)
  end, {})
end
