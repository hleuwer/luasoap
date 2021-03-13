-- $Id: test-http.lua,v 1.4 2009/07/22 19:02:46 tomas Exp $
--package.path = "../lua-http-digest.git/?.lua;"..package.path
--print(package.path)
local soap_client = require"soap.client"
local copas = require "copas"
local pretty = require "pl.pretty"
local N = tonumber(os.getenv("N") or "1")
local exp_res = 3

-------------------------------------------------------------------------------
-- Test 1: Using handler function
local request = {
-- url = "http://www.dneonline.com/calculator.asmx",
  url = "http://user:user@www.dneonline.com/calculator.asmx",
  soapaction = "http://tempuri.org/Add",
  namespace = "http://tempuri.org/",
  auth = "digest",
  method = "Add",
  entries = {
    { tag = "intA", 1 },
    { tag = "intB", 2 },
  },
  handler = function(ns, meth, ent, soap_headers, body, opaque)
     print("handler: ", pretty.write(ent,""))
     assert (meth == "AddResponse")
     assert (type(ent) == "table")
     assert (type(ent[1]) == "table")
     assert (ent[1].tag == "AddResult")
     assert (ent[1][1] == opaque)
  end
}

-- Launch N requests
print("Test 1: Launching ".. N .. " requests")
for i = 1, N do
   request.entries[1][1] = i
   request.entries[2][1] = i + 1
   request.opaque = tostring(2 * i + 1)
   soap_client.call(request)
end

-- Need to loop in copas
local cnt = 0
repeat
   print(">> stepping: ", cnt)
   cnt = cnt + 1
   copas.step()
until copas.finished() == true


-------------------------------------------------------------------------------
-- Test 2: Using standalone task instead of handler
local function task(a, b)
   local request = {
      url = "http://www.dneonline.com/calculator.asmx",
      soapaction = "http://tempuri.org/Add",
      namespace = "http://tempuri.org/",
      method = "Add",
      handler = false,
      entries = {
	 { tag = "intA", a },
	 { tag = "intB", b },
      }
   }
   ns, meth, ent, soap_headers, body = soap_client.call(request)
   assert (meth == "AddResponse")
   assert (type(ent) == "table")
   assert (type(ent[1]) == "table")
   assert (ent[1].tag == "AddResult")
   assert (ent[1][1] == tostring(a+b))
end

print("Test 2: Launching ".. N .. " threads")
for i =  1, N do
   copas.addthread(task, i, i +1)
end

-- Need to loop in copas
local cnt = 0
repeat
--   print(">> stepping: ", cnt)
   cnt = cnt + 1
   copas.step()
until copas.finished() == true

-------------------------------------------------------------------------------
-- Test 2: Using standalone task instead of handler
local function task2()
   local function secs2date(secs)
      local days = math.floor(secs / 86400)
      local hours = math.floor(secs / 3600) - (days * 24)
      local minutes = math.floor(secs / 60) - (days * 1440) - (hours * 60)
      local seconds = secs % 60
      return {
	 days = days, hours = hours, minutes = minutes, seconds = seconds
      }
   end
   local fin = assert(io.open(os.getenv("HOME").."/.fritzuser", "r"))
   local user = fin:read("*l")
   local pw = fin:read("*l")
   fin:close()
   local request = {
      soapaction = "urn:dslforum-org:service:DeviceInfo:1#GetInfo",
      url = "http://"..user..":"..pw.."@fritz.box:49000/upnp/control/deviceinfo",
      auth = "digest",
      entries = {
	 tag = "u:GetInfo"
      },
      method = "GetInfo",
      namespace = "urn:dslforum-org:service:DeviceInfo:1",
      handler = false
   }
   local ns, meth, ent, soap_headers, body = soap_client.call(request)
   local r = secs2date(tonumber(ent[22][1]))
   print(string.format("uptime is %d days,  %d hours, %d minutes, %d seconds",
		       r.days, r.hours, r.minutes, r.seconds))
   assert(ent[10][1] == "FRITZ!Box")
end

print("Test 3: Launching ".. N .. " threads")
for i = 1, N do 
   copas.addthread(task2)
end

-- Need to loop in copas
local cnt = 0
repeat
--   print(">> stepping: ", cnt)
   cnt = cnt + 1
   copas.step()
until copas.finished() == true

print(soap_client._VERSION, "Ok!")
