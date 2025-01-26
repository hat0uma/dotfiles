local COMMIT_MESSAGE_PROMPT = [[
Write a commit message following the conventional-commit format:

- The title is at most 50 characters.
- The message body is wrapped at 72 characters per line.

Provide two versions:
1. English.
2. <type> and <scope> are in English and other parts are in Japanese.
]]

--- Inspect the commit buffer to determine if it has a commit message and diff
---@param bufnr number
---@return { has_commit_message: boolean, has_commit_diff: boolean }
local function inspect_commit_buf(bufnr)
  local info = { has_commit_message = false, has_commit_diff = false }
  local count = vim.api.nvim_buf_line_count(bufnr)
  for i = 1, count do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if #line ~= 0 and not vim.startswith(line, "#") then
      info.has_commit_message = true
    end
    if vim.startswith(line, "# ------------------------ >8 ------------------------") then
      info.has_commit_diff = true
      return info
    end
  end

  return info
end

local function write_commit_message()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf = inspect_commit_buf(bufnr)
  vim.print(buf)
  if buf.has_commit_message then
    vim.notify("Commit message already exists")
    return
  end

  local config = require("codecompanion.config")
  local context_utils = require("codecompanion.utils.context")
  local context = context_utils.get(bufnr, {})
  require("codecompanion.strategies.inline")
    .new({
      opts = { placement = "before|false" },
      context = context,
      -- prompts = config.prompt_library["Generate a Commit Message"].prompts,
      prompts = {
        {
          role = config.constants.USER_ROLE,
          content = function()
            if buf.has_commit_diff then -- this is useful for commit --amend
              local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              return COMMIT_MESSAGE_PROMPT .. "\n" .. table.concat(lines, "\n")
            end

            local diff = vim.fn.system("git diff --no-ext-diff --staged")
            return string.format("%s\n```diff\n%s\n```", COMMIT_MESSAGE_PROMPT, diff)
          end,
          opts = {
            contains_code = true,
          },
        },
      },
    })
    :start({})
end

return {
  "olimorris/codecompanion.nvim",
  config = function()
    require("codecompanion").setup({
      strategies = {
        inline = {
          -- adapter = "deepseek",
          adapter = "copilot",
          keymaps = {
            accept_change = {
              modes = {
                n = "ga",
              },
              index = 1,
              callback = "keymaps.accept_change",
              description = "Accept change",
            },
            reject_change = {
              modes = {
                n = "gr",
              },
              index = 2,
              callback = "keymaps.reject_change",
              description = "Reject change",
            },
          },
        },
        chat = {
          -- adapter = "deepseek",
          adapter = "copilot",
          slash_commands = {
            ["buffer"] = {
              opts = {
                provider = "telescope", ---@type "default"|"telescope"|"mini_pick"|"fzf_lua"
              },
            },
            ["file"] = {
              opts = {
                provider = "telescope", ---@type "default"|"telescope"|"mini_pick"|"fzf_lua"
              },
            },
          },
          keymaps = {
            options = {
              modes = {
                n = "?",
              },
              callback = "keymaps.options",
              description = "Options",
              hide = true,
            },
            completion = {
              modes = {
                i = "<C-_>",
              },
              index = 1,
              callback = "keymaps.completion",
              description = "Completion Menu",
            },
            send = {
              modes = {
                n = { "<CR>", "<C-s>" },
                i = "<C-s>",
              },
              index = 2,
              callback = "keymaps.send",
              description = "Send",
            },
            regenerate = {
              modes = {
                n = "gr",
              },
              index = 3,
              callback = "keymaps.regenerate",
              description = "Regenerate the last response",
            },
            close = {
              modes = {
                n = "q",
              },
              index = 4,
              callback = "keymaps.close",
              description = "Close Chat",
            },
            stop = {
              modes = {
                n = "<C-c>",
              },
              index = 5,
              callback = "keymaps.stop",
              description = "Stop Request",
            },
            clear = {
              modes = {
                n = "gx",
              },
              index = 6,
              callback = "keymaps.clear",
              description = "Clear Chat",
            },
            codeblock = {
              modes = {
                n = "gc",
              },
              index = 7,
              callback = "keymaps.codeblock",
              description = "Insert Codeblock",
            },
            yank_code = {
              modes = {
                n = "gy",
              },
              index = 8,
              callback = "keymaps.yank_code",
              description = "Yank Code",
            },
            pin = {
              modes = {
                n = "gp",
              },
              index = 9,
              callback = "keymaps.pin_reference",
              description = "Pin Reference",
            },
            watch = {
              modes = {
                n = "gw",
              },
              index = 10,
              callback = "keymaps.toggle_watch",
              description = "Watch Buffer",
            },
            next_chat = {
              modes = {
                n = "}",
              },
              index = 11,
              callback = "keymaps.next_chat",
              description = "Next Chat",
            },
            previous_chat = {
              modes = {
                n = "{",
              },
              index = 12,
              callback = "keymaps.previous_chat",
              description = "Previous Chat",
            },
            next_header = {
              modes = {
                n = "]]",
              },
              index = 13,
              callback = "keymaps.next_header",
              description = "Next Header",
            },
            previous_header = {
              modes = {
                n = "[[",
              },
              index = 14,
              callback = "keymaps.previous_header",
              description = "Previous Header",
            },
            change_adapter = {
              modes = {
                n = "ga",
              },
              index = 15,
              callback = "keymaps.change_adapter",
              description = "Change adapter",
            },
            fold_code = {
              modes = {
                n = "gf",
              },
              index = 15,
              callback = "keymaps.fold_code",
              description = "Fold code",
            },
            debug = {
              modes = {
                n = "gd",
              },
              index = 16,
              callback = "keymaps.debug",
              description = "View debug info",
            },
            system_prompt = {
              modes = {
                n = "gs",
              },
              index = 17,
              callback = "keymaps.toggle_system_prompt",
              description = "Toggle the system prompt",
            },
          },
          opts = {
            register = "+", -- The register to use for yanking code
            yank_jump_delay_ms = 400, -- Delay in milliseconds before jumping back from the yanked code
          },
        },
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = { api_key = "cmd:op read op://Personal/deepseek/credential --no-newline" },
          })
        end,
      },
      display = {
        diff = {
          enabled = true,
          -- provider = "mini_diff",
          provider = "default",
        },
        chat = {
          window = {
            layout = "horizontal", ---@type "float"|"vertical"|"horizontal"|"buffer"
            position = nil, ---@type "left"|"right"|"top"|"bottom"|nil (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
            border = "single",
            height = 0.5,
            width = 0.7,
            relative = "editor",
            opts = {
              breakindent = true,
              cursorcolumn = false,
              cursorline = false,
              foldcolumn = "0",
              linebreak = true,
              list = false,
              number = true,
              numberwidth = 1,
              signcolumn = "no",
              spell = false,
              wrap = true,
            },
          },
        },
      },
    })

    -- Write commit message for git commit
    local group = vim.api.nvim_create_augroup("rc.auto_commit_message", {})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        write_commit_message()
        vim.api.nvim_buf_create_user_command(0, "CodeCompanionCommit", write_commit_message, {})
      end,
      group = group,
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "echasnovski/mini.diff",
      config = function()
        -- require("mini.diff").setup({
        --   -- source = {},
        -- })
      end,
    },
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCmd",
  },
  ft = { "gitcommit" },
  keys = {
    {
      "<leader>ca",
      "<cmd>CodeCompanionActions<CR>",
      mode = { "n" },
    },
    {
      "<leader>cc",
      "<cmd>CodeCompanionChat<CR>",
      mode = { "n" },
    },
    {
      "<leader>ce",
      ":CodeCompanion",
      mode = { "n", "v" },
    },
    {
      "<leader>ct",
      "<cmd>CodeCompanionCmd<CR>",
      mode = { "n" },
    },
  },
}
