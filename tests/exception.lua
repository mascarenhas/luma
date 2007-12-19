#!/usr/bin/env luma

require_for_syntax[[trycatch]]

local ran_catch = false
local ran_finally = false

try [[
  error("error!")
  assert(false)
catch err
  assert(err)
  ran_catch = true
finally
  ran_finally = true
]]

assert(ran_catch)
assert(ran_finally)
