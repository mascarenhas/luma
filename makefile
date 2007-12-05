# $Id: Makefile,v 1.1.1.1 2007/11/26 17:12:24 mascarenhas Exp $

include config

all:

install:
	mkdir -p $(LUA_DIR)
	cp src/macro.lua $(LUA_DIR)
        cp src/re.lua $(LUA_DIR)
        cp src/cosmo.lua $(LUA_DIR)

clean:
