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
  local fb_actions = require("telescope").extensions.file_browser.actions
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
      -- file_browser = {
      --   theme = "ivy",
      --   hijack_netrw = true,
      --   mappings = {
      --     ["i"] = {},
      --     ["n"] = {
      --       ["h"] = fb_actions.goto_parent_dir,
      --       ["l"] = require("telescope.actions").select_default,
      --     },
      --   },
      -- },
    },
  }
  if package.loaded.project_nvim then
    require("telescope").load_extension "projects"
  end
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
  require("telescope").extensions.live_grep_args.live_grep_args { preview = { hide_on_startup = true } }
end

local function telescope_gina_p_action_list()
  require("rc.telescope.my_pickers").gina_p_action_list(require("telescope.themes").get_cursor())
end

local function telescope_buffers()
  require("telescope.builtin").buffers()
end

local function on_telescope_prompt()
  local bufnr = vim.fn.bufnr()
  local group = vim.api.nvim_create_augroup("on_telescope_prompt", {})
  vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      -- require("rc.telescope.actions").disable_preview(bufnr)
    end,
    buffer = bufnr,
    group = group,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      -- require("rc.telescope.actions").enable_preview(bufnr)
    end,
    buffer = bufnr,
    group = group,
  })
end

function M.setup()
  local opt = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>o", telescope_oldfiles, opt)
  vim.keymap.set("n", "<leader>f", telescope_find_files, opt)
  vim.keymap.set("n", "<leader>p", telescope_packers, opt)
  vim.keymap.set("n", "<leader>g", telescope_live_grep, opt)
  vim.keymap.set("n", "<leader>b", telescope_buffers, opt)
  -- vim.keymap.set("n", "<space>e", "<Cmd>Telescope file_browser<CR>", opt)
  local group = vim.api.nvim_create_augroup("my_telescope_aug", {})
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "gina-status",
    callback = function()
      vim.keymap.set("n", "A", telescope_gina_p_action_list, { noremap = true, silent = true, buffer = true })
    end,
    group = group,
  })
  vim.api.nvim_create_autocmd(
    "FileType",
    { pattern = "TelescopePrompt", callback = on_telescope_prompt, group = group }
  )
end
return M
