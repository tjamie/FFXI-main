--[[
Don't get banned :)
This currently assumes that nothing is claimed by other players because I'm lazy and you shouldn't
be using this around other people anyway.
]]--

_addon.name = 'magiantrials'
_addon.author = 'Myrchee'
_addon.verion = '1.8.3'
_addon.command = 'mtrial'

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

debug = false

-- chat color index
cc = 2
-- max attack distance (yalms)
atkd = 3
-- min distance
dmin = 1
-- Required target name
target = 'Pasture Funguar'
-- WS required
ws = 'Savage Blade'
-- enemy HPP for WS
threshold = 70

continue = false

-- events
windower.register_event('addon command', function(...)
	local args = T{...}
	local cmd = args[1]
	if cmd then
		if cmd:lower() == 'start' then
			continue = true
			windower.send_command('input /autotarget off')
			coroutine.sleep(1)
			Trial()
		elseif cmd:lower() == 'stop' then
			windower.add_to_chat(cc, 'Stopping mtrial')
			continue = false
		elseif cmd:lower() == 'threshold' then
			threshold = tonumber(args[2])
			windower.add_to_chat(cc, 'New threshold: '..threshold)
		elseif cmd:lower() == 'target' then
			if args[3] then
				target = args[2]..' '..args[3]
			else
				target = args[2]
			end
			windower.add_to_chat(cc, 'New target: '..target)
		elseif cmd:lower() == 'dmin' then
			dmin = tonumber(args[2])
			windower.add_to_chat(cc, 'New minimum attack distance:  '..dmin)
		elseif cmd:lower() == 'dmax' then
			atkd = tonumber(args[2])
			windower.add_to_chat(cc, 'New maximum attack distance: '..atkd)
		elseif cmd:lower() == 'debug' then
			if debug then
				debug = false
				windower.add_to_chat(cc, 'Debug mode disabled.')
			else
				debug = true
				windower.add_to_chat(cc, 'Debug mode enabled.')
			end
		end
	end
end)

windower.register_event('zone change', function(new_id, old_id)
	if continue then
		continue = false
		windower.add_to_chat(2, 'Area changed -- stopping magiantrials')
	end
end)
-- events end

function Trial()
	if debug then
		windower.add_to_chat(cc, 'Starting Trial()')
	end
	
	while continue do
		local player = windower.ffxi.get_mob_by_target('me')
		--tar_id = GetClosestMob()
		--local mob = windower.ffxi.get_mob_by_id(tar_id)
		--local d = 99999
		
		local mob = windower.ffxi.get_mob_by_id(GetClosestMob())
		
		if mob.id ~= player.id then
			-- Move to target range (i.e., start of line 124 in ver 1.2)
			GoToTarget(mob.id)
			-- Turn to target and engage (i.e., start of line 139 in ver. 1.2)
			mob = windower.ffxi.get_mob_by_id(GetClosestMob())
			if (mob.hpp > 0) and (mob.valid_target) then
				Battle(mob.id)
			end
		end

		coroutine.sleep(1)
	end
end

function Battle(tar_id)
	if debug then
		windower.add_to_chat(cc, 'Starting Battle('..tar_id..')')
	end
	
	local mob = windower.ffxi.get_mob_by_id(tar_id)
	local player = windower.ffxi.get_mob_by_target('me')
	local posTar = {x = mob.x, y = mob.y}
	local posPlayer = {x = player.x, y = player.y}
	
	while (player.status == 0) and (mob.hpp > 0) and (mob.distance < 400) and (mob.valid_target) and (continue) do
		if debug then
			windower.add_to_chat(cc, 'Attempting to engage ID '..tar_id)
		end
		Engage(tar_id)
		mob = windower.ffxi.get_mob_by_id(tar_id)
		player = windower.ffxi.get_mob_by_target('me')
		coroutine.sleep(2)
	end
	
	--- fight after engagement
	while (mob.hpp > 0) and (mob.valid_target) and (continue) do
		if debug then
			windower.add_to_chat(cc, 'Fighting ID '..tar_id)
		end
		mob = windower.ffxi.get_mob_by_id(tar_id)
		player = windower.ffxi.get_mob_by_target('me')
		posTar = {x = mob.x, y = mob.y}
		posPlayer = {x = player.x, y = player.y}
		
		FaceTarget(posPlayer, posTar)
		
		if math.sqrt(mob.distance) > atkd then
			ApproachTarget(posPlayer, posTar)
			coroutine.sleep(0.2)
			windower.ffxi.run(false)
		elseif math.sqrt(mob.distance) < dmin then
			Backup(posPlayer, posTar)
			coroutine.sleep(0.5)
			windower.ffxi.run(false)
		end

		if (math.sqrt(mob.distance) < atkd) and (mob.hpp < threshold) and (windower.ffxi.get_player().vitals.tp > 999) then
			if debug then
				windower.add_to_chat(cc, 'Using '..ws..'on ID '..tar_id)
			end
			windower.send_command('input /ws \"'..ws..'\" <t>')
		end
		coroutine.sleep(1)
	end
end

function GoToTarget(tar_id)
	-- Move to target, turn when in range, engage
	local d = 99999
	local mob = windower.ffxi.get_mob_by_id(tar_id)
	local player = windower.ffxi.get_mob_by_target('me')
	local posTar = {x = mob.x, y = mob.y}
	local posPlayer = {x = player.x, y = player.y}
	coroutine.sleep(1)
	
	while (d > atkd) and (mob.hpp > 0) and (mob.valid_target) and (continue) do
		-- Update position info with closest target
		mob = windower.ffxi.get_mob_by_id(GetClosestMob())
		player = windower.ffxi.get_mob_by_target('me')
		posTar = {x = mob.x, y = mob.y}
		posPlayer = {x = player.x, y = player.y}
		
		ApproachTarget(posPlayer, posTar)
		if debug then
			windower.add_to_chat(cc, 'Going to '..mob.x..', '..mob.y..' ID '..mob.id)
		end
		coroutine.sleep(1)
		windower.ffxi.run(false)
		d = math.sqrt(windower.ffxi.get_mob_by_id(mob.id).distance)
	end
end

function GetClosestMob()
	local player = windower.ffxi.get_mob_by_target('me')
	marray = windower.ffxi.get_mob_array()
	
	-- Prevent nil from popping up
	target_id = player.id
	
	local dist = 99999
	
	for i,v in pairs(marray) do
		if (v.name == target) and (v.hpp > 0) and (v.valid_target) then
			if v.distance < dist then
				dist = v.distance
				target_id = v.id
			end
		end
	end	
	
	if (debug) and (target_id ~= player.id) then
		local temp = windower.ffxi.get_mob_by_id(target_id)
		windower.add_to_chat(cc, 'Closest target ID '..temp.id..' ('..temp.name..')')
	end
	
	return target_id
end

function ApproachTarget(posPlayer, posTar)
	coroutine.sleep(0.1)
	local angle = GetAngle(posPlayer, posTar)
	windower.ffxi.run(angle)
	--windower.ffxi.run(posTar.x, posTar.y)	
end

function Backup(posPlayer, posTar)
	coroutine.sleep(0.1)
	local angle = GetAngle(posPlayer, posTar) - math.pi
	windower.ffxi.run(angle)
end

function FaceTarget(posPlayer, posTar)
	windower.ffxi.turn(GetAngle(posPlayer, posTar))
end

function checkHPP(threshold)
	local player = windower.ffxi.get_player()
	local cureThreshold = 60
	if (player.vitals.hpp < cureThreshold) then
		return true
	else
		return false
	end
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	--print("angle: "..angle.." "..angle/math.pi)
	return angle
end

function Engage(tar_id)
	if debug then
		windower.add_to_chat(cc, 'Starting Engage('..tar_id..')')
	end
	
	local player = windower.ffxi.get_mob_by_target('me')
	local mob = windower.ffxi.get_mob_by_id(tar_id)
	
	if (mob.id ~= player.id) and (mob.id ~= nil) then
		engage = packets.new('outgoing', 0x1a, {
		['Target'] = mob.id,
		['Target Index'] = mob.index,
		['Category']     = 0x02,
		})
		
		packets.inject(engage)
	end
end