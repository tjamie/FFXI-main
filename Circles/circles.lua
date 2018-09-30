--lolwut

_addon.name = 'circles'
_addon.author = 'Myrchee'
_addon.version = '1.0'
_addon.command = 'circles'

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

continue = 0

--ru'lude gardens
waypoints = T{
	[1] = {x = 30, y = -6},
	[2] = {x = -27, y = -6},
	[4] = {x = -27, y = -73},
	[3] = {x = 30, y = -73}
}

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			continue = 1
			coroutine.sleep(1)
		elseif cmd:lower() == 'stop' then
			windower.add_to_chat(2,'Stopping.')
			continue = 0
		end
	end
	
	while continue == 1 do
	 RunCircles()
	end
end)

function RunCircles()
	--start near waypoints[1]
	--local player = windower.ffxi.get_mob_by_target('me')
	--local vecPlayer = UpdatePlayerPosition()
	local vecPlayer
	local vecWaypoint
	local dist
	
	for i,v in pairs(waypoints) do
		vecWaypoint = {x = v.x, y = v.y}
		dist = 9999
		while (dist > 4) and (continue == 1) do
			vecPlayer = UpdatePlayerPosition()
			dist = GetDistance(vecPlayer, vecWaypoint)
			GoToWaypoint(vecPlayer,vecWaypoint)
			coroutine.sleep(1)
			windower.ffxi.run(false)
		end
				
	end
	
end

function GetDistance(player, location)
	return math.sqrt((location.x - player.x)^2 + (location.y - player.y)^2)
end

function UpdatePlayerPosition()
	local player = windower.ffxi.get_mob_by_target('me')
	vecPlayer = {x = player.x, y = player.y}
	return vecPlayer
end

function GoToWaypoint(player, location)
	if continue == 1 then
		coroutine.sleep(0.1)
		local angle = GetAngle(player,location)
		--windower.ffxi.turn(angle)
		windower.ffxi.run(angle)
	end
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	--print("angle: "..angle.." "..angle/math.pi)
	return angle
end