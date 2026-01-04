-- font
-- vim.o.guifont = "UDEV Gothic,Symbols Nerd Font Mono,Twemoji Mozilla:h11"
vim.o.guifont = "Sarasa Term J,Symbols Nerd Font Mono,Twemoji Mozilla:h11"
vim.o.guifontwide = vim.o.guifont

-- enable mouse
vim.o.mouse = "a"

if vim.g.neovide then
  local group = vim.api.nvim_create_augroup("neovide-setup", {})

  -- set title bar colors
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      local bg = vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg
      vim.g.neovide_title_background_color = string.format("%x", bg)
    end,
  })

  -- toggle fullscreen
  vim.api.nvim_create_user_command("Fullscreen", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, {})
end

---@param count integer
local function increase_font_size(count)
  local guifont_splited = vim.split(vim.o.guifont, ":h")
  local name, size = guifont_splited[1], guifont_splited[2]
  if not size then
    print("not supported. ", vim.o.guifont)
    return
  end
  local next_size = math.ceil(tonumber(size) + count)
  vim.o.guifont = string.format("%s:h%d", name, next_size)
end

vim.api.nvim_create_user_command("FontSizeIncrease", function(opts)
  local count = opts.fargs[1] and tonumber(opts.fargs[1]) or 1
  increase_font_size(count)
end, { nargs = "?" })

vim.keymap.set({ "n", "i" }, "<C-+>", "<Cmd>FontSizeIncrease 1<CR>", { silent = true })
vim.keymap.set({ "n", "i" }, "<C-->", "<Cmd>FontSizeIncrease -1<CR>", { silent = true })
