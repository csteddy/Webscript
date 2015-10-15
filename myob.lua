myob={}

--[[

This is a wrapper for calls to the MYOB API.
The endpoint prefix (which specifies the GUID of our MYOB file),
is hardcoded. The OAuth token is contantly refreshed by a
seperate script that is run via Cron.


--]]
function myob.apiCall(q)

local API_endpoint = 'https://api.myob.com/accountright/84f38c5b-82a0-4213-9ad8-6c38b177a0ed/'

require 'csteddy/Webscript/lib.lua'
require 'csteddy/Webscript/json.lua'

o=json.parse(storage.oauth)
token = o["access_token"]

req_headers = {}
req_headers["Authorization"] = "Bearer "..token
req_headers["x-myobapi-cftoken"] = base64.encode(o.username..":"..o.password)
req_headers["x-myobapi-key"] = o["consumer_key"]
req_headers["x-myobapi-version"] = "v2"

queue = 'myob'
--lease.acquire(queue)

cache={}
if storage[queue] then
  cache=json.parse(storage[queue])
end

--q=q.."?$filter=PayPeriodStartDate eq datetime'2015-09-03T00:00:00'"
ep = API_endpoint..q
--check if we've called this endpoint before
--if so then pass the etag that we have in the headers so that
--MYOB can tell us if we already have the most current data
if cache[ep] then
  req_headers["If-None-Match"] = cache[ep].etag
end
r = lib.callout(ep,'GET',{},{})
if r.statuscode == 304 then
	return 200,cache[ep].data
	
elseif r.statuscode == 200 then

  cache[ep] = {['etag'] = r.headers['etag'],
		['data'] = r.content}
  storage[queue]=json.stringify(cache)
else	
  log('xxx')	
end
log
lease.release(queue)
return r.statuscode,r.content

end
end
return myob
