module("foo", package.seeall)

class [[
  extends bar

  class method baz(x, y)
    return x + y
  end

  instance method say(x)
    if self.message then
      return self.message .. " " .. x
    else
      return x
    end
  end

  instance method initialize(msg)
    super.initialize(self, msg)
  end
]]
