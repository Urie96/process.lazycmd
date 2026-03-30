local action = require 'process.action'

local M = {}

local function add_keymap(targets, key, callback, desc)
  if not key or key == '' then return end
  for _, target in ipairs(targets) do
    target[key] = { callback = callback, desc = desc }
  end
end

local metas = {
  process = {
    __index = {
      keymap = {},
      preview = function(entry, cb)
        action.preview(entry, cb)
      end,
    },
  },
  info = {
    __index = {
      keymap = {},
      preview = function(entry, cb)
        cb(action.info_preview(entry))
      end,
    },
  },
}

function M.setup(cfg)
  local keymap = (cfg or {}).keymap or {}
  local process_map = metas.process.__index.keymap

  for key, _ in pairs(process_map) do
    process_map[key] = nil
  end

  add_keymap({ process_map }, keymap.kill, action.kill, 'kill process')
end

function M.attach(entries)
  for i, entry in ipairs(entries or {}) do
    local mt = metas[entry.kind]
    if mt then entries[i] = setmetatable(entry, mt) end
  end
  return entries
end

return M
