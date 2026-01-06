local hook
hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    if not checkcaller() and getnamecallmethod() == "FireServer" and type(args[1]) == "string" and type(args[2]) == "number" and #args == 2 and #args[1] > 15 then
        args[2] = 1000000000
        return hook(self, unpack(args))
    end
    return hook(self, ...)
end))

_G.fuhe4p98fha4 = true

print("1")
