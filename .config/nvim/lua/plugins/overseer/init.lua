return {
  "stevearc/overseer.nvim",
  config = function()
    require("overseer").setup {
      strategy = "toggleterm",
      use_shell = false,
      direction = "float",
      auto_scroll = nil,
      close_on_exit = false,
      open_on_start = true,
    }
    require("plugins.overseer.tasks").setup()
  end,
  init = function()
    local opts = { silent = true, noremap = true }
    vim.keymap.set("n", "<leader>0", "<Cmd>OverseerToggle<CR>", opts)
    vim.api.nvim_create_autocmd("Filetype", {
      pattern = "OverseerList",
      callback = function()
        vim.keymap.set("n", "q", "<Cmd>OverseerClose<CR>", { silent = true, noremap = true, buffer = true })
        vim.keymap.set("n", "A", "<Cmd>OverseerRun<CR>", { silent = true, noremap = true, buffer = true })
      end,
      group = vim.api.nvim_create_augroup("my-overseer-settings", {}),
    })
  end,
  cmd = { "OverseerRun", "OverseerToggle" },
}
