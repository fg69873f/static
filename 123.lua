local KEY_HEX = "a8fdece49e6a30920ae951196b00a9efddacbe66ff5770fbfca3c23fdede997f"

-- ─── Hex utils ───────────────────────────────────────────────────────────────

local function hex_to_bytes(hex)
    local bytes = {}
    for i = 1, #hex, 2 do
        bytes[#bytes + 1] = tonumber(hex:sub(i, i+1), 16)
    end
    return bytes
end

local function bytes_to_hex(bytes)
    local hex = {}
    for _, b in ipairs(bytes) do
        hex[#hex + 1] = string.format("%02x", b)
    end
    return table.concat(hex)
end

local function str_to_bytes(s)
    local bytes = {}
    for i = 1, #s do bytes[i] = string.byte(s, i) end
    return bytes
end

local function bytes_to_str(bytes)
    local chars = {}
    for _, b in ipairs(bytes) do chars[#chars + 1] = string.char(b) end
    return table.concat(chars)
end

-- ─── AES S-box & tables ──────────────────────────────────────────────────────

local sbox = {
    0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,
    0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,
    0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,
    0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,
    0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,
    0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,
    0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,
    0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,
    0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,
    0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,
    0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,
    0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,
    0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,
    0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,
    0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,
    0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16,
}

local inv_sbox = {}
for i, v in ipairs(sbox) do inv_sbox[v] = i - 1 end

local function xtime(b)
    if b >= 128 then return ((b * 2) % 256) ~ 0x1b
    else return (b * 2) % 256 end
end

local function gmul(a, b)
    local p = 0
    for _ = 1, 8 do
        if b & 1 ~= 0 then p = p ~ a end
        local hi = a & 0x80
        a = (a << 1) & 0xFF
        if hi ~= 0 then a = a ~ 0x1b end
        b = b >> 1
    end
    return p
end

-- ─── Key expansion ───────────────────────────────────────────────────────────

local rcon = {0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x1b,0x36}

local function key_expansion(key_bytes)
    local w = {}
    for i = 0, 7 do
        w[i] = {key_bytes[i*4+1], key_bytes[i*4+2], key_bytes[i*4+3], key_bytes[i*4+4]}
    end
    for i = 8, 59 do
        local temp = {w[i-1][1], w[i-1][2], w[i-1][3], w[i-1][4]}
        if i % 8 == 0 then
            temp = {temp[2], temp[3], temp[4], temp[1]}
            for j = 1, 4 do temp[j] = sbox[temp[j] + 1] end
            temp[1] = temp[1] ~ rcon[i // 8]
        elseif i % 8 == 4 then
            for j = 1, 4 do temp[j] = sbox[temp[j] + 1] end
        end
        w[i] = {w[i-8][1]~temp[1], w[i-8][2]~temp[2], w[i-8][3]~temp[3], w[i-8][4]~temp[4]}
    end
    local round_keys = {}
    for r = 0, 14 do
        round_keys[r] = {}
        for c = 0, 3 do
            local word = w[r*4 + c]
            for b = 1, 4 do round_keys[r][c*4 + b] = word[b] end
        end
    end
    return round_keys
end

-- ─── AES block ───────────────────────────────────────────────────────────────

local function add_round_key(state, rk)
    for i = 1, 16 do state[i] = state[i] ~ rk[i] end
end

local function sub_bytes(state)
    for i = 1, 16 do state[i] = sbox[state[i] + 1] end
end

local function inv_sub_bytes(state)
    for i = 1, 16 do state[i] = inv_sbox[state[i]] end
end

local function shift_rows(state)
    local s = state
    s[2],s[6],s[10],s[14] = s[6],s[10],s[14],s[2]
    s[3],s[7],s[11],s[15] = s[11],s[15],s[3],s[7]
    s[4],s[8],s[12],s[16] = s[16],s[4],s[8],s[12]
end

local function inv_shift_rows(state)
    local s = state
    s[2],s[6],s[10],s[14] = s[14],s[2],s[6],s[10]
    s[3],s[7],s[11],s[15] = s[11],s[15],s[3],s[7]
    s[4],s[8],s[12],s[16] = s[8],s[12],s[16],s[4]
end

local function mix_columns(state)
    for c = 0, 3 do
        local i = c*4 + 1
        local s0,s1,s2,s3 = state[i],state[i+1],state[i+2],state[i+3]
        state[i]   = gmul(s0,2)~gmul(s1,3)~s2~s3
        state[i+1] = s0~gmul(s1,2)~gmul(s2,3)~s3
        state[i+2] = s0~s1~gmul(s2,2)~gmul(s3,3)
        state[i+3] = gmul(s0,3)~s1~s2~gmul(s3,2)
    end
end

local function inv_mix_columns(state)
    for c = 0, 3 do
        local i = c*4 + 1
        local s0,s1,s2,s3 = state[i],state[i+1],state[i+2],state[i+3]
        state[i]   = gmul(s0,14)~gmul(s1,11)~gmul(s2,13)~gmul(s3,9)
        state[i+1] = gmul(s0,9)~gmul(s1,14)~gmul(s2,11)~gmul(s3,13)
        state[i+2] = gmul(s0,13)~gmul(s1,9)~gmul(s2,14)~gmul(s3,11)
        state[i+3] = gmul(s0,11)~gmul(s1,13)~gmul(s2,9)~gmul(s3,14)
    end
end

local function aes_encrypt_block(block, round_keys)
    local state = {table.unpack(block)}
    add_round_key(state, round_keys[0])
    for r = 1, 13 do
        sub_bytes(state); shift_rows(state); mix_columns(state)
        add_round_key(state, round_keys[r])
    end
    sub_bytes(state); shift_rows(state)
    add_round_key(state, round_keys[14])
    return state
end

local function aes_decrypt_block(block, round_keys)
    local state = {table.unpack(block)}
    add_round_key(state, round_keys[14])
    inv_shift_rows(state); inv_sub_bytes(state)
    for r = 13, 1, -1 do
        add_round_key(state, round_keys[r])
        inv_mix_columns(state); inv_shift_rows(state); inv_sub_bytes(state)
    end
    add_round_key(state, round_keys[0])
    return state
end

-- ─── CBC mode ────────────────────────────────────────────────────────────────

local function pkcs7_pad(bytes)
    local pad = 16 - (#bytes % 16)
    for _ = 1, pad do bytes[#bytes + 1] = pad end
    return bytes
end

local function pkcs7_unpad(bytes)
    local pad = bytes[#bytes]
    for i = #bytes - pad + 1, #bytes do
        if bytes[i] ~= pad then return bytes end
    end
    for _ = 1, pad do bytes[#bytes] = nil end
    return bytes
end

local function random_iv()
    local iv = {}
    for i = 1, 16 do iv[i] = math.random(0, 255) end
    return iv
end

local function xor_blocks(a, b)
    local out = {}
    for i = 1, 16 do out[i] = a[i] ~ b[i] end
    return out
end

-- ─── Public API ──────────────────────────────────────────────────────────────

local KEY_BYTES = hex_to_bytes(KEY_HEX)
local ROUND_KEYS = key_expansion(KEY_BYTES)

function encode_string(plaintext)
    local bytes = pkcs7_pad(str_to_bytes(plaintext))
    local iv = random_iv()
    local prev = iv
    local cipher_bytes = {}
    for b = 1, #bytes, 16 do
        local block = {}
        for i = 1, 16 do block[i] = bytes[b + i - 1] end
        local xored = xor_blocks(block, prev)
        local enc = aes_encrypt_block(xored, ROUND_KEYS)
        for _, v in ipairs(enc) do cipher_bytes[#cipher_bytes + 1] = v end
        prev = enc
    end
    return bytes_to_hex(iv) .. ":" .. bytes_to_hex(cipher_bytes)
end

function decode_string(ciphertext)
    local colon = ciphertext:find(":")
    if not colon then return ciphertext end
    local iv = hex_to_bytes(ciphertext:sub(1, colon - 1))
    local cipher_bytes = hex_to_bytes(ciphertext:sub(colon + 1))
    local prev = iv
    local plain_bytes = {}
    for b = 1, #cipher_bytes, 16 do
        local block = {}
        for i = 1, 16 do block[i] = cipher_bytes[b + i - 1] end
        local dec = aes_decrypt_block(block, ROUND_KEYS)
        local xored = xor_blocks(dec, prev)
        for _, v in ipairs(xored) do plain_bytes[#plain_bytes + 1] = v end
        prev = block
    end
    plain_bytes = pkcs7_unpad(plain_bytes)
    return bytes_to_str(plain_bytes)
end

local function CRASH()
    local p = game.Players.LocalPlayer
    if p then
        p:Kick("An unexpected error occurred. [0x" .. string.format("%X", math.random(0x1000, 0xFFFF)) .. "]")
    end
    while true do wait(9e9) end
end

-- Executor whitelist
local _allowedExecutors = {
    "AWP", "Volt", "ChocoSploit", "Seliware", "Wave", "Volcano",
    "Potassium", "SirHurt", "Fluxus", "Delta", "Krnl", "Synapse", "Velocity",
    "Nihon", "Madium", "Cosmic",
}
local _executor = identifyexecutor and identifyexecutor() or "Unknown"
local _allowed = false
for _, v in ipairs(_allowedExecutors) do
    if _executor:lower():find(v:lower()) then _allowed = true; break end
end
if not _allowed then
    game:GetService("Players").LocalPlayer:Kick('Your executor ("' .. _executor .. '") cannot run this script.')
    return
end

script_key = script_key or _G.script_key or "nil"
website = "https://cumarmor.vercel.app"

local jmp_counter = 0

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
            -- Structure: random54 : random10 : "key" : date : current : script_key : username : hwid : ip : executor : "2" : random14
            raw = generateRandomString(54) .. ":" .. generateRandomString(10) .. ":" .. "key:" .. os.date("%x") .. ":" .. current .. ":" .. script_key .. ":" .. game.Players.LocalPlayer.Name .. ":" .. hwid .. ":" .. ip .. ":" .. _executor .. ":" .. "2" .. ":" .. generateRandomString(14)
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
                    return print("Failed to connect to server.")
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
                            game.Players.LocalPlayer:Kick("HWID mismatch")
                        end
                    else
                        game.Players.LocalPlayer:Kick("Username mismatch")
                    end
                else
                    game.Players.LocalPlayer:Kick("Key mismatch")
                end
            else
                game.Players.LocalPlayer:Kick("Time sync error")
            end
        elseif split_string[2 + offset] == "key" then
            game.Players.LocalPlayer:Kick("Invalid Key")
        elseif split_string[2 + offset] == "not_activated" then
            game.Players.LocalPlayer:Kick("Key not activated. Redeem your key in the Discord server first.")
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
            game.Players.LocalPlayer:Kick("Authentication failed. [0x" .. string.format("%X", math.random(0x1000, 0xFFFF)) .. "]")
        end
    end
end)

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
