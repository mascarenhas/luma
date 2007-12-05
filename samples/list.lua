#!/usr/bin/env luma -l listcomp -l automaton

x = L[[i for i = 1,5]]

y = L[[L[=[j for j=1,3]=] for i=1,3]]

print(unpack(x))

for _, v in ipairs(y) do print(unpack(v)) end

lines = L[[tostring(automaton[=[init: c -> more 
                                more: a -> more
                                      d -> more
                                      r -> finish
                                finish: accept]=](line)) 
           for line in io.lines()]]

print(table.concat(lines,"\n"))
