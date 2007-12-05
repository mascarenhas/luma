require"macro"

local function fact(n)
  n = tonumber(n)
  local a = 1
  for i = 2, n do
    a = a * i
  end
  return a
end

macro.define_simple("fact", function (args)
                              return fact(args[1])
                            end)
