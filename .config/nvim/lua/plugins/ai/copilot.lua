return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
          accept_word = "<C-k>",
          accept_line = "<C-j>",
          -- next = "<A-]>",
          -- prev = "<A-[>",
          -- dismiss = "<C-]>",
        },
      },
      filetypes = {
        ["*"] = true,
      },
    })
  end,
}
