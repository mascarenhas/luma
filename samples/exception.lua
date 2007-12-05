#!/usr/bin/env luma -l trycatch

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
