require"macro"
require"lpeg"
require"leg.scanner"
require"leg.parser"

local name = leg.scanner.IDENTIFIER
local exp = lpeg.P(leg.parser.apply(lpeg.V"Exp"))

local syntax = [[
  comp <- (space {exp} space 'for' space { numfor / genfor } space) -> build_comp
  numfor <- name space '=' space exp space ',' space exp space (',' space exp)?
  genfor <- name space (',' space name)* space 'in' space
    exp space (',' space exp)*
]]

local defs = {
  build_comp = function (e, f)
    return { exp = e, exp_for = f }
  end,
  name = name,
  exp = exp
}

local code = [[
  (function ()
    local ___lcomp_list = {}
    for $exp_for do
      ___lcomp_list[#___lcomp_list + 1] = $exp
    end
    return ___lcomp_list
  end)()
]]

macro.define("L", syntax, code, defs)

