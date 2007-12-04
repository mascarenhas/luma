require"macro"

local syntax = [==[
  aut <- space state+ -> build_aut
  accept <- {'accept'} space
  arrow <- '->' space
  colon <- ':' space
  rule <- accept / (char arrow luaname) -> build_rule 
  state <- ( luaname colon rule+ -> {} ) -> build_state
]==]

local defs = {
  build_rule = function (c, n)
    return { char = c, next = n }
  end,
  build_state = function (n, rs)
    local final = 'false'
    for i, v in ipairs(rs) do
      if v == 'accept' then
        final = 'true'
        table.remove(rs, i)
        do break end
      end
    end
    return { name = n, rules = rs, final = final }
  end,
  build_aut = function (...)
    local sts = { ... }
    local init = sts[1].name
    return { init = init, states = sts }
  end
}

local code = [[
  function (input)
    local substr = string.sub
    $states[=[
      local $name
    ]=]
    $states[=[
      $name = function (rest)
        if #rest == 0 then
          return $final
        end
        local c = substr(rest, 1, 1)
        rest = substr(rest, 2, #rest)
        $rules[==[
          if c == '$char' then
            return $next(rest)
          end
        ]==]
        return false
      end
    ]=]
    return $init(input)
  end
]]

macro.define("automata", syntax, code, defs) 


