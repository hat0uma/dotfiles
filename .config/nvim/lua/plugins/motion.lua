return {
  {
    "ggandor/lightspeed.nvim",
    enabled = false,
    init = function()
      vim.g.lightspeed_no_default_keymaps = true
    end,
    config = function()
      vim.api.nvim_set_hl(0, "LightspeedHiddenCursor", { blend = 100, nocombine = true })

      local guicursor = vim.go.guicursor
      local hide_cursor = function()
        vim.go.guicursor = "a:LightspeedHiddenCursor"
      end
      local restore_cursor = vim.schedule_wrap(function()
        vim.go.guicursor = guicursor
      end)

      local group = vim.api.nvim_create_augroup("lightspeed_aug", {})
      vim.api.nvim_create_autocmd("User", { pattern = "LightspeedFtEnter", callback = hide_cursor, group = group })
      vim.api.nvim_create_autocmd("User", { pattern = "LightspeedFtLeave", callback = restore_cursor, group = group })
    end,
    keys = {
      { "f", "<Plug>Lightspeed_f", { "n", "x", "o" } },
      { "F", "<Plug>Lightspeed_F", { "n", "x", "o" } },
      { "t", "<Plug>Lightspeed_t", { "n", "x", "o" } },
      { "T", "<Plug>Lightspeed_T", { "n", "x", "o" } },
    },
  },
  {
    "phaazon/hop.nvim",
    config = function()
      require("hop").setup()
    end,
    -- keys = { { ";", "<Cmd>HopWord<CR>" } },
  },
  {
    "mfussenegger/nvim-treehopper",
    enabled = false,
    init = function()
      vim.keymap.set({ "o", "x" }, "m", require("tsht").nodes, {})
    end,
    dependencies = { "hop.nvim" },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup {
        jump = {
          nohlsearch = true,
          autojump = true,
        },
        modes = {
          char = {
            enabled = true,
            keys = { "f", "F", "t", "T" },
            highlight = { backdrop = false },
          },
          search = {
            labels = "ASDFGHJKLQWERTYUIOPZXCVBNM",
          },
        },
        highlight = {
          groups = { label = "HopNextKey" },
        },
      }
    end,
    keys = {
      {
        ";",
        mode = { "n", "x", "o" },
        function()
          local flash = require "flash"
          ---@param opts Flash.Format
          local function format(opts)
            -- always show first and second label
            return {
              { opts.match.label1, "FlashMatch" },
              { opts.match.label2, "FlashLabel" },
            }
          end

          flash.jump {
            search = { mode = "search" },
            label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
            pattern = [[\<]],
            action = function(match, state)
              state:hide()
              flash.jump {
                search = { max_length = 0 },
                highlight = { matches = false },
                label = { format = format },
                matcher = function(win)
                  -- limit matches to the current label
                  return vim.tbl_filter(function(m)
                    return m.label == match.label and m.win == win
                  end, state.results)
                end,
                labeler = function(matches)
                  for _, m in ipairs(matches) do
                    m.label = m.label2 -- use the second label
                  end
                end,
              }
            end,
            labeler = function(matches, state)
              local labels = state:labels()
              for m, match in ipairs(matches) do
                match.label1 = labels[math.floor((m - 1) / #labels) + 1]
                match.label2 = labels[(m - 1) % #labels + 1]
                match.label = match.label1
              end
            end,
          }
        end,
      },
      {
        "m",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
      },
    },
  },
}
