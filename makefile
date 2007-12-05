# $Id: Makefile,v 1.1.1.1 2007/11/26 17:12:24 mascarenhas Exp $

config_file:=config

ifneq '$(wildcard $(config_file))' ''
include $(config_file)
endif

$(config_file):
	chmod +x configure

install: $(config_file)
	sed -e '1s,^#!.*,#!$(LUA_BIN),' bin/luma > $(BIN_DIR)/luma
	chmod +x $(BIN_DIR)/luma
	sed -e '1s,^#!.*,#!$(LUA_BIN),' bin/expand > bin/expand.tmp
	mv bin/expand.tmp bin/expand
	chmod +x bin/expand
	mkdir -p $(LUA_DIR)
	cp src/macro.lua $(LUA_DIR)
	cp src/re.lua $(LUA_DIR)
	cp src/cosmo.lua $(LUA_DIR)

clean:
