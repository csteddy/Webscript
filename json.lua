json = {}
local lunajson = require 'csteddy/lunajson/src/lunajson.lua'
function json.parse(str)
--log('new parse function')
return lunajson.decode(str)

end

function json.stringify(table)
--log('new serialise function')
return lunajson.encode(table)

end

return json
