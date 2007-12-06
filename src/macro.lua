require"lpeg"
require"re"
require"cosmo"

module("macro", package.seeall)

local macros = {}

local IGNORED, STRING, LONGSTRING, SHORTSTRING, NAME, NUMBER

do
  local m = lpeg
  local N = m.R'09'
  local AZ = m.R('__','az','AZ','\127\255')     -- llex.c uses isalpha()

  NAME = AZ * (AZ+N)^0

  local number = (m.P'.' + N)^1 * (m.S'eE' * m.S'+-'^-1)^-1 * (N+AZ)^0
  NUMBER = #(N + (m.P'.' * N)) * number

  local long_brackets = #(m.P'[' * m.P'='^0 * m.P'[') * function (subject, i1)
    local level = _G.assert( subject:match('^%[(=*)%[', i1) )
    local _, i2 = subject:find(']'..level..']', i1, true)
    return (i2 and (i2+1))
  end

  local multi  = m.P'--' * long_brackets
  local single = m.P'--' * (1 - m.P'\n')^0

  local COMMENT = multi + single
  local SPACE = m.S'\n \t\r\f'
  IGNORED = (SPACE + COMMENT)^0

  SHORTSTRING = (m.P'"' * ( (m.P'\\' * 1) + (1 - (m.S'"\n\r\f')) )^0 * m.P'"') +
                (m.P"'" * ( (m.P'\\' * 1) + (1 - (m.S"'\n\r\f")) )^0 * m.P"'")
  LONGSTRING = long_brackets
  STRING = SHORTSTRING + LONGSTRING
end

local basic_rules = {
  ["_"] = IGNORED,
  name = NAME,
  number = NUMBER,
  string = STRING,
  longstring = LONGSTRING,
  shortstring = SHORTSTRING
}

local function gsub (s, patt, repl)
  patt = lpeg.P(patt)
  patt = lpeg.Cs((patt / repl + 1)^0)
  return lpeg.match(patt, s)
end

function define(name, grammar, code, defs)
  setmetatable(defs, { __index = basic_rules })
  local patt = re.compile(grammar, defs) * (-1)
  macros[name] = { patt = patt, code = code } 
end

local lstring = loadstring

function expand(text)
  local macro_use = [[ 
    macro <- {name} _ {longstring} 
  ]]
  local patt = re.compile(macro_use, basic_rules)
  return gsub(text, patt, function (name, arg)
    if macros[name] then
      arg = loadstring("return " .. arg)()
      local patt, code = macros[name].patt, macros[name].code
      local data = patt:match(arg)
      if data then
        if type(code) == "string" then
          return expand(cosmo.fill(code, data))
        else
          return expand(cosmo.fill(code(data), data))
        end
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

do
  local ok, parser = pcall(require, "leg.parser")
  if ok then
    function define_simple(name, code)
      local exp = lpeg.P(parser.apply(lpeg.V"Exp"))
      local syntax = [[
        explist <- _ ({exp} _ (',' _ {exp} _)*) -> build_explist 
      ]]
      local defs = {
        build_explist = function (...)
          local args = { ... }
          local exps = { args = {} }
          for i, a in ipairs(args) do
            exps[tostring(i)] = a
	    exps[i] = a
            exps.args[i] = { value = a }
          end
          return exps
        end,
        exp = exp
      }
      define(name, syntax, code, defs)
    end

    define_simple("require_for_syntax", function (args)
                                          require(args[1])
                                          return ""
                                        end)

    define("meta", "{chunk}", function (c) 
                                macro.dostring(c)
                                return ""
                              end,
           { chunk = lpeg.P(parser.apply(lpeg.V"Chunk")) })
  end
end

