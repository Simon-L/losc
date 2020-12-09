local inspect = require'inspect' -- debug only
local is_lua53 = _VERSION:find('3') ~= nil
local _pack = string.pack or require'struct'.pack
local _unpack = string.unpack or require'struct'.unpack

local Types = {}

--- @brief Pack an OSC type
Types.pack = {}

--- @brief Unpack an OSC type
Types.unpack = {}

local function strsize(s)
  return 4 * (math.floor(#s / 4) + 1)
end

local function blobsize(b)
  return 4 * (math.floor((#b + 3) / 4))
end

--- 32-bit big-endian two's complement integer

-- Pack a integer value.
-- @returns buffer
Types.pack.i = function(value)
  return _pack('>i4', value)
end

-- Unpack integer data.
-- @returns value, index of the bytes read + 1
Types.unpack.i = function(data, offset)
  return _unpack('>i4', data, offset)
end

--- 32-bit big-endian IEEE 754 floating point number

-- Pack a float value.
-- @returns buffer
Types.pack.f = function(value)
  return _pack('>f', value)
end

-- Unpack float data.
-- @returns value, index of the bytes read + 1
Types.unpack.f = function(data, offset)
  return _unpack('>f', data, offset)
end

--- String (null terminated)

-- Pack a string value.
-- @returns buffer
Types.pack.s = function(value)
  local len = strsize(value)
  local fmt = 'c' .. len
  value = value .. string.rep(string.char(0), len - #value)
  return _pack('>' .. fmt, value)
end

-- Unpack string data.
-- @returns value, index of the bytes read + 1
Types.unpack.s = function(data, offset)
  local fmt = is_lua53 and 'z' or 's'
  local str = _unpack('>' .. fmt, data, offset)
  return str, strsize(str) + (offset or 1)
end


--- Blob (arbitrary binary data)

-- Pack byte string.
-- @returns buffer
Types.pack.b = function(value)
  local size = #value
  local aligned = blobsize(value)
  local fmt = 'c' .. aligned
  value = value .. string.rep(string.char(0), aligned - size)
  return _pack('>I4' .. fmt, size, value)
end

-- Unpack blob data.
-- @returns value, index of the bytes read + 1
Types.unpack.b = function(data, offset)
  local size, blob
  size, offset = _unpack('>I4', data, offset)
  blob, offset = _unpack('>c' .. size, data, offset)
  return blob, offset + blobsize(blob) - size
end

-- Extended types

--- Boolean

-- Unpack true.
-- @note This type does not have a corresponding `pack` method.
-- @returns true (boolean) and byte offset (not incremented)
Types.unpack.T = function(_, offset)
  return true, offset or 0
end

-- Unpack false.
-- @note This type does not have a corresponding `pack` method.
-- @returns false (boolean) and byte offset (not incremented)
Types.unpack.F = function(_, offset)
  return false, offset or 0
end

-- Unpack nil.
-- @note This type does not have a corresponding `pack` method.
-- @returns false (since nil cannot be represented in a lua table) and byte offset (not incremented)
Types.unpack.N = function(_, offset)
  -- TODO: decide on what to return here..
  return false, offset or 0
end

-- Unpack infinitum.
-- @note This type does not have a corresponding `pack` method.
-- @returns math.huge and byte offset (not incremented)
Types.unpack.I = function(_, offset)
  return math.huge, offset or 0
end

return Types
