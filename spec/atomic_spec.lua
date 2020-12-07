local inspect = require'inspect'
local Atomic = require'../src/atomic'

describe('Atomic', function()
  local types = 'ifs'
  local packed_data = {}
  local data = {
    i = 123456789,
    f = 1.2345678,
    s = 'hello',
    -- b = 'world123'
  }

  describe('pack', function()
    it('can handle the fundamental types', function()
      for type in types:gmatch('.') do
        assert.not_nil(Atomic.pack[type])
      end
    end)

    it('returns a multiple of 32', function()
      for k, v in pairs(data) do
        local buffer = Atomic.pack[k](v)
        assert.are.equal(#buffer * 8 % 32, 0)
        packed_data[k] = buffer
      end
    end)
  end)

  describe('unpack', function()
    it('can handle the fundamental types', function()
      for type in types:gmatch('.') do
        assert.not_nil(Atomic.unpack[type])
      end
    end)

    it('returns the correct value', function()
      for k, v in pairs(packed_data) do
        local value, offset, size
        if k == 'b' then
          size, value, offset = Atomic.unpack[k](v)
          assert.are.equal(8, size)
          assert.are.equal(data[k], value)
          assert.are.equal(offset, 13) -- size (4) + blob (8) + 1
        elseif k == 'f' then
          value, offset = Atomic.unpack[k](v)
          assert.is_true(math.abs(data[k] - value) < 0.0001)
        else
          value, offset = Atomic.unpack[k](v)
          assert.are.equal(data[k], value)
        end
      end
    end)
  end)
end)
