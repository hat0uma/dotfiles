local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    config = function()
      require("plugins.treesitter.parser").setup()
      require("nvim-treesitter").setup({})
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(ev)
          local ft = ev.match
          local buf = ev.buf
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end

          local parsers = require("nvim-treesitter.parsers")
          if not parsers[lang] then
            return
          end

          local ok = pcall(vim.treesitter.start, buf, lang)
          if not ok then
            vim.notify(string.format("Failed to attach treesitter parser lang %s", lang))
            return
          end
        end,

        group = vim.api.nvim_create_augroup("rc.treesitter", {}),
      })
    end,
  },
  require("plugins.treesitter.parser").local_parser_packages(),
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter" },
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true

      local function select_textobject(query)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end
      end

      local function swap_next(query)
        return function()
          require("nvim-treesitter-textobjects.swap").swap_next(query)
        end
      end

      local function swap_prev(query)
        return function()
          require("nvim-treesitter-textobjects.swap").swap_previous(query)
        end
      end

      local function goto_next_start(query, group)
        return function()
          require("nvim-treesitter-textobjects.move").goto_next_start(query, group)
        end
      end

      local function goto_next_end(query, group)
        return function()
          require("nvim-treesitter-textobjects.move").goto_next_end(query, group)
        end
      end

      local function goto_prev_start(query, group)
        return function()
          require("nvim-treesitter-textobjects.move").goto_previous_start(query, group)
        end
      end

      local function goto_prev_end(query, group)
        return function()
          require("nvim-treesitter-textobjects.move").goto_previous_end(query, group)
        end
      end

      -- local function goto_next(query, group)
      --   return function()
      --     require("nvim-treesitter-textobjects.move").goto_next(query, group)
      --   end
      -- end
      --
      -- local function goto_prev(query, group)
      --   return function()
      --     require("nvim-treesitter-textobjects.move").goto_previous(query, group)
      --   end
      -- end

      local keymaps = {
        -- Text objects
        { modes = { "x", "o" }, lhs = "af", rhs = select_textobject("@function.outer") },
        { modes = { "x", "o" }, lhs = "if", rhs = select_textobject("@function.inner") },
        { modes = { "x", "o" }, lhs = "ac", rhs = select_textobject("@class.outer") },
        { modes = { "x", "o" }, lhs = "ic", rhs = select_textobject("@class.inner") },
        { modes = { "x", "o" }, lhs = "aa", rhs = select_textobject("@parameter.outer") },
        { modes = { "x", "o" }, lhs = "ia", rhs = select_textobject("@parameter.inner") },
        -- Swap
        { modes = "n", lhs = "swn", rhs = swap_next("@parameter.inner") },
        { modes = "n", lhs = "swp", rhs = swap_prev("@parameter.inner") },
        -- Move to next start
        { modes = { "n", "x", "o" }, lhs = "]m", rhs = goto_next_start("@function.outer", "textobjects") },
        { modes = { "n", "x", "o" }, lhs = "]]", rhs = goto_next_start("@class.outer", "textobjects") },
        {
          modes = { "n", "x", "o" },
          lhs = "]o",
          rhs = goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects"),
        },
        { modes = { "n", "x", "o" }, lhs = "]s", rhs = goto_next_start("@local.scope", "locals") },
        { modes = { "n", "x", "o" }, lhs = "]z", rhs = goto_next_start("@fold", "folds") },
        -- Move to next end
        { modes = { "n", "x", "o" }, lhs = "]M", rhs = goto_next_end("@function.outer", "textobjects") },
        { modes = { "n", "x", "o" }, lhs = "][", rhs = goto_next_end("@class.outer", "textobjects") },
        -- Move to previous start
        { modes = { "n", "x", "o" }, lhs = "[m", rhs = goto_prev_start("@function.outer", "textobjects") },
        { modes = { "n", "x", "o" }, lhs = "[[", rhs = goto_prev_start("@class.outer", "textobjects") },
        -- Move to previous end
        { modes = { "n", "x", "o" }, lhs = "[M", rhs = goto_prev_end("@function.outer", "textobjects") },
        { modes = { "n", "x", "o" }, lhs = "[]", rhs = goto_prev_end("@class.outer", "textobjects") },
        -- Move to nearest
        -- { modes = { "n", "x", "o" }, lhs = "]d", rhs = goto_next("@conditional.outer", "textobjects") },
        -- { modes = { "n", "x", "o" }, lhs = "[d", rhs = goto_prev("@conditional.outer", "textobjects") },
      }

      for _, keymap in ipairs(keymaps) do
        vim.keymap.set(keymap.modes, keymap.lhs, keymap.rhs)
      end
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {},
        move = {},
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
    ft = {
      "typescript",
      "typescriptreact",
      "javascript",
      "javascript",
      "html",
    },
  },
  {
    "nvim-treesitter/playground",
    dependencies = { "nvim-treesitter" },
    cmd = { "TSPlaygroundToggle" },
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("nt-cpp-tools").setup({
        header_extension = "h",
        source_extension = "cpp",
      })
    end,
    cmd = { "TSCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter" },
    config = function()
      vim.g.skip_ts_context_commentstring_module = true
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
    ft = { "typescript", "typescriptreact", "javascript", "javascript" },
  },
}
return M
