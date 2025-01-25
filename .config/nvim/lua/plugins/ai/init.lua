local function plug(spec)
  return vim.tbl_extend("error", spec, {
    cond = function()
      return vim.env.ENABLE_NVIM_AI_PLUGINS == "1"
    end,
  })
end

return {
  plug(require("plugins.ai.copilotchat")),
  plug(require("plugins.ai.codecompanion")),
  plug(require("plugins.ai.copilot")),
}
