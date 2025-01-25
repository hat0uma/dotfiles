return {
  "olimorris/codecompanion.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          -- adapter = "deepseek",
          adapter = "copilot",
        },
        inline = {
          -- adapter = "deepseek",
          adapter = "copilot",
        },
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = { api_key = "cmd:op read op://Personal/deepseek/credential --no-newline" },
          })
        end,
      },
      display = { diff = { provider = "mini_diff" } },
    })
  end,
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCmd",
  },
}
