#!/usr/bin/env luma -l using

using [[

from math import random, pow

from cosmo import fill

]]

print(random())
print(pow(2,3))
print((fill("Hello $msg!", { msg = "world" })))
