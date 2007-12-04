#!/usr/bin/env lua51 luam -l class

require"foo"

local o = foo.new("Hello")

print(o:say("world!"))
