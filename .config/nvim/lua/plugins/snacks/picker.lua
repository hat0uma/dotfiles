---@param current_bufnr number
---@return snacks.picker.Item[]
local function oldfiles(current_bufnr)
  local current_file = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(current_bufnr))
  local results = {} ---@type snacks.picker.Item[]

  local in_results = function(file)
    return vim.tbl_contains(results, function(v)
      return v.file == file
    end, { predicate = true })
  end

  -- get all buffers
  local bufnrs = vim.api.nvim_list_bufs()
  table.sort(bufnrs, function(a, b)
    return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
  end)
  for _, bufnr in ipairs(bufnrs) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local buf_stats = vim.api.nvim__buf_stats(bufnr)
    local open_by_lsp = buf_stats.current_lnum == 0
    local file = vim.uv.fs_realpath(bufname)

    if not open_by_lsp and file and bufnr ~= current_bufnr then
      table.insert(results, {
        file = file,
        idx = #results + 1,
        score = 0,
        text = file,
      })
    end
  end

  -- get all oldfiles
  for _, file in ipairs(vim.v.oldfiles) do
    local path = vim.uv.fs_realpath(file)
    if path and not in_results(path) and path ~= current_file then
      table.insert(results, {
        file = path,
        idx = #results + 1,
        score = 0,
        text = path,
      })
    end
  end

  return results
end

return {
  init = function()
    local nmaps = {
      {
        "<leader>o",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          require("snacks").picker.pick({
            finder = function(opts, ctx)
              return oldfiles(bufnr)
            end,
            -- multi = {
            --   {
            --     finder = function(opts, ctx)
            --       return oldfiles(bufnr)
            --     end,
            --   },
            --   "files",
            -- },
            title = "Oldfiles",
            preview = "file",
            format = "file",
          })
        end,
      },
      {
        "<leader>f",
        function()
          require("snacks").picker.files()
        end,
      },
      {
        "<leader>p",
        function()
          require("telescope").extensions.lazy.lazy()
        end,
      },
      {
        "<leader>g",
        function()
          require("snacks").picker.grep()
        end,
      },
      {
        "<leader>b",
        function()
          require("snacks").picker.buffers()
        end,
      },
      {
        "<leader>r",
        function()
          require("snacks").picker.resume()
        end,
      },
      {
        "<leader>P",
        function()
          require("telescope").extensions.projects.projects({})
        end,
      },
      {
        "<leader>:",
        function()
          require("snacks").picker.command_history()
        end,
      },
    }
    for _, map in ipairs(nmaps) do
      vim.keymap.set("n", map[1], map[2], {
        silent = true,
        noremap = true,
      })
    end
  end,

  ---@type snacks.picker.Config?|{}
  opts = {
    ui_select = true,
    on_show = function(picker)
      vim.cmd.stopinsert()
      picker:toggle_preview(false)
      picker:action("toggle_hidden")
    end,
    formatters = {
      file = {
        filename_first = true,
      },
    },
    sources = {
      smart = {
        multi = {
          "buffers",
          "recent",
          -- "files",
        },
        matcher = {
          file_pos = true,
          cwd_bonus = false,
          frecency = false,
        },
      },
    },
    actions = {
      enter = function(picker, item)
        if vim.api.nvim_get_mode().mode == "i" then
          vim.cmd.stopinsert()
        else
          picker:action("confirm")
        end
      end,
      backspace = function(picker, item)
        local col = vim.fn.col(".")
        if col <= 1 then
          vim.cmd.stopinsert()
        else
          vim.fn.feedkeys("\b")
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "enter", mode = { "n", "i" } },
          ["<BS>"] = { "backspace", mode = { "i" } },
          ["p"] = { "toggle_preview", mode = { "n" } },
        },
      },
    },
  },
}
