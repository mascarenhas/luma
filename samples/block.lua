#!/usr/bin/env luma

require_for_syntax[[block_func]]

foo = block_func [[ (s, block)
  local x = {}  
  function x:print(m)
    print(m .. " " .. s .. "!")
  end
  block(x)
]]

foo("World") with [[ (x)
  x:print("Hello")
]]
