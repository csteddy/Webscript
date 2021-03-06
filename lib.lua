--[[
    LUA library for webscript.io
    Many/most of this functions have been copied without attribution from public websites etc.
    If you are the author and want attribution then please let me know at csteddy at petaplex dot com.
--]]
lib = {}

function lib.callout(req_url,req_method,req_params,req_data)

return http.request {
	      url = req_url, method = req_method, 
	      headers = req_headers, 
	      params = req_params,
		    data = req_data
        }

end

function lib.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function lib.to_Dd(latlon)
-- Latitude and Longitude are in DM.m - 3200.7308S 11545.8208E
-- Convert to D.d
local lat,ns,lon,ew,dpos,minutes,degrees,latDd,lonDd
	
lat, ns, lon, ew = string.match(latlon, '(.*)%s*(%a)%s*(.*)%s*(%a)')
--log(lat,ns,lon,ew)
--find decimal point
    dpos = lat:find('%.')
	  if (dpos == nil) then
		  lat = lat.."."
		  dpos = #lat
		end
    minutes = (lat:sub(dpos-2,-1))/60
	  degrees = lat:sub(1,dpos-3)
	  latDd = degrees + minutes
	  if(ns == 'S') then 
			latDd = -latDd
		end
--find decimal point
    dpos = lon:find('%.')
	  if (dpos == nil) then
		  lon = lon.."."
		  dpos = #lon
		end
    minutes = (lon:sub(dpos-2,-1))/60
	  degrees = lon:sub(1,dpos-3)
	  lonDd = degrees + minutes
	  if(ns == 'W') then 
			lonDd = -lonDd
		end
return latDd,lonDd

end

-- Function to return the URL encoded version of the specified string
function lib.url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

-- Function to return true if argument is of type table and false otherwise
function lib.istable(t) return type(t) == 'table' end

-- Function to print/log the
-- contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function lib.tprint (tbl, indent)
  if not indent then indent = 0 end
  local k,v
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      lib.tprint(v, indent+1)
    else
      print(formatting .. tostring(v))
    end
  end
return  
end

function lib.pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
end

function lib.fill(str)
	if str == nil then
		return ''
	else
		return str
	end
end

function lib.pdate(s)
p="%a+, (%d+) (%a+) (%d+)"
day,month,year=s:match(p)
MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
month=MON[month]
return lib.Date(year.."-"..month.."-"..day)
end

-- Function to log current date time

function lib.datetimestamp(offset,msg)
offset = offset or 8
msg = msg or 'Script ran at '
local gmt = os.time()
local awst = gmt + offset*60*60  --GMT +/-
local today = os.date("*t", awst)
local hhmm = string.format("%02d:%02d", today.hour, today.min)

timestamp = (today.day..'/'..today.month..'/'..today.year..' | '..string.format("%02d:%02d", today.hour, today.min))
log(msg..timestamp)
return
end

local meta ={}

function lib.Date(str)
-- Create a Date object of the form yyyy-mm-dd
	local p ="(%d+)%-(%d+)%-(%d+)"
  local datestring = {}
	
	datestring.year, datestring.month, datestring.day = string.match(str, p)
	datestring.osdate = os.time(datestring)
	datestring.wday = tonumber(os.date("%w",datestring.osdate)) -- [0-6 = Sunday-Saturday]
	datestring.str = str
	setmetatable(datestring,meta)
	return datestring
end

function meta.__lt(date1,date2)
-- compare two dates in the format yyyy-mm-dd
	return date1.osdate < date2.osdate
end

function meta.__le(date1,date2)
-- compare two dates in the format yyyy-mm-dd
	return date1.osdate <= date2.osdate
end 

function meta.__eq (date1,date2)
	-- compare two dates in the format yyyy-mm-dd
  return date1.osdate <= date2.osdate and date2.osdate <= date1.osdate
end

function meta.__add(lhs,rhs)
	-- add days to a data object
	-- right hand side must be the number
	assert(type(rhs)=='number','RHS of add not a number')
	local datestring = {}
	local osdate = lhs.osdate + (24*60*60*rhs)
	temp = os.date("*t", osdate)
	datestring.year = tostring(temp.year)
	datestring.month = tostring(temp.month)
	datestring.day = tostring(temp.day)
	datestring.wday = temp.wday - 1 -- convert  [0-6 = Sunday-Saturday]
	datestring.osdate = osdate
	datestring.str = datestring.year..'-'..datestring.month..'-'..datestring.day
	setmetatable(datestring,meta)
	return datestring
end

function lib.ispublicholiday(date)
--[[
Checks for Western Australian public holidays
https://publicholidays.com.au/western-australia/2019-dates/
--]]	
holidays ={}

holidays['1/1/2014'] = "New Year's Day"
holidays['27/1/2014'] = "Australia Day"	
holidays['3/3/2014'] = "Labour Day" 
holidays['18/4/2014'] = "Good Friday"
holidays['21/4/2014'] = "Easter Monday"
holidays['25/4/2014'] = "Anzac Day"
holidays['2/6/2014'] = "Western Australia Day"
holidays['29/9/2014'] = "Queen's Birthday"
holidays['25/12/2014'] = "Christmas Day"
holidays['26/12/2014'] = "Boxing Day"
holidays['1/1/2015'] = "New Year's Day"
holidays['26/1/2015'] = "Australia Day"	
holidays['2/3/2015'] = "Labour Day" 
holidays['3/4/2015'] = "Good Friday"
holidays['6/4/2015'] = "Easter Monday"
holidays['27/4/2015'] = "Anzac Day"
holidays['1/6/2015'] = "Western Australia Day"
holidays['28/9/2015'] = "Queen's Birthday"
holidays['25/12/2015'] = "Christmas Day"
holidays['28/12/2015'] = "Boxing Day"
holidays['1/1/2016'] = "New Year's Day"
holidays['26/1/2016'] = "Australia Day"	
holidays['7/3/2016'] = "Labour Day" 
holidays['25/3/2016'] = "Good Friday"
holidays['28/3/2016'] = "Easter Monday"
holidays['25/4/2016'] = "Anzac Day"
holidays['6/6/2016'] = "Western Australia Day"
holidays['26/9/2016'] = "Queen's Birthday"
holidays['26/12/2016'] = "Christmas Day"
holidays['27/12/2016'] = "Boxing Day"
holidays['2/1/2017'] = "New Year's Day"
holidays['26/1/2017'] = "Australia Day"	
holidays['6/3/2017'] = "Labour Day" 
holidays['14/4/2017'] = "Good Friday"
holidays['17/4/2017'] = "Easter Monday"
holidays['25/4/2017'] = "Anzac Day"
holidays['5/6/2017'] = "Western Australia Day"
holidays['26/9/2017'] = "Queen's Birthday"
holidays['25/12/2017'] = "Christmas Day"
holidays['26/12/2017'] = "Boxing Day"

holidays['1/1/2018'] = "New Year's Day"
holidays['26/1/2018'] = "Australia Day"	
holidays['5/3/2018'] = "Labour Day" 
holidays['30/3/2018'] = "Good Friday"
holidays['2/4/2018'] = "Easter Monday"
holidays['25/4/2018'] = "Anzac Day"
holidays['4/6/2018'] = "Western Australia Day"
holidays['1/10/2018'] = "Queen's Birthday"
holidays['25/12/2018'] = "Christmas Day"
holidays['26/12/2018'] = "Boxing Day"

holidays['1/1/2019'] = "New Year's Day"
holidays['28/1/2019'] = "Australia Day"	
holidays['4/3/2019'] = "Labour Day" 
holidays['19/4/2019'] = "Good Friday"
holidays['22/4/2019'] = "Easter Monday"
holidays['25/4/2019'] = "Anzac Day"
holidays['3/6/2019'] = "Western Australia Day"
holidays['23/9/2019'] = "Queen's Birthday"
holidays['25/12/2019'] = "Christmas Day"
holidays['26/12/2019'] = "Boxing Day"

-- normalise date
	p ="(%d+)[-/](%d+)[-/](%d+)"
  x1,x2,x3 = string.match(date, p)
	
-- year will be x1 or x3
-- day will be x1 or x3
-- month will be x2 (numeric or alpha)
if tonumber(x1) > 1000 then
		year = x1
		day = x3
else
		year = x3
		day = x1
end

if not tonumber(x2) then
	MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
	month=MON[x2]
else
	month = x2
end			

return holidays[tostring(day)..'/'..tostring(month)..'/'..tostring(year)]
end

function lib.haversine(pt1, pt2)

--[[
	A function to return the distance in Kms between two points.

	Usage:


	pt1={}; pt1.lat = -31.943068; pt1.lon = 115.879925
	pt2={}; pt2.lat = -32.1058824;pt2.lon = 115.810732

	print(haversine(pt1,pt2))


--]]
	local R = 6371; --km radius of the earth
	local lat1=math.rad(pt1.lat)
	local lat2=math.rad(pt2.lat)
	local latDelta = math.rad(pt2.lat-pt1.lat)
	local lonDelta = math.rad(pt2.lon-pt1.lon)

	local a = math.sin(latDelta/2) * math.sin(latDelta/2) + math.cos(lat1) * math.cos(lat2) * math.sin(lonDelta/2) * math.sin(lonDelta/2)
	local c = 2 * math.atan2(math.sqrt(a) , math.sqrt(1-a))
	local d = R * c

	return d
end

return lib
