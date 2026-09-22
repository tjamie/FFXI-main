_addon.name = 'examination'
_addon.author = 'Myrchee'
_addon.version = '1.0'
_addon.command = 'examination'

require('logger')
require('strings')
require('tables')
require('lists')
require('sets')
require('maths')
require('functions')
require('chat')
res = require('resources')
packets = require('packets')

local responses = {
	"feels examined.",
	"is examined by a sussy baka.",
	"is examined... OwO what's this?",
	"feels examined by the CIA.",
	"gets examined by someone who's probably wearing binoculars.",
	"is examined and likes it.",
	"prepares a restraining order.",
}

windower.register_event('incoming text', function(original, modified, mode, blocked)
    if original:find('examines you.') then
		local response = responses[math.random(#responses)]
        windower.chat.input("/em "..response)
		local response = nil
    end
end)