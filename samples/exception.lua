#!/usr/bin/env luma

require_for_syntax[[trycatch]]

try [[
  print("Hello world!")
  error("error!")
catch err
  print(err)
--  Reraise
--  error(err)
finally
  print("Finally!")
]]
