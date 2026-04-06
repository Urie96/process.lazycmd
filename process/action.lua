local config = require 'process.config'

local M = {}

local function line(parts) return lc.style.line(parts) end
local function text(lines) return lc.style.text(lines) end
local function span(value, color)
  local s = lc.style.span(tostring(value or ''))
  if color and color ~= '' then s = s:fg(color) end
  return s
end

local function current_entry()
  local entry = lc.api.get_hovered()
  if not entry or entry.kind ~= 'process' or not entry.pid then return nil end
  return entry
end

function M.kill(entry)
  entry = entry or current_entry()
  if not entry then
    lc.notify 'No process selected'
    return
  end

  lc.system({ 'kill', tostring(entry.pid) }, function(out)
    if out.code == 0 then
      lc.cmd 'reload'
      return
    end
    lc.notify('Failed to kill process: ' .. tostring(out.stderr or 'unknown error'))
  end)
end

function M.preview(entry, cb)
  if not entry or not entry.pid then
    cb(text {
      line { span('Select a process to preview', 'darkgray') },
    })
    return
  end

  lc.system({ config.get().pstree_command, '-p', tostring(entry.pid) }, function(out)
    if out.code == 0 then
      cb(out.stdout:ansi())
      return
    end

    cb(text {
      line { span('Failed to load process tree', 'red') },
      line { span(out.stderr or 'unknown error', 'darkgray') },
    })
  end)
end

function M.info_preview(entry)
  return text {
    line { span(entry.message or 'Info', entry.color or 'darkgray') },
  }
end

return M
