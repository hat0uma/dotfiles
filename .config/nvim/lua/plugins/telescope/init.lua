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
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "telescope.nvim" },
    enabled = false,
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
      local function dropdown_theme(entry_maker)
        local theme = require("telescope.themes").get_dropdown {
          border = true,
          layout_config = {
            width = math.floor(vim.o.columns * 0.7),
            height = math.floor(vim.o.lines * 0.7),
          },
          preview = { hide_on_startup = true },
        }
        if entry_maker then
          theme.entry_maker = entry_maker
        end
        return theme
      end

      local function telescope_oldfiles()
        require("telescope.builtin").oldfiles(
          dropdown_theme(require("plugins.telescope.my_make_entry").gen_from_files_prioritize_basename())
        )
      end

      local function telescope_find_files()
        require("telescope.builtin").find_files(
          dropdown_theme(require("plugins.telescope.my_make_entry").gen_from_files_prioritize_basename())
        )
      end

      local function telescope_live_grep()
        require("telescope").extensions.live_grep_args.live_grep_args { preview = { hide_on_startup = true } }
      end

      local function telescope_gina_p_action_list()
        require("plugins.telescope.my_pickers").gina_action_list(require("telescope.themes").get_cursor())
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
        require("telescope").extensions.projects.projects {}
      end, opt)

      local group = vim.api.nvim_create_augroup("my_telescope_aug", {})
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gina-status",
        callback = function()
          vim.keymap.set("n", "A", telescope_gina_p_action_list, { noremap = true, silent = true, buffer = true })
        end,
        group = group,
      })
    end,
    config = function()
      local actions = require "telescope.actions"
      local actions_state = require "telescope.actions.state"
      local layout_actions = require "telescope.actions.layout"
      require("telescope").setup {
        defaults = {
          prompt_prefix = "   ",
          mappings = {
            i = {
              ["<cr>"] = function()
                vim.cmd [[stopinsert]]
              end,
              ["<BS>"] = function()
                -- prompt + separator
                local col = vim.fn.col "." - 6
                if col <= 1 then
                  vim.cmd [[stopinsert]]
                else
                  vim.fn.feedkeys "\b"
                end
              end,
              ["<c-t>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["q"] = actions.close,
              ["v"] = actions.file_vsplit,
              ["s"] = actions.file_split,
              ["p"] = layout_actions.toggle_preview,
              -- ["<C-d>"] = my_actions.shift_selection_pagedown,
              -- ["<C-u>"] = my_actions.shift_selection_pageup,
              ["<c-t>"] = actions.send_to_qflist + actions.open_qflist,
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
          path_display = function(_, path)
            return vim.fn.fnamemodify(path, ":p:~:.")
          end,
        },
        pickers = {
          find_files = {
            find_command = FIND_COMMAND,
          },
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
                vim.cmd.vsplit(selection.readme)
              end
              map("n", "v", vsplit_readme)
              return true
            end,
          },
        },
      }
    end,
    cmd = { "Telescope" },
  },
}

return M
