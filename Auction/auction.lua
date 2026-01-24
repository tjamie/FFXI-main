_addon.name = "Auction Check"
_addon.author = "Myrchee"
_addon.verion = "1.0.0"
_addon.commands = {"auction", "ah"}

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
-- db = require("map") -- find a different solution with item ids...

cc = 2

-- !!!IMPORTANT -- ffxiah's sid for bahamut is 1

windower.register_event("addon command", function(...)
	local args = T{...}
    local cmd = args[1]
    args:remove(1) -- remove command from args array

    
    if cmd:lower() == "check" then
        -- get server
        local serverinfo = get_server_info
        local sid = serverinfo.sid

        -- convert item args to auto translate
        for i,v in pairs(args) do
            args[i]=windower.convert_auto_trans(args[i])
        end
	    local item = table.concat(args," "):lower()

        windower.add_to_chat(cc, item)
    end

    if cmd:lower() == "httptest" then
        local http = require("socket.http")
        local ltn12 = require("ltn12")
        local url = "https://ffxiah.com/item/9758"
        local cookie_value = "sid=1"

        local response = follow_redirect(url, cookie_value)
        
    end

    if cmd:lower() == "test" then
        local serverinfo = get_server_info()
        windower.add_to_chat(cc, serverinfo.server .. " (SID " .. serverinfo.sid .. ")" )
    end
end)

function get_server_info()
    local info = windower.ffxi.get_info()
    local sid = info.server
    local server = resources.servers[info.server].en

    info_out = {
        window_sid = sid,
        server = server,
        sid = 1 -- TODO change this. 1 is FFXIAH's id for bahamut
    }
    return info_out
end

function follow_redirect(start_url, custom_cookie)
    local http = require("socket.http")
    local https = require("ssl.https")
    local ltn12 = require("ltn12")
    local socket_url = require("socket.url")

    local function resolve_url(base, location)
        if location:match("^https?://") then
            return location
        end
        return socket_url.absolute(base, location)
        -- local parsed = socket_url.parse(base)
        -- return socket_url.build{
        --     scheme = parsed.scheme,
        --     host = parsed.host,
        --     port = parsed.port,
        --     path = location
        -- }
    end


    local current_url = start_url
    local max_redirects = 5
    for i = 1, max_redirects do
        local body_table = {}
        local status_code_msg
        
        -- Use simple interface for initial request
        -- For complex scenarios, use generic interface with sink
        local response = {}
        local success_code, status_code, headers = https.request{
            url = current_url,
            method = "GET",
            headers = {
                ["Cookie"] = custom_cookie,
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
            },
            sink = ltn12.sink.table(response),
            redirect = false
        }
        print("Iteration " .. i .. ", status " .. status_code)

        -- The status code message will be "301" for a 301 redirect
        if status_code == 301 or status_code == 302 then
            if headers["set-cookie"] then
                custom_cookie = headers["set-cookie"]
            end
            
            if headers.location then
                current_url = resolve_url(current_url, headers.location)
                windower.add_to_chat(cc, "Redirected to: " .. current_url)
            else
                windower.add_to_chat(cc, "Redirect received but no Location header found.")
                return nil, "No location header"
            end
        elseif status_code == 200 then
            -- Success, the result is in the returned string (for simple interface)
            local response_body = table.concat(response)
            windower.add_to_chat(cc, response_body)
            return response_body, nil
        else
            print("Received unexpected status code: " .. tostring(status_code))
            return nil, status_code
        end
    end
    return nil, "Max redirects exceeded"
end

function get_item_id(input)

end