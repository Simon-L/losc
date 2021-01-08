-- TODO: Remove later
package.path = package.path .. ';./src/?.lua'
package.path = package.path .. ';./src/?/?.lua'

return function(arg)
  local losc = require'losc'
  local Types = require'losc.types'
  local ok, udp = pcall(require, 'losc.plugins.udp-socket')

  if not ok then
    local msg = 'loscsend requires `luasocket`. Try: `luarocks install luasocket`'
    io.stderr:write(msg)
    return
  end

  local function usage()
    local str = ''
    str = str .. 'loscsend - Send an OSC message via UDP.\n'
    str = str .. '\nusage: loscsend ip port address [types [args]]'
    str = str .. '\nsupported types: '
    local types = {}
    for key, _ in pairs(Types.pack) do
      types[#types + 1] = key
    end
    table.sort(types)
    str = str .. table.concat(types, ', ')
    str = str .. '\n\nexample: loscsend localhost 57120 ifs 1 2.3 "hi"\n'
    io.write(str)
  end

  local ip, port, address, types

  for i, opt in ipairs(arg) do
    if opt == '-h' or opt == '--help' then
      usage()
      return
    end
    if i == 1 then
      ip = opt
    elseif i == 2 then
      port = tonumber(opt)
    elseif i == 3 then
      address = opt
    elseif i == 4 then
      types = opt
    end
  end

  local _, message = losc.new_message(address)
  if types then
    local index = 5
    for type in types:gmatch('.') do
      local item = arg[index]
      if string.match(type, '[ifdht]') then
        item = tonumber(item)
      end
      message:append(type, item)
      index = index + 1
    end
  end

  losc:use(udp)
  losc:send(message, ip, port)
  losc:close()
end
