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

o=json.parse(storage.oauth)
token = o["access_token"]

req_headers = {}
req_headers["Authorization"] = "Bearer "..token
req_headers["x-myobapi-cftoken"] = base64.encode(o.username..":"..o.password)
req_headers["x-myobapi-key"] = o["consumer_key"]
req_headers["x-myobapi-version"] = "v2"

queue = 'myob'
lease.acquire(queue)

myob={}
if storage[queue] then
  myob=json.parse(storage[queue])
end

--q=q.."?$filter=PayPeriodStartDate eq datetime'2015-09-03T00:00:00'"
ep = API_endpoint..q
--check if we've called this endpoint before
--if so then pass the etag that we have in the headers so that
--MYOB can tell us if we already have the most current data
if myob[ep] then
	req_headers["If-None-Match"] = myob[ep].etag
end
local r = lib.callout(ep,'GET',{},{})
if r.statuscode == 304 then
	r.statuscode = 200
	r.content = myob[ep].data
else if r.statuscode == 200 then

  myob[ep] = {['etag'] = r.headers['etag'],
							['data'] = r.content}
  storage[queue]=json.stringify(myob)
	
	
	end
end

return r.statuscode,r.content

end

return myob
