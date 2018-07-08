_addon.name = 'targetpractice'
_addon.author = 'Myrchee'
_addon.version = '1.0'
--_addon.commands = {'targetpractice','tp','tpa'}
_addon.command = 'tp'

require('tables')
require('packets')
require('functions')
require('chat')

cc = 8 --chat color
delay = 0.001

mobInfo = {
    'name', --string
    'claim_id', --int
    'distance', --number
    'facing', --number
    'hpp', --int
    'id', -- int
    'is_npc', --bool
    'mob_type', --int
    'model_size', --number
    'speed', --number
    'speed_base', --number
    'race', --number
    'status', --int
    'index', --int
    'x', --number
    'y', --number
    'z', --number
    --target_index: number (only valid for PCs)
    --fellow_index: number (only valid for PCs)
    --pet_index: number  
    --tp: number  (only valid for pets - May not exist?)  
    --mpp: number  (only valid for pets - May not exist?)  
    'charmed', --bool
    'in_party', --bool
    'in_alliance', --bool
    'valid_target' --bool
}

mobDist = {
	'name',
	'id',
	'distance',
	'x',
	'y',
	'z'
}


mobBasic = {
	'name',
	'id'
}


windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1]
	local cmd2 = args[2]
	if cmd then 
		if cmd:lower() == 'mobarray' then
			if cmd2:lower() == 'dist' then
				mobarray(mobDist)
			elseif cmd2:lower() == 'basic' then
				mobarray(mobBasic)
			else
				mobarray(mobInfo)
			end
		elseif cmd:lower() == 'target' then
			if cmd2:lower() == 'dist' then
				targetinfo(mobDist)
			elseif cmd2:lower() == 'basic' then
				targetinfo(mobBasic)
			else
				targetinfo(mobInfo)
			end
		end
	end
end)



function mobarray(params)
	marray = windower.ffxi.get_mob_array()
	for i,v in pairs(marray) do
	--for i,v in pairs(windower.ffxi.get_mob_array()) do
		windower.add_to_chat(cc,'i = '..i)
		ArrayToChat(v, params)
		--ArrayToChat(marray[i], params)
		--coroutine.sleep(delay)
	end
end

function targetinfo(params)
	mob = windower.ffxi.get_mob_by_target('t')
	ArrayToChat(mob, params)
end

function ArrayToChat(arr, params)
	for arri,arrv in pairs(params) do
		if arr[arrv] then
			windower.add_to_chat(cc, arrv..': '..tostring(mob[arrv]))
		else
			windower.add_to_chat(cc, arrv..': false or DNE')
		end
	end
end