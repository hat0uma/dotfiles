return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    local config = require("CopilotChat.config")
    local additional_prompts = {
      Docs = "",
      Review = "Output in Japanese.",
      Commit = "Output the result in two versions: one in English and one in Japanese, with the title prefix (e.g., feat, fix) in English for both versions.",
      Explain = "For explanations, output in Japanese, but for code and examples, output in English.",
      Fix = "For explanations, output in Japanese, but for code and examples, output in English.",
      Optimize = "For explanations, output in Japanese, but for code and examples, output in English.",
      Tests = "For explanations, output in Japanese, but for code and examples, output in English.",
      FixDiagnostic = "For explanations, output in Japanese, but for code and examples, output in English.",
    }

    local prompts = {}
    for key, value in pairs(config.prompts) do
      prompts[key] = { prompt = value.prompt .. (additional_prompts[key] or "") }
    end

    require("CopilotChat").setup({
      system_prompt = require("CopilotChat.prompts").COPILOT_INSTRUCTIONS .. "\nOutput should be in Japanese.\n",
      prompts = prompts,
    })
  end,
  cmd = { "CopilotChat", "CopilotChatCommit" },
  -- keys = {
  --   {
  --     "<leader>ca",
  --     function()
  --       local actions = require("CopilotChat.actions")
  --       local help_actions = actions.help_actions() or {}
  --       local prompt_actions = actions.prompt_actions() or {}
  --       local act = vim.tbl_deep_extend("force", help_actions, prompt_actions)
  --       require("CopilotChat.integrations.telescope").pick(act)
  --     end,
  --     mode = { "n", "v" },
  --     desc = "CopilotChat - actions",
  --   },
  --   {
  --     "<leader>cc",
  --     function()
  --       require("CopilotChat").open()
  --     end,
  --     mode = { "n", "v" },
  --     desc = "CopilotChat - open chat",
  --   },
  -- },
}
