# $Id: Makefile,v 1.1.1.1 2007/11/26 17:12:24 mascarenhas Exp $

config_file:=config

ifneq '$(wildcard $(config_file))' ''
include $(config_file)
endif

$(config_file):
	chmod +x configure

install: $(config_file)
	sed -e '1s,^#!.*,#!$(LUA_BIN),' -i bin/luma
	sed -e '1s,^#!.*,#!$(LUA_BIN),' -i bin/expand
	mkdir -p $(LUA_DIR)
	cp src/macro.lua $(LUA_DIR)
	cp src/re.lua $(LUA_DIR)
	cp src/cosmo.lua $(LUA_DIR)
	chmod +x bin/luma
	cp bin/luma $(BIN_DIR)

clean:
