local M = {
  "windwp/nvim-autopairs",
  dependencies = { "nvim-cmp" },
  event = { "InsertEnter" },
  cond = not vim.g.vscode,
}

function M.config()
  -- _G.__is_log = true
  local npairs = require "nvim-autopairs"
  local Rule = require "nvim-autopairs.rule"
  local cond = require "nvim-autopairs.conds"
  local ts_conds = require "nvim-autopairs.ts-conds"

  local syntax_filetypes = { "cs", "vim", "toml", "lua", "python" }
  local ts_config = {}
  for _, value in ipairs(syntax_filetypes) do
    ts_config[value] = {}
  end

  npairs.setup {
    check_ts = true,
    ts_config = ts_config,
    fast_wrap = {},
  }

  -- cmp settings
  -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  -- local cmp = require('cmp')
  -- cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

  -- operator with filetypes
  local operators = { ">", "<", "+", "-", "=", "*", "/", "~", "!" }
  local escaped_brackets = { "%(", "%)", "%{", "%}", "%[", "%]" }

  --- insert white space operator's side.
  local function operator_settings(operator)
    return Rule(operator, "", syntax_filetypes)
      :with_pair(ts_conds.is_not_ts_node { "string", "comment", "string_literal", "source" })
      :replace_endpair(function(opts)
        local prev_2char = string.sub(opts.line, opts.col - 2, opts.col - 1)
        -- single operator
        if string.match(prev_2char, "[%w_" .. table.concat(escaped_brackets) .. "]$") then
          return ("<bs> %s "):format(operator)
        end
        -- double operator
        if string.match(prev_2char, ("[%s] "):format(table.concat(operators))) then
          return ("<bs><bs>%s "):format(operator)
        end
        return " "
      end)
      :set_end_pair_length(0)
      :with_move(cond.none())
      :with_del(cond.none())
  end

  npairs.add_rules(vim.tbl_map(operator_settings, operators))

  -- insert white space inner bracket
  npairs.add_rules {
    Rule(" ", " "):with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ "()", "[]", "{}" }, pair)
    end),
  }
end

return M
