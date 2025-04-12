local COMMIT_MESSAGE_PROMPT_FORMAT = [[
You are a expert software engineer.
Please generate a commit message following the conventional-commit format:

- The title is at most 50 characters.
- The message body is wrapped at 72 characters per line.

Provide two versions:
1. English.
2. <type> and <scope> are in English and other parts are in Japanese.


Changes to be committed:

```diff
%s
```
]]

--- Inspect the commit buffer to determine if it has a commit message and diff
---@param bufnr number
---@return { has_commit_message: boolean, diff?: string }
local function inspect_commit_buf(bufnr)
  local info = { has_commit_message = false }
  local count = vim.api.nvim_buf_line_count(bufnr)
  for i = 0, count - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
    if #line ~= 0 and not vim.startswith(line, "#") then
      info.has_commit_message = true
    end
    if vim.startswith(line, "# ------------------------ >8 ------------------------") then
      -- [i+1] is # do not modify or remove this line
      -- [i+2] is # Everything below is ignored
      -- [i+3] to end is the diff
      info.diff = table.concat(vim.api.nvim_buf_get_lines(bufnr, i + 3, -1, false), "\n")
      break
    end
  end

  return info
end

local function write_commit_message()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf = inspect_commit_buf(bufnr)
  vim.print({ has_commit_message = buf.has_commit_message, has_diff = buf.diff ~= nil })
  if buf.has_commit_message then
    vim.notify("Commit message already exists")
    return
  end

  local config = require("codecompanion.config")
  local context_utils = require("codecompanion.utils.context")
  local context = context_utils.get(bufnr, {})
  -- require("codecompanion.strategies.inline")
  --   .new({
  --     placement = "before",
  --     context = context,
  --     -- prompts = config.prompt_library["Generate a Commit Message"].prompts,
  --   })
  --   :prompt(COMMIT_MESSAGE_PROMPT .. "\n" .. get_diff(buf, bufnr))

  require("codecompanion").inline({
    args = string.format(COMMIT_MESSAGE_PROMPT_FORMAT, buf.diff or vim.fn.system("git diff --no-ext-diff --staged")),
  })
end

-- local adapter = "copilot"
-- local adapter = "deepseek"
local adapter = "gemini"

return {
  "olimorris/codecompanion.nvim",
  config = function()
    require("codecompanion").setup({
      opts = { language = "Japanese" },
      prompt_library = {
        ["Generate a Commit Message"] = {
          prompts = {
            {
              role = "user",
              content = function()
                local diff = vim.fn.system("git diff --no-ext-diff --staged -U50")
                return string.format(COMMIT_MESSAGE_PROMPT_FORMAT, diff)
              end,
              opts = { contains_code = true },
            },
          },
        },
      },
      strategies = {
        inline = {
          adapter = adapter,
          keymaps = {
            accept_change = {
              modes = { n = "ga" },
              index = 1,
              callback = "keymaps.accept_change",
              description = "Accept change",
            },
            reject_change = {
              modes = { n = "gr" },
              index = 2,
              callback = "keymaps.reject_change",
              description = "Reject change",
            },
          },
        },
        chat = {
          adapter = adapter,
          keymaps = {
            close = {
              modes = { n = "q" },
              index = 4,
              callback = "keymaps.close",
              description = "Close Chat",
            },
          },
          slash_commands = {
            ["buffer"] = {
              opts = {
                provider = "snacks", ---@type "default"|"telescope"|"mini_pick"|"fzf_lua"|"snacks"
              },
            },
            ["file"] = {
              opts = {
                provider = "snacks", ---@type "default"|"telescope"|"mini_pick"|"fzf_lua"|"snacks"
              },
            },
          },
          opts = { register = "+", yank_jump_delay_ms = 400 },
        },
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
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = { api_key = "cmd:op read op://Personal/deepseek/credential --no-newline" },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "GEMINI_API_KEY",
              model = "gemini-2.5-pro-experimental-03-25",
            },
          })
        end,
      },
    })

    -- Write commit message for git commit
    -- local group = vim.api.nvim_create_augroup("rc.auto_commit_message", {})
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "gitcommit",
    --   callback = function()
    --     write_commit_message()
    --     vim.api.nvim_buf_create_user_command(0, "CodeCompanionCommit", write_commit_message, {})
    --   end,
    --   group = group,
    -- })
  end,
}
