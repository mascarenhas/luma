#!/usr/bin/env lua51 luam -l automata

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

