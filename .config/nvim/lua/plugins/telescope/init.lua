local IGNORE_GLOBS = {
  ".git",
  ".svn",
  "node_modules",
  "*.meta",
}
local GLOB_TEXT = "!{" .. table.concat(IGNORE_GLOBS, ",") .. "}"
local FIND_COMMAND = {
  "rg",
  "--files",
  "--hidden",
  "--glob",
  GLOB_TEXT,
  "--color=never",
}

local GREP_COMMAND = {
  "rg",
  "--hidden",
  "--glob",
  GLOB_TEXT,
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--smart-case",
}

local function get_dropdown(opts)
  opts = vim.tbl_deep_extend("force", {
    border = true,
    layout_config = {
      width = math.floor(vim.o.columns * 0.7),
      height = math.floor(vim.o.lines * 0.7),
    },
    preview = { hide_on_startup = true },
  }, opts or {})
  return require("telescope.themes").get_dropdown(opts)
end

local M = {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = { "telescope.nvim" },
    build = "make",
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "telescope.nvim" },
  },
  {
    "tsakirist/telescope-lazy.nvim",
    dependencies = { "telescope.nvim" },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      local function telescope_oldfiles()
        require("plugins.telescope.my_pickers").oldfiles(get_dropdown())
      end

      local function telescope_find_files()
        require("telescope.builtin").find_files()
      end

      local function telescope_live_grep()
        require("telescope").extensions.live_grep_args.live_grep_args({ preview = { hide_on_startup = true } })
      end

      local function telescope_buffers()
        require("telescope.builtin").buffers()
      end

      local opt = { noremap = true, silent = true }
      vim.keymap.set("n", "<leader>o", telescope_oldfiles, opt)
      vim.keymap.set("n", "<leader>f", telescope_find_files, opt)
      vim.keymap.set("n", "<leader>p", function()
        require("telescope").extensions.lazy.lazy()
      end, opt)
      vim.keymap.set("n", "<leader>g", telescope_live_grep, opt)
      vim.keymap.set("n", "<leader>b", telescope_buffers, opt)
      vim.keymap.set("n", "<leader>r", "<Cmd>Telescope resume<CR>", opt)
      vim.keymap.set("n", "<leader>P", function()
        require("telescope").extensions.projects.projects({})
      end, opt)
    end,
    config = function()
      local actions = require("telescope.actions")
      local actions_state = require("telescope.actions.state")
      local layout_actions = require("telescope.actions.layout")
      local entry_display = require("telescope.pickers.entry_display")
      local path_displayer = entry_display.create({
        separator = " ",
        items = {
          {}, -- filename
          {}, -- dirname
        },
      })

      require("telescope").setup({
        defaults = {
          prompt_prefix = "   ",
          mappings = {
            i = {
              ["<cr>"] = function()
                vim.cmd([[stopinsert]])
              end,
              ["<BS>"] = function()
                -- prompt + separator
                local col = vim.fn.col(".") - 6
                if col <= 1 then
                  vim.cmd([[stopinsert]])
                else
                  vim.fn.feedkeys("\b")
                end
              end,
              ["<c-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["q"] = actions.close,
              ["gv"] = actions.file_vsplit,
              ["gs"] = actions.file_split,
              ["t"] = actions.file_tab,
              ["p"] = layout_actions.toggle_preview,
              -- ["<C-d>"] = my_actions.shift_selection_pagedown,
              -- ["<C-u>"] = my_actions.shift_selection_pageup,
              ["<c-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<Down>"] = actions.cycle_history_next,
              ["<Up>"] = actions.cycle_history_prev,
            },
          },
          initial_mode = "normal",
          -- winblend = 10,
          preview = {
            hide_on_startup = false,
          },
          vimgrep_arguments = GREP_COMMAND,
          path_display = function(opts, path)
            path = vim.fs.normalize(path)
            if rc.sys.is_windows and rc.path.is_absolute_path(path) then
              path = path:gsub("^%l", string.upper) -- normalize drive letter
            end
            local fname = vim.fs.basename(path)
            local cwd = vim.fs.normalize(assert(vim.uv.cwd()))
            local home = vim.fs.normalize(assert(vim.uv.os_homedir()))
            local dirname = vim.fs.dirname(path):gsub(cwd .. "/", ""):gsub(home, "~")
            return path_displayer({
              fname,
              { dirname, "Comment" },
            })
          end,
        },
        pickers = {
          find_files = get_dropdown({
            find_command = FIND_COMMAND,
          }),
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          lazy = {
            attach_mappings = function(prompt_bufnr, map)
              local vsplit_readme = function()
                local selection = actions_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd.vsplit(selection.value.readme)
              end
              local split_readme = function()
                local selection = actions_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd.split(selection.value.readme)
              end
              map("n", "gv", vsplit_readme)
              map("n", "gs", split_readme)
              return true
            end,
          },
        },
      })
    end,
    cmd = { "Telescope" },
    cond = not vim.g.vscode,
  },
}

return M
