require"lpeg"
require"luma"
require"leg.parser"

local chunk = lpeg.P(leg.parser.apply(lpeg.V"Chunk"))

local syntax = [[
    try <- _ ({chunk} _ catch? finally?) -> build_try 'end'? _
    catch <- 'catch' _ ({name} _ {chunk} _) -> build_catch
    finally <- 'finally' _ {chunk} -> build_finally _
]]

local defs = {
  build_catch = function (var, chunk)
    return { var = var, chunk = chunk }
  end,
  build_finally = function (chunk)
    return { chunk = chunk }
  end,
  build_try = function (chunk, tf1, tf2)
    local try = { chunk = chunk, catch = {}, finally = {},
     ok = luma.gensym(), err = luma.gensym()  }
    if tf1.var then
      try.catch = { tf1 }
      if tf2 then try.finally = { tf2 } end
    else
      try.finally = { tf1 }
    end
    return try
  end,
  chunk = chunk
}

local code = [[
  do
   local $ok, $err = pcall(function () $chunk end)
   if $ok then
     $finally[=[
       $chunk
     ]=]
   else
     $catch[=[
     $ok, $err = pcall(function ($var) $chunk end, $err)
     ]=] 
     $finally[=[
       $chunk
     ]=]
     if not $ok then error($err) end
   end
  end
]]

luma.define("try", syntax, code, defs)
