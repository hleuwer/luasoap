# $Id: Makefile,v 1.13 2009/07/22 19:02:46 tomas Exp $
#

VERSION=4.0
LUAV=5.2
LUA_DIR= /usr/local/share/lua/$(LUAV)
INSTALL_DIR= $(LUA_DIR)/soap
EXTRA_DIR= $(INSTALL_DIR)/client

MAIN_LUA= src/soap.lua 
LUAS= src/client.lua src/server.lua
EXTRA= src/client/https.lua

build clean:

install:
	cp $(MAIN_LUA) $(LUA_DIR)
	mkdir -p $(INSTALL_DIR)
	cp $(LUAS) $(INSTALL_DIR)
	mkdir -p $(EXTRA_DIR)
	cp $(EXTRA) $(EXTRA_DIR)

uninstall:
	rm -rf $(INSTALL_DIR) $(LUA_DIR)/soap.lua

dist:
	cd ..; tar czf luasoap-$(VERSION).tar.gz luasoap-$(VERSION) --exclude .git --exclude rockspecs
	echo Created ../luasoap-$(VERSION).tar.gz
