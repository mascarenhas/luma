#!/usr/bin/env luma -l automaton

local aut = automaton [[
  init: c -> more
  more: a -> more
        d -> more
        r -> finish
  finish: accept
]]

print(aut("cadar"))
print(aut("cadddar"))
print(aut("caxadr"))

