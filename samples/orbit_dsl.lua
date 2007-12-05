require"lpeg"
require"macro"
require"leg.parser"
require"leg.scanner"

local funcbody = lpeg.P(leg.parser.apply(lpeg.V"FuncBody"))
local luastring = leg.scanner.STRING

local function add_param(funcbody, param)
  return "(" .. param .. "," .. string.sub(funcbody, 2, #funcbody)
end

local syntax = [[
  defs <- space definition* -> build_app space !.
  method <- 'method' space (luaname {funcbody}) -> build_method space
  model <- 'model' space (luaname methods 'end') -> build_model
  action <- 'action' space (luaname '<-' space pattern methods 'end') -> build_action
  view <- 'view' space (luaname {funcbody}) -> build_view
  methods <- method* -> {}
  string <- luastring space
  pattern <- {string (',' space string)*}
  definition <- (method / model / action / view) space
]]

local defs = {
  build_method = function (name, body)
    return { type = "method", name = name, body = body }
  end,
  build_model = function (name, methods)
    for _, m in ipairs(methods) do m.body = add_param(m.body, "self") end
    return { type = "model", name = name, methods = methods }
  end,
  build_action = function (name, pattern, methods)
    for _, m in ipairs(methods) do m.body = add_param(m.body, "app") end
    return { type = "action", pattern = pattern, name = name,
      methods = methods }
  end,
  build_view = function (name, body)
    return { type = "view", name = name, body = add_param(body, "app") }
  end,
  build_app = function (...)
    local defs = { ... }
    local app = { methods = {}, models = {}, actions = {}, views = {} }
    for i, v in ipairs(defs) do
      print(v.type)
      table.insert(app[v.type .. "s"], v)
    end
    return app
  end,
  funcbody = funcbody,
  luastring = luastring
}

local code = [[

  $methods[=[
    function _M.methods:$name$body
  ]=]

  _M:add_models{
  $models[=[
    $name = {
    $methods[==[
      $name = function $body,
    ]==]
    }
  ]=]
  }

  _M:add_controllers{
  $actions[=[
    $name = { $pattern,
    $methods[==[
      $name = function $body,
    ]==]
    }
  ]=]
  }

  _M:add_views{
  $views[=[
    $name = function $body,
  ]=]
  }

]]

macro.define("orbit_application", syntax, code, defs)
