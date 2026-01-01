local M = {}

local restart = require("rc.editor.restart")

M.restart = restart.exec

function M.setup()
  restart.setup()
end

return M
