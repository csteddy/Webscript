glib={}
--[[

Library of Google API functions.

--]]

function glib.getOAuthToken(refresh_token,Client_Id,Client_Secret)



Access_Token_URL =	'https://www.googleapis.com/oauth2/v4/token'


d={}
d.client_id=Client_Id
d.client_secret=Client_Secret
d.refresh_token = refresh_token
d.grant_type='refresh_token'

local response = http.request {
	      url = Access_Token_URL, method = 'POST', 
	      data = d
        }

if response.statuscode == 200 then
  return json.parse(response.content).access_token
else
  log("Can't get access token, status = "..(response.statuscode or 'nil'))
  log(response.content)
  return nil 
end

end

function glib.addSheet(token,spreadsheetId,sheetname)

prefix='https://sheets.googleapis.com/v4/spreadsheets/'

ep=prefix..spreadsheetId

headers={["Authorization"] = "Bearer " .. token}
p={}
p.valueInputOption='USER_ENTERED'

template=[[
{
	"requests": [{
		"addSheet": {
			"properties": {
				"title": "title"

			}
		}
	}]
}
]]
r=json.parse(template)
r.requests[1].addSheet.properties.title=sheetname
d=(json.stringify(r))
local r=http.request{url=ep..':batchUpdate',method='post',headers=headers,data=d}

 

return
end

function glib.deleteSheet(token,spreadsheetId,sheetname)

prefix='https://sheets.googleapis.com/v4/spreadsheets/'

ep=prefix..spreadsheetId

headers={["Authorization"] = "Bearer " .. token}
--[[

Need to get SheetId to delete a Sheet
GET https://sheets.googleapis.com/v4/spreadsheets/spreadsheetId?&fields=sheets.properties
--]]
local r=http.request{url=ep,method='get',headers=headers,params={['fields']='sheets.properties'}}
sheets=json.parse(r.content).sheets
for _,v in ipairs(sheets) do
  if v.properties.title == sheetname then
  	sheetId=v.properties.sheetId
  end
 end
if not sheetId then return end
template=[[
{
  "requests": [
    {
      "deleteSheet": {
        "sheetId": "sheetId"
      }
    }
  ]
}
]]
r=json.parse(template)
r.requests[1].deleteSheet.sheetId=sheetId

d=(json.stringify(r))
local r=http.request{url=ep..':batchUpdate',method='post',headers=headers,data=d}
 

return
end

function glib.clearSheet(token,spreadsheetId,sheetname)

prefix='https://sheets.googleapis.com/v4/spreadsheets/'

ep=prefix..spreadsheetId

headers={["Authorization"] = "Bearer " .. token}
--[[

Need to get SheetId to clear a Sheet
GET https://sheets.googleapis.com/v4/spreadsheets/spreadsheetId?&fields=sheets.properties
--]]
local r=http.request{url=ep,method='get',headers=headers,params={['fields']='sheets.properties'}}
if r.statuscode ~= 200 then
  log(r.statuscode or 'nil')
  log(r.content)
  os.exit(0)
end
  sheets=json.parse(r.content).sheets
for _,v in ipairs(sheets) do
  if v.properties.title == sheetname then
  	sheetId=v.properties.sheetId
  end
 end
if not sheetId then return end
template=[[
{
  "requests": [
    {
      "updateCells": {
        "range": {
          "sheetId": "sheetId"
        },
        "fields": "userEnteredValue"
      }
    }
  ]
}
]]
r=json.parse(template)
r.requests[1].updateCells.range.sheetId=sheetId

d=(json.stringify(r))
local r=http.request{url=ep..':batchUpdate',method='post',headers=headers,data=d}
 

return
end

function glib.appendRows(token,spreadsheetId,sheet,rows)

prefix='https://sheets.googleapis.com/v4/spreadsheets/'

ep=prefix..spreadsheetId

headers={["Authorization"] = "Bearer " .. token}
p={}
p.valueInputOption='USER_ENTERED'

--/append/Sheet1
--[[
{
   "values": [
["Elizabeth", "2", "0.5", "60"],
["Margaret", "1", "1.5", "60"],
["Code", "Description",	"UID", "URI", "RowVersion"]
]
}
--]]
 
v={}
v['values']=rows
d=json.stringify(v)

local r=http.request{url=ep..'/values/'..sheet..':append',method='post',headers=headers,data=d,params=p}
--log(r.content)
return
end

return glib
