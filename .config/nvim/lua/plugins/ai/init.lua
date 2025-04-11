return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    enabled = false,
    config = require("plugins.ai.copilotchat").config,
    cmd = { "CopilotChat", "CopilotChatCommit" },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "echasnovski/mini.diff",
        config = function()
          -- require("mini.diff").setup({
          --   -- source = {},
          -- })
        end,
      },
    },
    config = require("plugins.ai.codecompanion").config,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
    ft = { "gitcommit" },
    keys = {
      { "<leader>ca", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" } },
      { "<leader>cc", "<cmd>CodeCompanionChat<CR>", mode = { "n", "v" } },
      { "<leader>ce", ":CodeCompanion", mode = { "n", "v" } },
      { "<leader>ct", "<cmd>CodeCompanionCmd<CR>", mode = { "n", "v" } },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    cond = function()
      return vim.env.COPILOT_ENABLE == "1"
    end,
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
  },
}
