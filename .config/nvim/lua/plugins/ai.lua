return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      local prompts = require("CopilotChat.prompts")
      local config = require("CopilotChat.config")
      local additional_prompt = "For explanations, output in Japanese, but for code and examples, output in English."
      require("CopilotChat").setup({
        system_prompt = prompts.COPILOT_INSTRUCTIONS .. "\nOutput should be in Japanese.\n",
        prompts = {
          CommitStaged = {
            prompt = config.prompts.CommitStaged.prompt
              .. "Output the result in two versions: one in English and one in Japanese, with the title prefix (e.g., feat, fix) in English for both versions.",
          },
          Explain = {
            prompt = config.prompts.Explain.prompt .. additional_prompt,
          },
          Review = {
            prompt = config.prompts.Review.prompt .. "Output in Japanese.",
          },
          Fix = {
            prompt = config.prompts.Fix.prompt .. additional_prompt,
          },
          Optimize = {
            prompt = config.prompts.Optimize.prompt .. additional_prompt,
          },
          Docs = {
            prompt = config.prompts.Docs.prompt,
          },
          Tests = {
            prompt = config.prompts.Tests.prompt .. additional_prompt,
          },
          FixDiagnostic = {
            prompt = config.prompts.FixDiagnostic.prompt .. additional_prompt,
          },
        },
      })
    end,
    cmd = { "CopilotChat", "CopilotChatCommitStaged" },
    keys = {
      {
        "<leader>c",
        function()
          local actions = require("CopilotChat.actions")
          local help_actions = actions.help_actions() or {}
          local prompt_actions = actions.prompt_actions() or {}
          local act = vim.tbl_deep_extend("force", help_actions, prompt_actions)
          require("CopilotChat.integrations.telescope").pick(act)
        end,
        mode = { "n", "v" },
        desc = "CopilotChat - actions",
      },
    },
    cond = function()
      return vim.env.ENABLE_NVIM_AI_PLUGINS == "1"
    end,
  },
  {
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
    cond = function()
      return vim.env.ENABLE_NVIM_AI_PLUGINS == "1"
    end,
  },
}
