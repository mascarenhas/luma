require"lpeg"
require"re"
require"macro"
require"leg.parser"
require"leg.scanner"

local exp = lpeg.P(leg.parser.apply(lpeg.V"Exp"))
local chunk = lpeg.P(leg.parser.apply(lpeg.V"Chunk"))

local syntax = [[
  match <- space ('subject' space {exp} space 
    clauses clause_else? 'end' space) -> build_match
  clauses <- clause+ -> {}
  captures <- ({luaname (',' space luaname)*} / {""}) -> build_captures
  clause <- ('with' space captures '<-' space {exp} space 'do' space {chunk} 
    {'fallthrough'?} space) -> build_clause
  clause_else <- ('default' space {chunk}) -> build_else
]]

local defs = {
  build_captures = function (caps)
    return caps
  end,
  build_match = function (subj, clauses, clause_else)
    return { subject = subj, clauses = clauses, clause_else = { clause_else } }
  end,
  build_clause = function (captures, patt, chunk, ft)
    if ft == "fallthrough" then ft = "" else ft = "do break end" end
    if captures == "" then captures = "_" end
    local first_cap = re.match(captures, [[ {[^ ,]+} ]])
    return { captures = captures, pattern = patt, chunk = chunk, 
      fallthrough = ft, first_cap = first_cap }
  end,
  build_else = function (chunk)
    return { chunk = chunk }
  end,
  chunk = chunk,
  exp = exp
}

local code = [[
  do
    local re = require"re"
    local subject = $subject
    repeat
    $clauses[=[
      local $captures = re.match(subject, $pattern)
      if $first_cap then
        $chunk
        $fallthrough
      end
    ]=]
    $clause_else[=[
      $chunk
    ]=]
    until true
  end
]]

macro.define("match", syntax, code, defs)
