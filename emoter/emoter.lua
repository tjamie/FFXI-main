--lolwut

_addon.name = 'emoter'
_addon.author = 'Myrchee'
_addon.version = '1.0'
_addon.commands = {'emoter', 'em'}

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

emote = ''
continue = 0

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			continue = 1
			-- TODO: check if an emote has been set
			EmoteSpammer()
		elseif cmd:lower() == 'set' then
			emote = args[2]
			windower.add_to_chat(2,'New emote set: '..emote)
		elseif cmd:lower() == 'stop' then
			windower.add_to_chat(2,'Stopping.')
			continue = 0
		end
	end
end)

function EmoteSpammer()
	while continue == 1 do
		windower.send_command('input /'..emote..' motion')
		coroutine.sleep(2)
	end
end