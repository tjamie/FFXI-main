-- work in progress obvs

_addon.name = 'Easy STF'
_addon.author = 'Myrchee'
_addon.verion = '0.0.1'
_addon.command = 'stf'

require('logger')
require('strings')
require('tables')
require('lists')
require('sets')
require('maths')
require('functions')
require('chat')
resources = require('resources')
packets = require('packets')

cc = 2

windower.register_event('addon command', function(...)
	local args = T{...}
    local cmd = args[1] --table index starts at 1 because this language is cursed
	if cmd then 
		if cmd:lower() == 'test' then
            get_info()
        elseif (cmd:lower() == 'report') and (#args > 3) then
            local player = args[2]
            local area = args[3]
            local reason = args[4]
            if area_names[area:lower()] and report_reasons[reason:lower()] then
                report(player, area, reason)
            else
                windower.add_to_chat(cc, "Invalid area and/or reason")
            end
        else
            windower.add_to_chat(cc, "Invalid or not enough arguments.")
            windower.add_to_chat(cc, "Format: //stf report player area reason")
        end
	end
end)

report_reasons = T{
    ["rmt"] = "User+is+using+a+bot+to+spam+mercenary+advertisements+for+RMT+purposes",
    ["rmt-alt"] = "User+is+associated+with+a+character+that+is+spamming+mercenary+advertisements+for+RMT+purposes"
}

area_names = T{
    ["norg"] = "Norg",
    ["kazham"] = "Kazham",
    ["selbina"] = "Selbina",
    ["mhaura"] = "Mhaura",
    ["ssandoria"] = "Southern+San+d'Oria",
    ["nsandoria"] = "Northern+San+d'Oria",
    ["psandoria"] = "Port+San+d'Oria",
    ["bastokmine"] = "Bastok+Mines",
    ["bastokmark"] = "Bastok+Markets",
    ["portbastok"] = "Port+Bastok",
    ["metalworks"] = "Metalworks",
    ["windwoods"] = "Windurst+Woods",
    ["windwalls"] = "Windurst+Walls",
    ["windwaters"] = "Windurst+Waters",
    ["portwind"] = "Port+Windurst",
    ["eschazitah"] = "Escha+-+Zi'Tah",
    ["escharuaun"] = "Escha+-+Ru'Aun",
    ["reisenjima"] = "Reisenjima"
}

function report(player, area, reason)
    local info = get_info()
    local player = string.upper(string.sub(player, 1, 1)) .. string.sub(player, 2)
    windower.add_to_chat(cc, "date: " .. info.month .. "-" .. info.day .. "   server: " .. info.server)
    windower.add_to_chat(cc, "player: " .. player)
    windower.add_to_chat(cc, "area: " .. area_names[area:lower()])
    windower.add_to_chat(cc, "reason: " .. reason)
    windower.add_to_chat(cc, "reason verbose: " .. report_reasons[reason:lower()])

    local url_month = "&date1=" .. info.month
    local url_day = "&date2=" .. info.day
    local url_server = "&ffxi_world=" .. info.server
    local url_area = "&ffxi_area=" .. area_names[area:lower()]
    local url_player = "&rep_character_name=" .. player
    local url_details = "&details=" .. report_reasons[reason:lower()]

    -- HTTP setup
    local http = require("socket.http")
    local ltn12 = require("ltn12")

    local form_url = "https://support.na.square-enix.com/form.php"
    local form_data = "fo=18&id=20&la=1&p=0" .. url_month .. url_day .. url_server .. url_area .. url_player .. url_details
    local request_url = form_url .. "?" .. form_data
    -- windower.add_to_chat(cc, "POST URL: " .. report_url)
    -- windower.add_to_chat(cc, "Sending POST request...")

    -- HTTP request
    local response_body, status_code, response_headers = http.request{
        url = form_url .. "?" .. form_data,
        method = "POST",
        headers = {
            -- ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Content-Length"] = 0
        },
    }
    windower.add_to_chat(cc, "Response code " .. status_code)

end

function get_info()
    local info = windower.ffxi.get_info()
    local server = resources.servers[info.server].en

    local os = require('os')
    local month = os.date('%m')
    local day = os.date('%d')

    local info_out = {
        month = month,
        day = day,
        server = server
    }

    return info_out

end

function test_request()
    local http = require('socket.http')
    local url = 'https://google.com'
    local body, statusCode, headers, statusText = http.request(url)

    if statusCode == 200 then
        windower.add_to_chat(cc, 'status code ' .. statusCode)
        windower.add_to_chat(cc, 'body: ' .. body)
    end
end