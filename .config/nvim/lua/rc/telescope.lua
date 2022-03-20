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
          ["v"] = actions.file_vsplit,
          ["p"] = layout_actions.toggle_preview,
          ["<C-d>"] = my_actions.shift_selection_pagedown,
          ["<C-u>"] = my_actions.shift_selection_pageup,
        },
      },
      initial_mode = "normal",
      winblend = 10,
      preview = {
        hide_on_startup = false,
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
    preview = {
      hide_on_startup = true,
    },
  }
  if entry_maker then
    theme.entry_maker = entry_maker
  end

  return theme
end

local function telescope_oldfiles()
  require("telescope.builtin").oldfiles(
    dropdown_theme(require("rc.telescope.my_make_entry").gen_from_files_prioritize_basename())
  )
end

local function telescope_find_files()
  require("telescope.builtin").find_files(
    dropdown_theme(require("rc.telescope.my_make_entry").gen_from_files_prioritize_basename())
  )
end

local function telescope_packers()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  vim.cmd [[ packadd packer.nvim ]]
  require("plugins").init()
  require("telescope").extensions.packer.packer {
    attach_mappings = function(prompt_bufnr, map)
      local vsplit_readme = function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd(string.format(":vsplit %s", selection.readme))
      end
      map("n", "v", vsplit_readme)
      return true
    end,
  }
end

local function telescope_live_grep()
  require("telescope").extensions.live_grep_raw.live_grep_raw { preview = { hide_on_startup = true } }
end

local function telescope_gina_p_action_list()
  require("rc.telescope.my_pickers").gina_p_action_list(require("telescope.themes").get_cursor())
end

local function telescope_buffers()
  require("telescope.builtin").buffers()
end

local function on_telescope_prompt()
  local bufnr = vim.fn.bufnr()
  local function buf_au(event, cb)
    return au(event, { callback = cb, buffer = bufnr })
  end
  aug("on_telescope_prompt", {
    buf_au("InsertEnter", function()
      -- require("rc.telescope.actions").disable_preview(bufnr)
    end),
    buf_au("InsertLeave", function()
      -- require("rc.telescope.actions").enable_preview(bufnr)
    end),
  })
end

function M.setup()
  local opt = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>o", telescope_oldfiles, opt)
  vim.keymap.set("n", "<leader>f", telescope_find_files, opt)
  vim.keymap.set("n", "<leader>p", telescope_packers, opt)
  vim.keymap.set("n", "<leader>g", telescope_live_grep, opt)
  vim.keymap.set("n", "<leader>b", telescope_buffers, opt)

  aug("my_telescope_aug", {
    au("FileType", {
      pattern = "gina-status",
      callback = function()
        vim.keymap.set("n", "A", telescope_gina_p_action_list, { noremap = true, silent = true, buffer = true })
      end,
    }),
    au("FileType", { pattern = "TelescopePrompt", callback = on_telescope_prompt }),
  })
end
return M
