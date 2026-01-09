-- Weight Lifting Simulator 3 - Correct Hook
-- Основан на анализе декомпилированного кода

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Настройки
local STRENGTH_MULTIPLIER = 1000000000

if _G.StrengthHookActive then
    warn("Hook уже активен!")
    return
end

_G.StrengthHookActive = true

print("===========================================")
print("[WLS3 Hook] Загрузка...")
print("===========================================")

-- Ждем персонажа и strengthEvent
repeat wait() until LocalPlayer.Character
local strengthEvent = LocalPlayer:WaitForChild("strengthEvent", 30)

if not strengthEvent then
    warn("[WLS3 Hook] strengthEvent не найден!")
    return
end

print("[WLS3 Hook] strengthEvent найден!")

-- Метод 1: Хук FireServer (для логирования)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() then
        if method == "FireServer" and self.Name == "strengthEvent" then
            print("[WLS3 Hook] FireServer перехвачен!")
            print("[WLS3 Hook] Аргументы:", unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end))

-- Метод 2: Главный хук - перехват OnClientEvent
-- Это работает потому что сервер отправляет клиенту информацию о полученной силе
local originalConnect = strengthEvent.OnClientEvent.Connect
local originalconnect = strengthEvent.OnClientEvent.connect

-- Подменяем Connect (с большой буквы)
strengthEvent.OnClientEvent.Connect = function(self, callback)
    print("[WLS3 Hook] OnClientEvent.Connect вызван!")
    
    local wrappedCallback = function(eventType, value, ...)
        print("[WLS3 Hook] Событие:", eventType, "Значение:", value)
        
        -- Умножаем силу при событии spawnStrength
        if eventType == "spawnStrength" and type(value) == "number" then
            local oldValue = value
            value = value * STRENGTH_MULTIPLIER
            print(string.format("[WLS3 Hook] Сила изменена: %d -> %d", oldValue, value))
        end
        
        -- Умножаем гемы при событии spawnGem
        if eventType == "spawnGem" and type(value) == "number" then
            local oldValue = value
            value = value * STRENGTH_MULTIPLIER
            print(string.format("[WLS3 Hook] Гемы изменены: %d -> %d", oldValue, value))
        end
        
        return callback(eventType, value, ...)
    end
    
    return originalConnect(self, wrappedCallback)
end

-- Подменяем connect (с маленькой буквы)
strengthEvent.OnClientEvent.connect = function(self, callback)
    print("[WLS3 Hook] OnClientEvent.connect вызван!")
    
    local wrappedCallback = function(eventType, value, ...)
        print("[WLS3 Hook] Событие:", eventType, "Значение:", value)
        
        if eventType == "spawnStrength" and type(value) == "number" then
            local oldValue = value
            value = value * STRENGTH_MULTIPLIER
            print(string.format("[WLS3 Hook] Сила изменена: %d -> %d", oldValue, value))
        end
        
        if eventType == "spawnGem" and type(value) == "number" then
            local oldValue = value
            value = value * STRENGTH_MULTIPLIER
            print(string.format("[WLS3 Hook] Гемы изменены: %d -> %d", oldValue, value))
        end
        
        return callback(eventType, value, ...)
    end
    
    return originalconnect(self, wrappedCallback)
end

print("[WLS3 Hook] OnClientEvent хук установлен!")

-- Метод 3: Если инструменты уже в руках, перехватываем их LocalScript
spawn(function()
    while wait(1) do
        local character = LocalPlayer.Character
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    -- Ищем LocalScript с strengthEvent
                    for _, script in pairs(tool:GetDescendants()) do
                        if script:IsA("LocalScript") and not script:GetAttribute("Hooked") then
                            print("[WLS3 Hook] Найден инструмент:", tool.Name)
                            script:SetAttribute("Hooked", true)
                        end
                    end
                end
            end
        end
    end
end)

-- Метод 4: Использование getconnections если доступно
local getconnections = getconnections or get_signal_cons

if getconnections then
    spawn(function()
        wait(2)
        
        local connections = getconnections(strengthEvent.OnClientEvent)
        print("[WLS3 Hook] Найдено подключений:", #connections)
        
        for i, connection in pairs(connections) do
            if connection.Function then
                local oldFunc = connection.Function
                
                connection.Function = function(...)
                    local args = {...}
                    
                    -- args[1] = eventType (spawnStrength/spawnGem)
                    -- args[2] = value (количество силы/гемов)
                    
                    if args[1] == "spawnStrength" and type(args[2]) == "number" then
                        local oldValue = args[2]
                        args[2] = args[2] * STRENGTH_MULTIPLIER
                        print(string.format("[WLS3 Hook Method 4] Сила: %d -> %d", oldValue, args[2]))
                    end
                    
                    if args[1] == "spawnGem" and type(args[2]) == "number" then
                        local oldValue = args[2]
                        args[2] = args[2] * STRENGTH_MULTIPLIER
                        print(string.format("[WLS3 Hook Method 4] Гемы: %d -> %d", oldValue, args[2]))
                    end
                    
                    return oldFunc(unpack(args))
                end
                
                print("[WLS3 Hook] Подключение", i, "перехвачено!")
            end
        end
    end)
else
    print("[WLS3 Hook] getconnections недоступен")
end

-- Информация
print("===========================================")
print("[WLS3 Hook] Активирован!")
print("[WLS3 Hook] Множитель: x" .. STRENGTH_MULTIPLIER)
print("[WLS3 Hook] Начните тренироваться!")
print("===========================================")

_G.fuhe4p98fha4765 = true
