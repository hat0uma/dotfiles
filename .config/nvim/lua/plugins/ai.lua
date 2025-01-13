return {
  {
    "yetone/avante.nvim",
    config = function()
      require("avante").setup({
        provider = "copilot",
      })
    end,
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = {
            -- "markdown",
            "Avante",
          },
        },
        ft = {
          -- "markdown",
          "Avante",
        },
      },
    },
    event = "VeryLazy",
    build = rc.sys.is_windows and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    cond = function()
      return vim.env.ENABLE_NVIM_AI_PLUGINS == "1"
    end,
  },
  {
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
    keys = {
      {
        "<leader>ca",
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
      {
        "<leader>cc",
        function()
          require("CopilotChat").open()
        end,
        mode = { "n", "v" },
        desc = "CopilotChat - open chat",
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
