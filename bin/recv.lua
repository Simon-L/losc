-- TODO: Remove later
package.path = package.path .. ';./src/?.lua'
package.path = package.path .. ';./src/?/?.lua'

return function(arg)
  local losc = require'losc'
  local ok, udp = pcall(require, 'losc.plugins.udp-socket')

  if not ok then
    local msg = 'loscsend requires `luasocket`. Try: `luarocks install luasocket`'
    io.stderr:write(msg)
    return
  end

  local function usage()
    local str = ''
    str = str .. 'loscrecv - Dump incoming OSC message.\n'
    str = str .. '\nusage: loscsend port'
    str = str .. '\n\nexample: loscrecv 9000\n'
    io.write(str)
  end

  if #arg > 0 then
    if arg[1] == '-h' or arg[1] == '--help' then
      usage()
      return
    end
  end

  local port = arg[1]
  if not port then
    error('loscrecv requires port argument')
  end

  losc:use(udp)
  losc:add_handler('*', function(data)
    local tt = data.timestamp
    local time = string.format('%x.%x', tt:seconds(), tt:fractions())
    io.write(time .. ' ')
    io.write(data.message.address .. ' ')
    io.write(data.message.types .. ' ')
    for _, a in ipairs(data.message) do
      io.write(tostring(a) .. ' ')
    end
    io.write('\n')
  end)
  losc:open("127.0.0.1", arg[1] or 0)
end
