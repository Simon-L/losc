------------------
-- API.
--
-- In most cases this will be the only module required to use losc.
--
-- @module losc
-- @author David Granström
-- @license MIT
-- @copyright David Granström 2020

local Message = require'losc.message'
local Bundle = require'losc.bundle'
local Timetag = require'losc.timetag'

local losc = {}
losc.__index = losc
losc.handlers = {}

--- Create a new Message.
--
-- @param[opt] ... arguments.
-- @return status, message object or error.
-- @see losc.message
-- @usage local ok, message = losc.message_new()
-- @usage local ok, message = losc.message_new('/address')
-- @usage local ok, message = losc.message_new({ address = '/foo', types = 'iif', 1, 2, 3})
function losc.message_new(...)
  return pcall(Message.new, ...)
end

--- Create a new OSC bundle.
--
-- @param[opt] ... arguments.
-- @return status, bundle object or error.
-- @see losc.bundle
-- @usage local bundle = losc.bundle_new()
-- @usage
-- local tt = Timetag.new_raw()
-- local ok, bundle = losc.bundle_new(tt)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local ok, bundle = losc.bundle_new(tt, osc_msg, osc_msg2)
-- @usage
-- local tt = Timetag.new(os.time(), 0)
-- local ok, bundle = losc.bundle_new(tt, osc_msg, other_bundle)
function losc.bundle_new(...)
  return pcall(Bundle.new, ...)
end

--- Specify a plugin.
-- @param plugin The plugin to use.
function losc:use(plugin)
  self.plugin = plugin
  self.plugin.handlers = self.handlers
end

--- Get a OSC timetag with the current timestamp.
-- Will fall back to os.time() if now() is not implemented by a plugin.
function losc:now()
  if self.plugin.now then
    return self.plugin:now()
  end
  return Timetag.new(os.time(), 0)
end

--- Opens an OSC server.
-- @param[opt] ... Plugin specific arguments.
-- @return status, plugin handle or error
function losc:open(...)
  return pcall(self.plugin.open, self.plugin, ...)
end

--- Closes an OSC server.
-- @return status, nil or error
function losc:close(...)
  return pcall(self.plugin.close, self.plugin, ...)
end

--- Send an OSC packet.
-- @param[opt] ... Plugin specific arguments.
-- @return status, nil or error
function losc:send(...)
  return pcall(self.plugin.send, self.plugin, ...)
end

--- Add an OSC method.
-- TODO: validate pattern
function losc:add_handler(pattern, cb)
  self.handlers[pattern] = cb
end

--- Remove an OSC method.
function losc:remove_handler(pattern)
  self.handlers[pattern] = nil
end

return losc
