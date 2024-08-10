local my_actions = require("plugins.oil.my_actions")

return {
  "stevearc/oil.nvim",
  init = function()
    vim.keymap.set("n", "<leader>e", my_actions.open, { desc = "Open current file directory" })
  end,
  cond = not vim.g.vscode,
  config = function()
    require("oil").setup({
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
        ["<Tab>"] = my_actions.toggle_tab,
        ["<leader>e"] = require("oil.actions").close,
        ["<leader>s"] = my_actions.find,
        ["<leader>t"] = my_actions.open_terminal,
        ["<leader>x"] = my_actions.open_explorer,
        ["H"] = require("oil.actions").parent,
        ["L"] = require("oil.actions").select,
        ["g."] = require("oil.actions").toggle_hidden,
        ["g?"] = require("oil.actions").show_help,
        ["g@"] = function()
          require("plugins.telescope.my_pickers").show_paths(require("telescope.themes").get_cursor())
        end,
        ["gp"] = require("oil.actions").preview,
        ["gs"] = my_actions.float_select_split,
        ["gv"] = my_actions.float_select_vsplit,
        ["gy"] = require("oil.actions").copy_entry_path,
        ["q"] = my_actions.close,
        ["~"] = my_actions.home,
        ["<CR>"] = require("plugins.oil.contextmenu").open,
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
    })
  end,
  cmd = { "Oil" },
}
