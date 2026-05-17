local function CRASH()
    local p = game.Players.LocalPlayer
    if p then
        p:Kick("An unexpected error occurred. [0x" .. string.format("%X", math.random(0x1000, 0xFFFF)) .. "]")
    end
    while true do wait(9e9) end
end

script_key = script_key or _G.script_key or "nil"
website = "https://cumarmor.vercel.app"

local jmp_counter = 0

-- Объявляем переменные до pcall чтобы они были доступны снаружи
local valid = false
local valid2 = false
local valid3 = true

do -- Anti Hooks
    jmp_counter += 1
end

pcall(function()
    do -- Functions / Encoding
        function encode_string(s) return s end
        function decode_string(s) return s end

        function split(str, sep)
            local result = {}
            local regex = ("([^%s]+)"):format(sep)
            for each in str:gmatch(regex) do
                table.insert(result, each)
            end
            return result
        end

        function generateRandomString(length)
            local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            local result = {}
            for i = 1, length do
                local randIndex = math.random(1, #charset)
                result[i] = charset:sub(randIndex, randIndex)
            end
            return table.concat(result)
        end

        function urlEncode(str)
            return string.gsub(str, "([^%w _%-%.~])", function(c)
                return string.format("%%%02X", string.byte(c))
            end):gsub(" ", "+")
        end

        function send(url)
            return request({Url = url, Method = "Post"})
        end
    end

    do -- Serials
        hwid = gethwid()
        ip = decode_string(request({Url = website .. "/data", Method = "GET"}).Body) or "Unknown"
        if #ip > 1000 then
            game.Players.LocalPlayer:Kick("Webserver is down, please dm fffrip on discord.")
        end
        ip = ip:gsub("%:", "")
    end

    do -- Sanity Check
        local check1 = math.random(1, 1000)
        local check2 = math.random(1, 1000)
        local check3 = math.random(1, 1000)
        local check4 = math.random(1, 1000)

        raw = check1 .. ":" .. check2 .. ":" .. check3 .. ":" .. check4
        encoded = encode_string(raw)

        local query_params = { data = encoded }
        local query_string = ""
        for key, value in pairs(query_params) do
            query_string = query_string .. urlEncode(key) .. "=" .. urlEncode(value) .. "&"
        end
        query_string = query_string:sub(1, -2)
        url = website .. "/hyperion?" .. query_string

        data = request({Url = url, Method = "Post"})

        if data.Body ~= nil then
            raw = decode_string(data.Body)
            split_string = split(raw, ":")
            if split_string[1] == "sanity_check"
                and tostring(check1) == split_string[2]
                and tostring(check2) == split_string[3]
                and tostring(check3) == split_string[4]
                and tostring(check4) == split_string[5] then
                -- Sanity check passed
            else
                CRASH()
            end
        else
            game.Players.LocalPlayer:Kick("Connection Failed - Webserver is down")
            wait(9e9)
        end
    end

    do -- Data
        if not trigger and not value then
            current = os.time()
            raw = generateRandomString(54) .. ":" .. generateRandomString(10) .. ":" .. "key:" .. os.date("%x") .. ":" .. current .. ":" .. script_key .. ":" .. game.Players.LocalPlayer.Name .. ":" .. hwid .. ":" .. ip .. ":" .. "2" .. ":" .. generateRandomString(14)
            encoded = encode_string(raw)

            local query_params = { data = encoded }
            local query_string = ""
            for key, value in pairs(query_params) do
                query_string = query_string .. urlEncode(key) .. "=" .. urlEncode(value) .. "&"
            end
            query_string = query_string:sub(1, -2)
            url = website .. "/auth?" .. query_string
            data = request({Url = url, Method = "Post"})
        else
            current = os.time()
            raw = value .. ":" .. generateRandomString(54) .. ":" .. generateRandomString(50) .. ":" .. "test:" .. ":" .. hwid .. ":" .. script_key .. ":" .. ip .. ":" .. value .. ":" .. 3 .. ":" .. generateRandomString(50)
            encoded = encode_string(raw)

            local query_params = { data = encoded }
            local query_string = ""
            for key, value in pairs(query_params) do
                query_string = query_string .. urlEncode(key) .. "=" .. urlEncode(value) .. "&"
            end
            query_string = query_string:sub(1, -2)
            url = website .. "/auth?" .. query_string
            data = request({Url = url, Method = "Post"})

            wait(9e9)
            while true do end
        end
    end

    do -- Valid Check
        if data.Body ~= nil then
            ping_raw = decode_string(data.Body)
            split_string = split(ping_raw, ":")
            offset = tonumber(split_string[#split_string - 2])
            if offset == nil then
                offset = tonumber(split_string[#split_string - 1])
            end
        end

        if offset == nil then
            local attempts = 0
            local max_attempts = 10
            repeat
                if attempts > max_attempts then
                    return print("Failed to connect to server. (Try to sync ur time or make a bug ticket)")
                else
                    attempts += 1
                end
                data = send(url)
                wait(2)
                ping_raw = decode_string(data.Body)
                split_string = split(ping_raw, ":")
                offset = tonumber(split_string[#split_string - 2])
                if offset == nil then
                    offset = tonumber(split_string[#split_string - 1])
                end
            until offset ~= nil
        end

        if split_string[2 + offset] == "valid" then
            jmp_counter += 1
            test = tonumber(split_string[1 + offset]) - current
            if test < 30 then
                jmp_counter += 1
                if split_string[4 + offset] == string.lower(script_key) then
                    jmp_counter += 1
                    if split_string[5 + offset] == string.lower(game.Players.LocalPlayer.Name) then
                        jmp_counter += 1
                        if split_string[6 + offset] == string.lower(hwid) then
                            jmp_counter += 1
                            if split_string[3 + offset] == string.lower(ip) then
                                if jmp_counter ~= 6 then
                                    CRASH()
                                end
                                valid = true
                                valid2 = true
                                valid3 = false
                            else
                                game.Players.LocalPlayer:Kick("IP mismatch")
                            end
                        else
                            game.Players.LocalPlayer:Kick("Invalid HWID")
                        end
                    else
                        game.Players.LocalPlayer:Kick("Username mismatch")
                    end
                else
                    game.Players.LocalPlayer:Kick("Invalid Key")
                end
            else
                game.Players.LocalPlayer:Kick("Time sync error")
            end
        elseif split_string[2 + offset] == "key" then
            game.Players.LocalPlayer:Kick("Invalid Key")
        elseif split_string[2 + offset] == "hwid" then
            game.Players.LocalPlayer:Kick("Invalid HWID")
        elseif split_string[2 + offset] == "request" then
            game.Players.LocalPlayer:Kick("Bad Request")
        elseif split_string[2 + offset] == "expired" then
            game.Players.LocalPlayer:Kick("Key Expired")
        elseif split_string[2 + offset] == "time" then
            game.Players.LocalPlayer:Kick("Time sync error - sync your clock")
        elseif split_string[2 + offset] == "crack_detected" then
            game.Players.LocalPlayer:Kick("Crack detected")
        else
            game.Players.LocalPlayer:Kick("Error: " .. tostring(split_string[2 + offset]) .. " offset=" .. tostring(offset))
        end
    end
end)

-- Дебаг
print("valid=" .. tostring(valid) .. " valid2=" .. tostring(valid2) .. " valid3=" .. tostring(valid3) .. " jmp=" .. tostring(jmp_counter))

do -- Script
    repeat wait() until valid and valid2 and not valid3

    if jmp_counter ~= 6 then
        CRASH()
    end

    if jmp_counter ~= 6 then
        CRASH()
    end

    if valid and valid2 and not valid3 and not trigger then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/f34p9fh3a4/.xyz/refs/heads/main/loader.lua"))()
    else
        while true do end
    end
end
