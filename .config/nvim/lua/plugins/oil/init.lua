local my_actions = require "plugins.oil.my_actions"

return {
  "stevearc/oil.nvim",
  init = function()
    vim.keymap.set("n", "<leader>e", my_actions.open, { desc = "Open current file directory" })
  end,
  config = function()
    require("oil").setup {
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
      default_file_explorer = true,
      delete_to_trash = true,
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = require("oil.actions").show_help,
        ["q"] = my_actions.close,
        ["<leader>e"] = require("oil.actions").close,
        ["L"] = require("oil.actions").select,
        ["H"] = require("oil.actions").parent,
        ["gv"] = my_actions.float_select_vsplit,
        ["gs"] = my_actions.float_select_split,
        ["g."] = require("oil.actions").toggle_hidden,
        ["gp"] = require("oil.actions").preview,
        ["~"] = my_actions.home,
        ["<leader>s"] = my_actions.find,
        ["<leader>x"] = my_actions.open_explorer,
        ["<leader>t"] = my_actions.open_terminal,
        ["<Tab>"] = my_actions.toggle_tab,
        ["g@"] = function()
          require("plugins.telescope.my_pickers").show_paths(require("telescope.themes").get_cursor())
        end,
      },
      float = {
        padding = 2,
        max_width = math.floor(vim.o.columns * 0.7),
        max_height = math.floor(vim.o.lines * 0.7),
        border = "rounded",
        win_options = {
          winblend = 10,
        },
      },
      view_options = {
        show_hidden = true,
      },
    }
  end,
  cmd = { "Oil" },
}
