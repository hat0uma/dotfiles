vim.o.splitright = true
vim.o.splitbelow = true
vim.o.termguicolors = true
vim.o.updatetime = 100
vim.g.mapleader = " "
vim.g.maplocalleader = " "
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
-- vim.o.scrolloff = 999
vim.o.splitkeep = "screen"
vim.o.sidescrolloff = 16
vim.o.sidescroll = 1
vim.o.wrap = false
vim.o.cursorline = true
-- fold
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.o.foldlevelstart = 99
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

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
vim.o.inccommand = "nosplit"

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
-- vim.o.mousemodel = ""
vim.o.mousefocus = false
-- vim.go.mousehide = false

-- :h 'sessionoptions'
local sessionoptions = {
  "blank", --empty windows
  "buffers", --hidden and unloaded buffers, not just those in windows
  "curdir", --the current directory
  "folds", --manually created folds, opened/closed folds and local fold options
  -- "globals", --global variables that start with an uppercase letter and contain at least one lowercase letter.  Only String and Number types are stored.
  "help", --the help window
  -- "localoptions", --options and mappings local to a window or buffer (not global values for local options)
  -- "options", --all options and mappings (also global values for local options)
  -- "skiprtp", --exclude 'runtimepath' and 'packpath' from the options
  "resize", --size of the Vim window: 'lines' and 'columns'
  -- "sesdir", --the directory in which the session file is located will become the current directory (useful with projects accessed over a network from different systems)
  "tabpages", --all tab pages; without this only the current tab page is restored, so that you can make a session for each tab page separately
  "terminal", --include terminal windows where the command can be restored
  "winpos", --position of the whole Vim window
  "winsize", --window sizes
}

vim.o.sessionoptions = table.concat(sessionoptions, ",")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "vim,lua",
  callback = function()
    -- vim.bo.keywordprg = ":vert help"
    vim.bo.keywordprg = ":abo help"
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function()
    vim.keymap.set("n", "q", "<Cmd>quit<CR>", { noremap = true, silent = true, buffer = true })
  end,
})

-- highlightedyank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlightedyank", {}),
  callback = function()
    vim.highlight.on_yank()
  end,
})
-------------------------------------------------------------------------
-- files
vim.o.fileformats = "unix,dos,mac"
vim.o.fileencodings = "utf-8,cp932,sjis,iso-2022-jp,euc-jp"
vim.g.scriptencoding = "utf-8"
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.api.nvim_create_autocmd("FileType", {
  pattern = "toml,yaml,json,lua,typescript,typescriptreact,javascript,javascriptreact,css,scss",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})
-- disable newline comment
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt.formatoptions:remove("c")
    vim.opt.formatoptions:remove("r")
    vim.opt.formatoptions:remove("o")
  end,
  group = vim.api.nvim_create_augroup("disable_newline_comments", {}),
})
-------------------------------------------------------------------------
-- key settings
if not vim.g.vscode then
  vim.keymap.set("n", "<Leader>w", vim.cmd.write, { noremap = true, silent = true })
  -- vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
  vim.keymap.set("n", "<C-i>", "<C-i>", { noremap = true, silent = true })

  -- abbrevs
  vim.cmd.cabbrev("printt", "vim.print()<Left>")
else
  require("vscode_neovim").setup()
end

-------------------------------------------------------------------------
-- plugins
vim.api.nvim_create_user_command("BufInspect", function()
  local display_ff = { unix = "lf", dos = "crlf", mac = "cr" }
  local f = string.format("fenc=%s,ff=%s,ft=%s", vim.bo.fileencoding, display_ff[vim.bo.fileformat], vim.bo.filetype)
  vim.notify(f)
end, {})

_G.rc = require("rc")

require("config.lazy")

rc.terminal.setup()
rc.winbar.setup()
rc.scratch.setup()
rc.editor.setup()
rc.ambiwidth.setup()
rc.curcenter.setup()
-- rc.git.autofetch.enable()
-- rc.projectrc.setup()

--- Wezterm
local function set_wezterm_user_var(key, value)
  io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, vim.base64.encode(tostring(value))))
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    set_wezterm_user_var("IS_NVIM", true)
  end,
})

-- Reset variable when exiting Neovim
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    set_wezterm_user_var("IS_NVIM", false)
  end,
})
