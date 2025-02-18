return {
  "stevearc/oil.nvim",
  init = function()
    vim.keymap.set("n", "<leader>e", require("plugins.oil.util").open, { desc = "Open current file directory" })
  end,
  cond = not vim.g.vscode,
  config = function()
    local contextmenu = require("plugins.oil.contextmenu")
    local history = require("plugins.oil.history")
    local my_actions = require("plugins.oil.actions")

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
        ["<leader>e"] = require("oil.actions").close,
        ["<leader>s"] = my_actions.back_first_opened,
        ["H"] = require("oil.actions").parent,
        ["L"] = require("oil.actions").select,
        ["g."] = require("oil.actions").toggle_hidden,
        ["g?"] = require("oil.actions").show_help,
        ["g@"] = my_actions.select_open_stdpaths,
        ["gp"] = require("oil.actions").preview,
        ["gi"] = my_actions.preview_image,
        ["gs"] = my_actions.float_select_split,
        ["gv"] = my_actions.float_select_vsplit,
        ["gy"] = require("oil.actions").copy_entry_path,
        ["q"] = my_actions.close,
        ["~"] = my_actions.home,
        ["-"] = history.select,
        ["<C-o>"] = history.back,
        ["<C-i>"] = history.forward,
        ["<CR>"] = contextmenu.open,
        ["<Tab>"] = my_actions.toggle_tab,
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
    contextmenu.setup()
    history.setup()
  end,
  cmd = { "Oil" },
}
