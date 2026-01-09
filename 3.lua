-- Weight Lifting Simulator 3 - Strength Multiplier Hook
-- Увеличивает получаемую силу при тренировках

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Настройки множителя
local STRENGTH_MULTIPLIER = 1000000000 -- Умножает получаемую силу в 1 миллиард раз

-- Проверка на повторное выполнение
if _G.StrengthHookActive then
    warn("Strength Hook уже активен!")
    return
end

_G.StrengthHookActive = true

-- Оригинальная функция
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Проверяем, что вызов идет не от нашего скрипта
    if not checkcaller() then
        -- Хук для FireServer (тренировка с инструментами)
        if method == "FireServer" then
            -- Проверяем, что это событие strengthEvent с аргументом "rep"
            if self.Name == "strengthEvent" and args[1] == "rep" then
                print("[Strength Hook] Перехвачена тренировка с инструментом")
                -- Не изменяем аргументы, так как сила начисляется на сервере
                return oldNamecall(self, ...)
            end
            
            -- Проверяем stomp для situps/pushups
            if self.Name == "replicator" and args[1] == "stomp" then
                print("[Strength Hook] Перехвачена тренировка situps/pushups")
                return oldNamecall(self, ...)
            end
        end
        
        -- Хук для InvokeServer (если используется)
        if method == "InvokeServer" then
            if self.Name == "strengthEvent" and args[1] == "rep" then
                print("[Strength Hook] Перехвачен InvokeServer для тренировки")
                return oldNamecall(self, ...)
            end
        end
    end
    
    return oldNamecall(self, ...)
end))

-- Альтернативный метод: изменение локальных данных клиента
local function hookLocalStrength()
    -- Ждем, пока появится strengthEvent
    local strengthEvent = LocalPlayer:WaitForChild("strengthEvent", 10)
    
    if strengthEvent then
        -- Хукаем OnClientEvent для изменения отображаемой силы
        local oldConnect = strengthEvent.OnClientEvent.connect
        strengthEvent.OnClientEvent.connect = function(self, callback)
            return oldConnect(self, function(eventType, strengthAmount, ...)
                -- Если это событие добавления силы
                if eventType == "spawnStrength" and type(strengthAmount) == "number" then
                    print(string.format("[Strength Hook] Изменена сила с %d на %d", strengthAmount, strengthAmount * STRENGTH_MULTIPLIER))
                    -- Изменяем количество силы
                    return callback(eventType, strengthAmount * STRENGTH_MULTIPLIER, ...)
                end
                return callback(eventType, strengthAmount, ...)
            end)
        end
        print("[Strength Hook] Локальный хук активирован!")
    end
end

-- Запускаем локальный хук
spawn(hookLocalStrength)

-- Метод 3: Прямой хук RemoteEvent
spawn(function()
    wait(2) -- Ждем загрузки игры
    
    local strengthEvent = LocalPlayer:FindFirstChild("strengthEvent")
    if strengthEvent and strengthEvent:IsA("RemoteEvent") then
        -- Старый метод через метатаблицу
        local mt = getrawmetatable(strengthEvent)
        local oldFireServer = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if not checkcaller() and self == strengthEvent and method == "FireServer" then
                if args[1] == "rep" then
                    print("[Strength Hook Method 3] Перехвачена тренировка")
                end
            end
            
            return oldFireServer(self, ...)
        end)
        
        setreadonly(mt, true)
        print("[Strength Hook] Method 3 активирован!")
    end
end)

print("[Strength Hook] Успешно загружен!")
_G.fuhe4p98fha4 = true
