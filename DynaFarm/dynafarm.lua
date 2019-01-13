--[[
Don't get banned. Or do.
]]


--windower.ffxi.get_mob_by_target('t').status => 0 = idle, 1 = attacking
--windower.ffxi.get_mob_by_target('t').claim_id => 0 = unclaimed, anything else = claimed
--claim_id = id of player with claim?
--so can do something like


--[[
mob = windower.ffxi.get_mob_by_target('t')
player = windower.ffxi.get_mob_by_target('me')
if mob.distance < 10 and mob.status = 1 and (mob.claim_id = player.id or mob.claim_id = 0){
	attack
}

to deal with non-target aggression
]]

--[[
for JA:
0 - 8 Byne Bills
8 - 16 Ordelle Bronzepieces
16 - 24 T Whiteshells
]]

--[[
Pre-release pseudo code
Note: add something to attack mobs attacking you regardless of ID

while (0 < time < 8){
	while (distance > byne area){
		RunTo(byne area)
	}
	while ( distance <= byne area && 0 < time < 8){
		Getmobs()
		while (targetMob = exists and targetMob.isValidTarget == true and targetMob.HP > 0){
			if (targetMob.distance > maxdistance){
				runTo(targetMob)
				NOTE: may need to add pos.x and pos.y restrictions for certain areas
					to prevent getting stuck
			}
			else if (targetMob.distance < mindistance){
				backUp(direction)
			}
			else{
				Fight(mob)
			}
		}
	}

}

Fight(mob){
	while (mob.HP > 0){
		if (mob.distance > max){
			runTo(mob)
			sleep(1)
		}
		if (mob.distance < min){
			runAway(mob)
			sleep(0.5)
		}
		if (step.ready == true){
			useStep(mob)
		}
	}
	
	sleep(0.5) //to hopefully prevent windower from crashing
}

]]

--time is stored in minutes, so 0 = 0:00, 480 = 08:00, 960 = 16:00

_addon.name = 'dyna'
_addon.author = 'Myrchee'
_addon.version = '0.1'
_addon.commands = {'dyna', 'dfarm'}

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

step = 'Quickstep'
stepTP = 100
stepID = 220

timeDelay = 0.1 --time for coroutine.sleep
wpDistance = 2 --proximity to waypoints required (in yalms)

continue = 0

jaTargets = T{
	[39] = T{ --Dynamis - Valkurm
		[0] = 'Nightmare Flytrap',
		[8] = 'Nightmare Hippogryph',
		[16] = 'Nightmare Treant'
		
	},
	[41] = T{ --Dynamis - Qufim
		[0] = 'Nightmare Kraken',
		[8] = 'Nightmare Snoll',
		[16] = 'Nightmare Tiger'
		
	}
}

--currency areas
wpCamps = T{
	[39] = T{-- Dynamis - Valkurm
		[0] = {x = -145, y = -110},
		[8] = {x = -267, y = -33},
		[16] = {x = -325, y = 63}
	},
	[41] = T{ --Dynamis - Qufim
		[0] = {x = 15, y = -75},
		[8] = {x = 19, y = 275},
		[16] = {x = 92, y = -170}
	}
}

wpStart = T{ --move from start to camps - will need to change when dynamis campaign isn't active
	[39] = T{ --Dynamis - Valkurm
		[1] = {x = 0, y = 0}
	},
	[41] = T{
		[1] = {x = 0, y = 0},
		[2] = {x = 0, y = 0}
	}
}

wp = T{ --waypoints for moving between camps
	[39] = T{ --Dynamis - Valkurm
		[0] = T{
			[1] = {x = 0, y = 0}
		},
		[8] = T{
			[1] = {x = 0, y = 0}
		},
		[16] = T{
			[1] = {x = 0, y = 0}
		}
	},
	[41] = T{ --Dynamis - Qufim
		[0] = T{ --0-8 to 8-16
			[1] = {x = 39, y = -165},
			[2] = {x = 88, y = 34},
			[3] = {x = 76, y = 82},
			[4] = {x = 120, y = 110},
			[5] = {x = 95, y = 161},
			[6] = {x = 64, y = 174},
			[7] = {x = 13, y = 252},
			[8] = {x = 21, y = 275}
		},
		[8] = T{ --8-16 to 16-24
			[1] = {x = 34, y = 270},
			[2] = {x = 60, y = 232},
			[3] = {x = 97, y = 160}
		},
		[16] = T{ --16-24 to 0-8
			[1] = {x = 113, y = 156},
			[2] = {x = 121, y = 115},
			[3] = {x = 77, y = 86},
			[4] = {x = 89, y = 23},
			[5] = {x = 11, y = -85}
		}
	}
}


trusts = T{
	[1] = 'Mayakov',
	[2] = 'Uka Totlihn',
	[3] = 'Koru-Moru',
	[4] = 'Kupipi',
	[5] = 'Apururu (UC)'
}

--event handlers
windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == 'start' then
			if ValidateLocation() == true then
				continue = 1
				MyMoneyAndINeedItNow()
			end
		elseif cmd:lower() == 'stop' then
			windower.add_to_chat(2,'Stopping.')
			continue = 0
		elseif cmd:lower() == 'stepper' then
			Step()
		end
	end
end)

windower.register_event('zone change', function(new_id, old_id)
	if continue == 1 then
		continue = 0
		windower.add_to_chat(2, 'Area changed -- stopping dynafarm')
	end
end)

--functions
function MyMoneyAndINeedItNow()
	--initialization to get to first camp from entrance
	i = 1
	local zone = windower.ffxi.get_info()['zone']
	local vecPlayer
	local vecWaypoint
	local dist
	
	sneakInvisible()
	
	while (i < #wpStart[zone]) and (continue == 1) do
		vecWaypoint = {x = wp[zone][i].x, y = wp[zone][i].y}
		dist = 9999
		--debug
		windower.add_to_chat(2,'Going to ['..i..'] -- '..wp[zone][i].x..', '..wp[zone][i].y)
		while (dist > wpDistance) and (continue == 1) do
			vecPlayer = UpdatePlayerPosition()
			dist = GetDistance(vecPlayer, vecWaypoint)
			GoToWaypoint(vecPlayer, vecWaypoint)
			coroutine.sleep(timeDelay)
			windower.ffxi.run(false)
			--coroutine.sleep(0.1)
		end
		i = i + 1
		--if i > iMax then
		--	i = 1
		--end
	end
	
	i = 1
	
	while (continue == 1) do
		
	end
	
	
end

function Step()
	local mob = windower.ffxi.get_mob_by_target('t')
	local tar_id = mob["id"]
	while (mob.hpp > 0) and (mob.valid_target == true) do
		mob = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_id(tar_id)
		if (windower.ffxi.get_player().vitals.tp > stepTP) then
			if isReady(stepID) == true then
				windower.send_command('input /ja \"'..step..'\" <t>')
			end
		end
		coroutine.sleep(1)
	end
end
function isReady(abilityID)
	if windower.ffxi.get_ability_recasts()[abilityID] > 0 then
		return false
	else
		return true
	end
end

function getHour()
	local currentTime = windower.ffxi.get_info()['time']
	if currentTime < 480
		return 0
	elseif currentTime < 960
		return 8
	else
		return 16
	end
end

function GoToWaypoint(player, location)
	if continue == 1 then
		local angle = GetAngle(player,location)
		windower.ffxi.run(angle)
	end
end

function GetAngle(playervec,mobvec)
	--radians
    angle = (math.atan2(playervec.y-mobvec.y, playervec.x-mobvec.x) * -1) + math.pi
	--print("angle: "..angle.." "..angle/math.pi)
	return angle
end

function summon(trustList)
	local castDelay = 6
	for i = 1,#trustList,1 do
		windower.ffxi.send_command('input /ma \"'..trustList[i]..'\" <me>')
		coroutine.sleep(castDelay)
	end
end

function sneakInvisible()
	local castDelay = 4
	windower.ffxi.send_command('input /ja \"Spectral Jig\" <me>')
	coroutine.sleep(castDelay)
end

function UpdatePlayerPosition()
	local player = windower.ffxi.get_mob_by_target('me')
	vecPlayer = {x = player.x, y = player.y}
	return vecPlayer
end

function ValidateLocation()
	local zone = windower.ffxi.get_info()['zone']
	local player = windower.ffxi.get_mob_by_target('me')
	
	if wp[zone] ~= nil then
		vecStart = wp[zone][1]
		windower.add_to_chat(2,'Validated')
		return true
	else
		windower.add_to_chat(2,'Current zone not currently implemented.')
		return false
	end
end


--[[
function GetClosestMob()
	local player = windower.ffxi.get_mob_by_target('me')
	marray = windower.ffxi.get_mob_array()
	
	--just to prevent returning a nil value
	target_id = player.id
	
	local dist = 99999
	
	for i,v in pairs(marray) do
		if (v["name"] == target or v["name"] == target2 or v["name"] == target3 or v["name"] == target4) and (v["hpp"] > 0) and (v["valid_target"] == true) then
			if v["distance"] < dist then
				dist = v["distance"]
				mobname = v["name"]
				--mobx = v["x"]
				--moby = v["y"]
				target_id = v["id"]
			end
		end
	end
	
	
	return target_id
end
]]

--[[ to get step IDs
function Recasts()
	local rTable = windower.ffxi.get_ability_recasts()
	for i,v in pairs(rTable) do
		windower.add_to_chat(2,'i: '..i..' recast: '..v)
	end
end
]]