-- font
vim.o.guifont = "UDEV Gothic NF,Segoe UI Emoji:h11"
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
