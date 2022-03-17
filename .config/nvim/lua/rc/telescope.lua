local M = {}
local ignore_globs = {
  ".git",
  ".svn",
  "node_modules",
  "*.meta",
}
local glob_text = "!{" .. table.concat(ignore_globs, ",") .. "}"
local find_command = {
  "rg",
  "--files",
  "--hidden",
  "--glob",
  glob_text,
  "--color=never",
}

local grep_command = {
  "rg",
  "--hidden",
  "--glob",
  glob_text,
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--smart-case",
}
function M.config()
  local actions = require "telescope.actions"
  local layout_actions = require "telescope.actions.layout"
  local my_actions = require "rc.telescope.actions"
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
        },
        n = {
          ["q"] = actions.close,
          ["p"] = layout_actions.toggle_preview,
          ["<C-d>"] = my_actions.shift_selection_pagedown,
          ["<C-u>"] = my_actions.shift_selection_pageup,
        },
      },
      initial_mode = "normal",
      winblend = 10,
      preview = {
        hide_on_startup = true,
      },
      vimgrep_arguments = grep_command,
      path_display = function(_, path)
        return vim.fn.fnamemodify(path, ":p:~:.")
      end,
    },
    pickers = {
      find_files = {
        find_command = find_command,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  }

  -- vim.cmd[[
  --   highlight! default link TelescopeNormal NormalFloat
  --   highlight! default link TelescopePreviewNormal NormalFloat
  -- ]]
end

local function dropdown_theme(entry_maker)
  local theme = require("telescope.themes").get_dropdown {
    border = true,
    layout_config = {
      width = math.floor(vim.o.columns * 0.7),
      height = math.floor(vim.o.lines * 0.7),
    },
  }
  if entry_maker then
    theme.entry_maker = entry_maker
  end

  return theme
end

function M.telescope_oldfiles()
  require("telescope.builtin").oldfiles(
    dropdown_theme(require("rc.telescope.my_make_entry").gen_from_files_prioritize_basename())
  )
end

function M.telescope_find_files()
  require("telescope.builtin").find_files(
    dropdown_theme(require("rc.telescope.my_make_entry").gen_from_files_prioritize_basename())
  )
end

function M.telescope_packers()
  vim.cmd [[ packadd packer.nvim ]]
  require("plugins").init()
  require("telescope").extensions.packer.packer()
end

function M.telescope_live_grep()
  require("telescope").extensions.live_grep_raw.live_grep_raw()
end

function M.telescope_gina_p_action_list()
  require("rc.telescope.my_pickers").gina_p_action_list(require("telescope.themes").get_cursor())
end

function M.setup()
  local opt = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>o", M.telescope_oldfiles, opt)
  vim.keymap.set("n", "<leader>f", M.telescope_find_files, opt)
  vim.keymap.set("n", "<leader>p", M.telescope_packers, opt)
  vim.keymap.set("n", "<leader>g", M.telescope_live_grep, opt)
  aug("my_telescope_aug", {
    au("FileType", {
      pattern = "gina-status",
      callback = function()
        vim.keymap.set("n", "A", M.telescope_gina_p_action_list, { noremap = true, silent = true, buffer = true })
      end,
    }),
  })
end
return M
