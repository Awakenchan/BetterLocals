if not LPH_OBFUSCATED then
    local assert = assert
    local type = type
    local setfenv = setfenv

    LPH_ENCNUM = function(toEncrypt, ...)
        assert(type(toEncrypt) == "number" and #{...} == 0, "LPH_ENCNUM only accepts a single constant double or integer as an argument.")
        return toEncrypt
    end
    LPH_NUMENC = LPH_ENCNUM

    LPH_ENCSTR = function(toEncrypt, ...)
        assert(type(toEncrypt) == "string" and #{...} == 0, "LPH_ENCSTR only accepts a single constant string as an argument.")
        return toEncrypt
    end
    LPH_STRENC = LPH_ENCSTR

    LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
        -- not checking decKey value since this shim is meant to be used without obfuscation/whitelisting
        assert(type(toEncrypt) == "function" and type(encKey) == "string" and #{...} == 0, "LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")
        return toEncrypt
    end
    LPH_FUNCENC = LPH_ENCFUNC

    LPH_JIT = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
        return f
    end
    LPH_JIT_MAX = LPH_JIT

    LPH_NO_VIRTUALIZE = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
        return f
    end

    LPH_NO_UPVALUES = function(f, ...)
        assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
        return f
    end

    LPH_CRASH = function(...)
        assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
    end
end;

getgenv().SafeService = setmetatable({}, {
    __index = function(self, name)
        local service
        xpcall(function()
            service = cloneref(game:GetService(name))
        end, function(rr) print(rr) end) 
        if service then
            rawset(self, name, service)
            return service
        end
        return nil
    end
})
local services = {
    "Players", "Workspace", "ReplicatedStorage", "ReplicatedFirst",
    "Lighting", "UserInputService", "RunService", "TweenService", "HttpService",
    "CoreGui", "InsertService", "Debris", "SoundService",
    "ContextActionService", "StarterGui", "StarterPack", "Teams", "Chat",
    "PathfindingService", "PhysicsService", "CollectionService", "MarketplaceService",
    "GuiService", "ChangeHistoryService", "TextService", "LocalizationService",
    "TestService", "GroupService", "AssetService", "BadgeService",
    "PointsService", "AnalyticsService","ProximityPromptService",
    "VirtualInputManager","ContentProvider"
}
getgenv().GlobalsTable = {}
for _, name in next, services do
    if name == "VirtualInputManager" then
        local vimClone = cloneref(Instance.new("VirtualInputManager"))
        getgenv()[name] = vimClone
        getgenv().GlobalsTable[name] = vimClone
    else
        local svc = SafeService[name]
        getgenv()[name] = svc
        getgenv().GlobalsTable[name] = svc
    end
end
getgenv().LocalPlayer = LPH_JIT_MAX(function()
    return cloneref(Players.LocalPlayer)
end)
getgenv().Character = LPH_JIT_MAX(function()
    return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end)

getgenv().HumanoidRootPart = LPH_JIT_MAX(function()
    local char = Character()
    return char and char:FindFirstChild("HumanoidRootPart")
end)

getgenv().Humanoid = LPH_JIT_MAX(function()
    local char = Character()
    return char and char:FindFirstChildOfClass("Humanoid")
end)
getgenv().CharacterPart = setmetatable({}, {
    __index = function(self, partName)
        local f = LPH_JIT_MAX(function()
            local char = Character()
            return char and char:FindFirstChild(partName)
        end)
        rawset(self, partName, f)
        return f
    end
})

getgenv().RecursiveTable = function(obj)
    local result = {
        Scripts = {},
        RemoteEvents = {},
        RemoteFunctions = {},
        Values = {},
        Folders = {},
        Parts = {},
        Models = {},
        ScreenGuis = {},
        Frames = {},
        TextLabels = {},
        TextButtons = {},
        WeldConstraints = {},
        HingeConstraints = {},
        Sounds = {},
        Animations = {},
        ParticleEmitters = {},
        Tools = {},
    }

    if typeof(obj) ~= "Instance" then return result end

    for _, child in next, obj:GetChildren() do
        if child:IsA("Folder") then
            result.Folders[child.Name] = RecursiveTable(child)
        elseif child:IsA("RemoteEvent") then
            result.RemoteEvents[child.Name] = child
        elseif child:IsA("RemoteFunction") then
            result.RemoteFunctions[child.Name] = child
        elseif child:IsA("ModuleScript") or child:IsA("Script") or child:IsA("LocalScript") then
            local success, src = pcall(function() return child.Source end)
            result.Scripts[child.Name] = {
                ClassName = child.ClassName,
                Source = success and src or "[Cannot read source]"
            }
        elseif child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("BoolValue") or
               child:IsA("ObjectValue") or child:IsA("CFrameValue") or child:IsA("Vector3Value") then
            result.Values[child.Name] = {
                ClassName = child.ClassName,
                Value = child.Value
            }
        elseif child:IsA("Part") or child:IsA("MeshPart") or child:IsA("UnionOperation") then
            result.Parts[child.Name] = child
        elseif child:IsA("Model") then
            result.Models[child.Name] = RecursiveTable(child)
        elseif child:IsA("ScreenGui") then
            result.ScreenGuis[child.Name] = RecursiveTable(child)
        elseif child:IsA("Frame") then
            result.Frames[child.Name] = RecursiveTable(child)
        elseif child:IsA("TextLabel") then
            result.TextLabels[child.Name] = child
        elseif child:IsA("TextButton") then
            result.TextButtons[child.Name] = child
        elseif child:IsA("WeldConstraint") then
            result.WeldConstraints[child.Name] = child
        elseif child:IsA("HingeConstraint") then
            result.HingeConstraints[child.Name] = child
        elseif child:IsA("Sound") then
            result.Sounds[child.Name] = child
        elseif child:IsA("Animation") then
            result.Animations[child.Name] = child
        elseif child:IsA("ParticleEmitter") then
            result.ParticleEmitters[child.Name] = child
        elseif child:IsA("Tool") then
            result.Tools[child.Name] = child
        end
    end

    return result
end


--[[
table.foreach(getgenv().GlobalsTable,print)

getgenv().LocalPlayer = Players.LocalPlayer

for i,v in next, ReplicatedStorage:GetChildren()
print(v)
end

local hrp = CharacterPart.HumanoidRootPart()
local head = CharacterPart.Head()
local tool = CharacterPart.MySword()
table.foreach(getgenv().GlobalsTable,print)
local Class,Default = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/Data2Code%40Amity.lua"))()

local ReplicatedStorageData = RecursiveTable(ReplicatedStorage)
]]
