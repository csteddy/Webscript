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
function istable(t) return type(t) == 'table' end

-- Function to print/log the
-- contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    else
      print(formatting .. tostring(v))
    end
  end
end
return lib
