#!/usr/bin/env luma -l class

require"foo"

local o = foo.new("Hello")

print(o:say("world!"))
