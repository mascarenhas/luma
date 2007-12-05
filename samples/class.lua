require"lpeg"
require"macro"
require"leg.parser"

local funcbody = lpeg.P(leg.parser.apply(lpeg.V"FuncBody"))

local syntax = [[
  defs <- space definition* -> build_class
  extends <- 'extends' space luaname -> build_extends
  mixin <- 'include' space luaname -> build_mixin
  classmethod <- 'class' space 'method' space (luaname {funcbody}) -> build_classmethod space
  instancemethod <- ('instance' space)? 'method' space (luaname {funcbody}) -> build_instancemethod space
  definition <- extends / mixin / classmethod / instancemethod
]]

local defs = {
  build_classmethod = function (name, body)
    return { name = "_M." .. name, body = body }
  end,
  build_instancemethod = function (name, body)
    return { name = "_M.instance_methods:" .. name, body = body }
  end,
  build_extends = function (class)
    return { type = "extends", class = class }
  end,
  build_mixin = function (class)
    return { type = "mixin", class = class }
  end,
  build_class = function (...)
    local defs = { ... }
    local class = { parent = "", mixins = {}, methods = {} }
    for i, v in ipairs(defs) do
      if v.type == "extends" then
        class.parent = v.class
      elseif v.type == "mixin" then
        table.insert(class.mixins, { class = v.class })
      else
        table.insert(class.methods, v)
      end
    end
    return class
  end,
  funcbody = funcbody
}

local code = [[
  _M.instance_methods = _M.instance_methods or _M.methods or {}

  $mixins[=[
  do
    local mixin = require"$class"
    for k, v in pairs(mixin.instance_methods) do
      _M.instance_methods[k] = v
    end
  end
  ]=]

  if "$parent" ~= "" then
    local parent = require"$parent"
    setmetatable(instance_methods, { __index = parent.instance_methods })
    _M.super = parent.instance_methods
  end

  if not _M.new then
    function _M.new(...)
      local obj = {}
      setmetatable(obj, { __index = instance_methods })
      if obj.initialize then obj:initialize(...) end
      return obj
    end
  end

  $methods[=[
  function $name $body
  ]=]
]]

macro.define("class_description", syntax, code, defs)