local M = {
  "windwp/nvim-autopairs",
  -- dependencies = { "nvim-cmp" },
  event = { "InsertEnter" },
  cond = not vim.g.vscode,
}

function M.config()
  -- _G.__is_log = true
  local npairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")
  local cond = require("nvim-autopairs.conds")
  local ts_conds = require("nvim-autopairs.ts-conds")

  local syntax_filetypes = { "cs", "vim", "toml", "lua", "python", "c", "cpp" }
  local ts_config = {} --- @type table<string, table>
  for _, value in ipairs(syntax_filetypes) do
    ts_config[value] = {}
  end

  npairs.setup({
    check_ts = true,
    ts_config = ts_config,
  })

  -- cmp settings
  -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  -- local cmp = require('cmp')
  -- cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

  -- operator with filetypes
  local operators = {
    ">",
    "<",
    "+",
    "-",
    "=",
    -- "*",
    -- "/",
    "~",
    "!",
  }
  local escaped_brackets = { "%(", "%)", "%{", "%}", "%[", "%]" }
  local not_string_or_comment = ts_conds.is_not_ts_node({
    "string",
    "string_content",
    "string_literal",
    "comment",
    "comment_content",
    "source",
  })
  local comment = ts_conds.is_ts_node({
    "comment",
    "comment_content",
    "source",
  })

  --- Insert white space operator's side.
  ---@param operator string
  ---@return Rule
  local function operator_settings(operator)
    return Rule(operator, "", syntax_filetypes)
      ---@param opts CondOpts
      ---@return boolean | nil
      :with_pair(function(opts)
        -- This setting is for allowing --- comments in lua.
        -- Without this comment, -- after -- will become -- -
        local prev_3char = opts.line:sub(opts.col - 3, opts.col - 1)
        if comment(opts) and prev_3char == operator .. operator .. " " then
          return true
        end
        return not_string_or_comment(opts)
      end)
      ---@param opts CondOpts
      ---@return string
      :replace_endpair(function(opts)
        local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
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
  npairs.add_rules({
    Rule(" ", " ")
      ---@param opts CondOpts
      ---@return boolean | nil
      :with_pair(function(opts)
        local pair = opts.line:sub(opts.col - 1, opts.col)
        return vim.tbl_contains({ "()", "[]", "{}" }, pair)
      end),
  })
end

return M
