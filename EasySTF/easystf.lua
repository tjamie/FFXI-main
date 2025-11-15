--[[
Copyright © 2025, Myrchee of Quetzalcoatl & Bahamut
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <addon name> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = "Easy STF"
_addon.author = "Myrchee"
_addon.verion = "0.0.1"
_addon.commands = {"stf", "easystf"}

require("logger")
require("strings")
require("tables")
require("lists")
require("sets")
require("maths")
require("functions")
require("chat")
resources = require("resources")
packets = require("packets")

cc = 2

windower.register_event("addon command", function(...)
	local args = T{...}
    local cmd = args[1]
	if cmd then 
		if cmd:lower() == "help" then
            help()
        elseif cmd:lower() == "listareas" then
            list_areas()
        elseif cmd:lower() == "listreasons" then
            list_reasons()
        elseif (cmd:lower() == "report") and (#args > 3) then
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

help_commands = T{
    [1] = "help - Displays the list of commands available in this addon.",
    [2] = "listareas - Displays the list of areas and their truncated names that are currently implemented.",
    [3] = "listreasons - Displays the list of reporting justifications that are currently implemented.",
    [4] = [[report - Report player to the Special Task Force. Syntax is as follows:
        //stf report Playername Area Reason
        e.g., //stf report Johnfinalfantasy BastokMark rmt
        Multiple characters can be reported at once by separating each name by a comma (",").
        e.g., //stf report Johnfinalfantasy,Janefinalfantasy,Timfinalfantasy Area Reason]]
}

report_reasons = T{
    ["rmt"] = "User+is+using+a+bot+to+spam+mercenary+advertisements+for+RMT+purposes",
    ["rmt-alt"] = "User+is+associated+with+a+character+that+is+spamming+mercenary+advertisements+for+RMT+purposes",
    ["multibox"] = "User+is+using+a+bot+to+use+several+characters+simultaneously",
    ["multibox-exp"] = "User+is+using+a+bot+to+use+several+characters+simultaneously+in+order+to+automate+experience+points+farming",
    ["bot-general"] = "User+is+using+a+bot+to+automate+content",
    ["bot-rmt"] = "User+is+using+a+bot+to+farm+items+for+RMT+purposes"
}

area_names = T{
    -- towns and cities
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
    ["whitegate"] = "Aht+Urghan+Whitegate",
    ["alzahbi"] = "Al+Zahbi",
    -- outdoor areas 
    -- Aht Urghan
    ["bhafthicket"] = "Bhaflau+Thickets",
    ["mamook"] = "Mamook",
    ["wajaom"] = "Wajaom Woodlands",
    ["aydeewa"] = "Aydeewa Subterrane",
    -- Rhapsodies
    ["eschazitah"] = "Escha+-+Zi'Tah",
    ["escharuaun"] = "Escha+-+Ru'Aun",
    ["reisenjima"] = "Reisenjima",
}

function sort_keys(in_table)
    local keys = {}
    for k in pairs(in_table) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

function help()
    -- force output to be printed in order
    local help_keys = sort_keys(help_commands)

    windower.add_to_chat(cc, "\n[EasySTF] Available commands:")
    for _,key in ipairs(help_keys) do
        windower.add_to_chat(cc, "    " .. help_commands[key])
    end
    windower.add_to_chat(cc, " ")
end

function list_areas()
    local area_keys = sort_keys(area_names)

    windower.add_to_chat(cc, "\n[EasySTF] Currently supported zones:")
    for _,key in ipairs(area_keys) do
        local area_clean = string.gsub(area_names[key], "+", " ")
        windower.add_to_chat(cc, "    " .. key .. " - " .. area_clean)
    end
    windower.add_to_chat(cc, " ")
end

function list_reasons()
    local reason_keys = sort_keys(report_reasons
)
    windower.add_to_chat(cc, "\n[EasySTF] Currently supported justifications:")
    for _,key in ipairs(reason_keys) do
        local reason_clean = string.gsub(report_reasons[key], "+", " ")
        windower.add_to_chat(cc, "    " .. key .. " - " .. reason_clean)
    end
    windower.add_to_chat(cc, " ")
end

function report(player, area, reason)
    local info = get_info()
    local player = string.upper(string.sub(player, 1, 1)) .. string.sub(player, 2)
    windower.add_to_chat(cc, "date: " .. info.month .. "-" .. info.day .. "   server: " .. info.server)
    windower.add_to_chat(cc, "player: " .. player)
    windower.add_to_chat(cc, "area: " .. string.gsub(area_names[area:lower()], "+", " "))
    windower.add_to_chat(cc, "reason: " .. reason)
    windower.add_to_chat(cc, "reason verbose: " .. string.gsub(report_reasons[reason:lower()], "+", " "))

    local url_month = "&date1=" .. info.month
    local url_day = "&date2=" .. info.day
    local url_server = "&ffxi_world=" .. info.server
    local url_area = "&ffxi_area=" .. area_names[area:lower()]
    local url_player = "&rep_character_name=" .. player
    local url_details = "&details=" .. report_reasons[reason:lower()]
    local url_form_type = function(reason)
        if reason:lower() == "rmt" or reason:lower() == "rmt-alt" then
            return "fo=18&id=20&la=1&p=0"
        else
            -- ie, non-rmt botting that's obnoxious
            return "fo=17&id=20&la=1&p=0"
        end
    end

    -- HTTP setup
    local http = require("socket.http")
    local ltn12 = require("ltn12")

    local form_url = "https://support.na.square-enix.com/form.php"
    local form_data = url_form_type(reason) .. url_month .. url_day .. url_server .. url_area .. url_player .. url_details
    local request_url = form_url .. "?" .. form_data

    -- HTTP request
    local response_body, status_code, response_headers = http.request{
        url = form_url .. "?" .. form_data,
        method = "POST",
        headers = {
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