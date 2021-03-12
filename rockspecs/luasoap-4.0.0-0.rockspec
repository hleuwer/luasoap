package = "luasoap"
version = "4.0.0-0"

source = {
   url="https://github.com/tomasguisasola/luasoap/archive/v4_0_0.tar.gz",
   md5="0aafb0d7c6aa1f5b9b7c350d7507879f"
   dir="luasoap-4_0_0",
}

description = {
   summary = "Support for SOAP",
   detailed = "LuaSOAP provides a very simple API that convert Lua tables to and from XML documents",
   homepage = "http://tomasguisasola.github.io/luasoap/",
   license = "MIT/X11",
}

dependencies = {
   "lua >= 5.0",
   "luaexpat >= 1.1.0-3",
   "luasocket >= 2.0.2-1",
   "lua-http-digest >= 1.2.2-1"
}

build = {
   type = "builtin",
   modules = {
      soap  = "src/soap.lua",
      ["soap.server"] = "src/server.lua",
      ["soap.client"] = "src/client.lua",
   }
}

