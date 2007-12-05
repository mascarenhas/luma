require"macro"

local function expand_power(n, x)
  if n == 0 then return "1"
  else return "" .. x .. " * " .. expand_power(n-1, x) end
end

local function mk_power(n)
  n = tonumber(n)
  return "function (x) return " .. expand_power(n,"x") .. " end "
end

macro.define_simple("mk_power_ml", 
  function (args) return mk_power(args[1]) end)

macro.define_simple("mk_power", function (args)
                                   args.pow = {}
                                   for i = 1, tonumber(args[1]) do
                                     table.insert(args.pow, 1)
                                   end
                                   return [[function (x)
                                              return $pow[=[x*]=]1
                                            end]]
                                 end)
