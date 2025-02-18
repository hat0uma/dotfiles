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

---@param dir string
---@param files string[]
---@return string?
local function find(dir, files)
  for _, file in ipairs(files) do
    local path = vim.fs.joinpath(dir, file)
    if vim.uv.fs_access(path, "R") then
      return path
    end
  end
end

--- Find a vimdoc file in a directory
---@param plugin_dir string
---@return string?
local function find_vimdoc(plugin_dir)
  local doc_dir = vim.fs.joinpath(plugin_dir, "doc")
  if vim.fn.isdirectory(doc_dir) == 0 then
    return nil
  end

  for name, type in vim.fs.dir(doc_dir, {}) do
    if type == "file" and (name:match("%.txt$") or name:match("%.jax$")) then
      return vim.fs.joinpath(doc_dir, name)
    end
  end

  return nil
end

---@param opts snacks.picker.Config
---@param ctx snacks.picker.finder.ctx
---@return snacks.picker.Item[]
local function lazy_plugins(opts, ctx)
  local results = {} ---@type snacks.picker.Item[]
  local plugins = require("lazy").plugins()

  for _, plugin in ipairs(plugins) do
    table.insert(results, {
      file = find(plugin.dir, { "README.md", "README.mkd" }) or find_vimdoc(plugin.dir),
      idx = #results + 1,
      score = 0,
      text = plugin.name,
    })
    if not results[#results].file then
      print(plugin.name, " has no documents.")
    end
  end

  return results
end

---@param dir string
---@return fun(opts:snacks.picker.Config, ctx: snacks.picker.finder.ctx):snacks.picker.finder.result
local function repos(dir)
  local patterns = { "^%.git$", "^%.svn$", "^.*%.sln$" }
  dir = vim.fs.normalize(dir)

  --- Check dir is repos
  ---@param path string
  ---@return boolean
  local function is_repos(path)
    for child_name, _ in vim.fs.dir(path) do
      for _, pattern in ipairs(patterns) do
        if child_name:match(pattern) then
          return true
        end
      end
    end
    return false
  end

  return function(opts, ctx)
    local results = {} ---@type snacks.picker.Item[]
    if vim.fn.isdirectory(dir) == 0 then
      return results
    end

    for name, type in vim.fs.dir(dir) do
      local path = vim.fs.joinpath(dir, name)
      if type == "directory" and is_repos(path) then
        table.insert(results, { file = path, idx = #results + 1, score = 0, text = path })
      end
    end

    return results
  end
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
            layout = {
              preview = { enabled = false },
            },
            preview = "file",
            format = "file",
          })
        end,
      },
      {
        "<leader>f",
        function()
          require("snacks").picker.files({
            layout = {
              preview = { enabled = false },
            },
          })
        end,
      },
      {
        "<leader>P",
        function()
          ---@param category string
          ---@param icon? string
          ---@param icon_hl? string
          ---@return snacks.picker.format
          local function text_with_icon(category, icon, icon_hl)
            return function(item, picker)
              local ret = {}
              table.insert(ret, { icon or "", icon_hl or "SpecialChar" })
              table.insert(ret, { " " })
              table.insert(ret, { Snacks.picker.util.align(vim.fs.basename(item.text), 30) })
              table.insert(ret, { " " })
              table.insert(ret, { category, "Comment" })
              return ret
            end
          end

          require("snacks").picker.pick({
            title = "Repos",
            preview = "file",
            multi = {
              {
                finder = lazy_plugins,
                format = text_with_icon("plugin", "💤", "NoTexthl"),
              },
              {
                finder = repos("~/Unity/Projects"),
                format = text_with_icon("~/Unity/Projects", " ", "NoTexthl"),
              },
              {
                finder = repos("~/source/repos"),
                format = text_with_icon("~/source/repos", "󰘐 ", "NoTexthl"),
              },
              -- {
              --   source = "projects",
              --   format = function(item, picker)
              --     local repo_name ---@type string
              --     local find_root ---@type string
              --     if vim.tbl_contains(project_patterns, vim.fs.basename(item.file)) then -- marker
              --       local repo_path = vim.fs.dirname(item.file)
              --       find_root = vim.fs.dirname(repo_path)
              --       repo_name = vim.fs.basename(repo_path)
              --     else
              --       find_root = vim.fs.dirname(item.file)
              --       repo_name = vim.fs.basename(item.file)
              --     end
              --
              --     local cwd = vim.fs.normalize(assert(vim.uv.cwd()))
              --     local home = vim.fs.normalize(assert(vim.uv.os_homedir()))
              --     local dirname = vim.fs.dirname(find_root):gsub(cwd .. "/", ""):gsub(home, "~")
              --
              --     local ret = {}
              --     table.insert(ret, { "", "SpecialChar" })
              --     table.insert(ret, { " " })
              --     table.insert(ret, { Snacks.picker.util.align(repo_name, 30) })
              --     table.insert(ret, { " " })
              --     table.insert(ret, { dirname, "Comment" })
              --     return ret
              --   end,
              -- },
            },
            confirm = function(picker, item, action)
              if vim.fn.isdirectory(item.file) ~= 1 then
                picker:action("jump")
              else
                picker:close()
                require("snacks").picker.files({ cwd = item.file })
              end
            end,
          })
        end,
      },
      {
        "<leader>g",
        function()
          require("snacks").picker.grep()
        end,
      },
      {
        "<leader>G",
        function()
          require("snacks").picker.grep_word()
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
        "<leader>p",
        function()
          require("snacks").picker.lazy()
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
    layout = {
      -- preview = "main",
    },
    ui_select = true,
    on_show = function(picker)
      vim.cmd.stopinsert()
      -- picker:toggle("preview", { enable = false })
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
      projects = {
        dev = {
          "~/dev",
          "~/projects",
          "~/work",
          "~/UnityProjects",
          "~/Unity/Projects",
          "~/source/repos",
        },
        patterns = {
          ".git",
          "_darcs",
          ".hg",
          ".bzr",
          ".svn",
          "package.json",
          "Makefile",
          "*.sln",
        },
      },
      grep = {
        hidden = true,
      },
      files = {
        hidden = true,
      },
      lazy = {
        confirm = function(picker, item)
          if item.file then
            local resolved = vim.fs.normalize(assert(vim.uv.fs_realpath(item.file)))
            item.file = resolved
            item._path = resolved
          end
          picker:action("jump")
        end,
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
          ["J"] = { "history_forward", mode = { "n" } },
          ["K"] = { "history_back", mode = { "n" } },
          ["gv"] = { "vsplit", mode = { "n" } },
          ["gs"] = { "split", mode = { "n" } },
        },
      },
    },
  },
}
