--[[
    LUA library for webscript.io
    Many/most of this functions have been copied without attribution from public websites etc.
    If you ae the author and want attribution then please let me know at csteddy at petaplex dot com.
--]]
lib = {}
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
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      lib.tprint(v, indent+1)
    else
      print(formatting .. tostring(v))
    end
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

function lib.datetimestamp(offset)
local gmt = os.time()
local awst = gmt + offset*60*60  --GMT +/-
local today = os.date("*t", awst)
local hhmm = string.format("%02d:%02d", today.hour, today.min)

timestamp = (today.day..'/'..today.month..'/'..today.year..' | '..string.format("%02d:%02d", today.hour, today.min))
log('Script ran at '..timestamp)
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

return lib
