local M = {}
_G.Status = M

---@return {name:string, text:string, texthl:string}[]
function M.get_signs()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  return vim.tbl_map(function(sign)
    return vim.fn.sign_getdefined(sign.name)[1]
  end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
end

local sign_text = function(sign)
  local text = ""
  if sign.texthl then
    text = text .. "%#" .. sign.texthl .. "#"
  end
  if sign.text then
    text = text .. sign.text
  end
  return text .. "%*"
end

function M.column()
  local sign, git_sign
  for _, s in ipairs(M.get_signs()) do
    if s.name:find "GitSign" then
      git_sign = s
    else
      sign = s
    end
  end
  local components = {
    sign and sign_text(sign) or " ",
    [[%=]],
    -- [[%{&nu?(&rnu&&v:relnum?v:relnum:v:lnum):''} ]],
    [[%{&nu&&!v:virtnum?(&rnu&&v:relnum?v:relnum:v:lnum):''} ]],
    git_sign and sign_text(git_sign) or "  ",
  }
  return table.concat(components, "")
end

function M.setup()
  vim.opt.statuscolumn = [[%!v:lua.Status.column()]]
end

return M
