--[[
    LUA library for webscript.io
    Calls for Trello API
--]]
trello = {}

function trello.call(key,token,method,endpoint,params,data)

function callout(req_url,req_method,req_params,req_data)

return http.request {
	      url = req_url, method = req_method, 
	      headers = req_headers, 
	      params = req_params,
		    data = req_data
        }

end

prefix = 'https://api.trello.com/1/'

return callout(prefix..endpoint,method,params,data)
end

function trello.find_board(orgId,boardName,key,token)
--[[
		Function to find a named Trello board in a specified organisation
		and to return the board id if found (nil otherwise)
--]]
	
--list all boards for an Organization
-- /organization/[Org Id]/boards
r= trello.call(key,token,'GET','/organization/'..orgId..'/boards/',{key=key,token=token})
j=json.parse(r.content)
-- trawl through all boards (open and closed) for this organisation
-- return the id of the first board with a matching name that is found
for k,v in ipairs(j) do
	if (v.name == boardName) then
		-- return id of matching board name
		return v.id
	end
end
-- no matching board name found
return nil

end
