local M = {}

local cfg = {
  ps_command = 'ps',
  pstree_command = 'pstree',
  keymap = {
    kill = 'dd',
  },
}

function M.setup(opt)
  cfg = lc.tbl_deep_extend('force', cfg, opt or {})
end

function M.get() return cfg end

return M
