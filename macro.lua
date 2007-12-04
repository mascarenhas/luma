require"lpeg"
require"re"
require"cosmo"
require"leg.scanner"

module("macro", package.seeall)

local macros = {}

local basic_rules = {
  space = leg.scanner.IGNORED,
  luaname = lpeg.C(leg.scanner.IDENTIFIER) * leg.scanner.IGNORED,
  char = lpeg.C(lpeg.R("az", "AZ", "09", "__")) * leg.scanner.IGNORED
}

local function gsub (s, patt, repl)
  patt = lpeg.P(patt)
  patt = lpeg.Cs((patt / repl + 1)^0)
  return lpeg.match(patt, s)
end

function define(name, grammar, code, defs)
  setmetatable(defs, { __index = basic_rules })
  local patt = re.compile(grammar, defs)
  macros[name] = { patt = patt, code = code } 
end

local lstring = loadstring

function expand(text)
  local start = "[" * lpeg.P"="^0 * "["
  local longstring = lpeg.P(function (s, i)
    local l = lpeg.match(start, s, i)
    if not l then return nil end
    local p = lpeg.P("]" .. string.rep("=", l - i - 2) .. "]")
    p = (1 - p)^0 * p
    return lpeg.match(p, s, l)
  end)
  longstring = #("[" * lpeg.S"[=") * 
    (lpeg.C(longstring) / function (s) return lstring("return " .. s)() end)
  local macro_use = [[ 
    macro <- luaname longstring 
  ]]
  local defs = { longstring = longstring }
  setmetatable(defs, { __index = basic_rules })
  local patt = re.compile(macro_use, defs)
  return gsub(text, patt, function (name, arg)
    if macros[name] then
      local patt, code = macros[name].patt, macros[name].code
      local data = patt:match(arg)
      if data then
        return expand(cosmo.fill(code, data))
      end
    end
  end)
end

function loadstring(text)
  return lstring(expand(text))
end

function dostring(text)
  return loadstring(text)()
end

function loadfile(filename)
  local file = io.open(filename)
  if file then
    local contents = expand(string.gsub(file:read("*a"), "^#![^\n]*", ""))
    file:close()
    return lstring(contents, filename)
  else
    error("file " .. filename .. " not found")
  end
end

function dofile(filename)
  return loadfile(filename)()
end

local function findfile(name)
  local path = package.path
  name = string.gsub(name, "%.", "/")
  for template in string.gmatch(path, "[^;]+") do
    local filename = string.gsub(template, "?", name)
    local file = io.open(filename)
    if file then return file, filename end
  end
end

function loader(name)
  local file, filename = findfile(name)
  local ok, contents
  if file then
    ok, contents = pcall(file.read, file, "*a")
    file:close()
    if not ok then return contents end
    ok, contents = pcall(expand, string.gsub(contents, "^#![^\n]*", ""))
    if not ok then return contents end
    return loadstring(contents, filename)
  end
end
