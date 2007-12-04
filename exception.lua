#!/usr/bin/env lua51 luam -l trycatch

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
