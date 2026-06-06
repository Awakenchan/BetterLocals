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
end

local Class = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV3/refs/heads/main/Utility/Data2Code.luau"))()

local SafeService = setmetatable({}, {
    __index = function(self, name)
        local service
        xpcall(function()
            service = cloneref(game:GetService(name))
        end, function(err)
            print(err)
        end)
        if service then
            rawset(self, name, service)
            return service
        end
        return nil
    end
})

local Services = {
    "Players", "Workspace", "ReplicatedStorage", "ReplicatedFirst",
    "Lighting", "UserInputService", "RunService", "TweenService", "HttpService",
    "CoreGui", "InsertService", "Debris", "SoundService",
    "ContextActionService", "StarterGui", "StarterPack", "Teams", "Chat",
    "PathfindingService", "PhysicsService", "CollectionService", "MarketplaceService",
    "GuiService", "TextService", "LocalizationService",
    "GroupService", "ProximityPromptService", "VirtualInputManager",
    "ContentProvider"
}

local GlobalsTable = {}

for _, name in Services do
    if name == "VirtualInputManager" then
        GlobalsTable[name] = cloneref(Instance.new("VirtualInputManager"))
    else
        GlobalsTable[name] = SafeService[name]
    end
end

local Players = GlobalsTable.Players

local LocalPlayer = LPH_JIT_MAX(function()
    return Players.LocalPlayer
end)

local Character = LPH_JIT_MAX(function()
    return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end)

local HumanoidRootPart = LPH_JIT_MAX(function()
    local char = Character()
    return char and char:FindFirstChild("HumanoidRootPart")
end)

local Humanoid = LPH_JIT_MAX(function()
    local char = Character()
    return char and char:FindFirstChildOfClass("Humanoid")
end)

local CharacterPart = setmetatable({}, {
    __index = function(self, partName)
        local f = LPH_JIT_MAX(function()
            local char = Character()
            return char and char:FindFirstChild(partName)
        end)
        rawset(self, partName, f)
        return f
    end
})

local ValueClasses = {
    StringValue = true,
    NumberValue = true,
    BoolValue = true,
    ObjectValue = true,
    CFrameValue = true,
    Vector3Value = true
}

local ScriptClasses = {
    ModuleScript = true,
    Script = true,
    LocalScript = true
}

local function RecursiveTable(obj)
    local result = {
        Instance = obj,

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

        _connections = {},
        _placement = {}
    }

    if typeof(obj) ~= "Instance" then
        return result
    end

    local Direct = {
        RemoteEvent = "RemoteEvents",
        RemoteFunction = "RemoteFunctions",
        TextLabel = "TextLabels",
        TextButton = "TextButtons",
        WeldConstraint = "WeldConstraints",
        HingeConstraint = "HingeConstraints",
        Sound = "Sounds",
        Animation = "Animations",
        ParticleEmitter = "ParticleEmitters",
        Tool = "Tools"
    }

    local Nested = {
        Folder = "Folders",
        Model = "Models",
        ScreenGui = "ScreenGuis",
        Frame = "Frames"
    }

    local PartFallback = { "Part", "MeshPart", "UnionOperation" }

    local function place(child, category, value)
        result[category][child.Name] = value
        result._placement[child] = category
    end

    local function unplace(child)
        local category = result._placement[child]
        if category and result[category] then
            result[category][child.Name] = nil
        end
        result._placement[child] = nil
    end

    local classify

    local function store(child)
        local cls = child.ClassName

        local direct = Direct[cls]
        if direct then
            return place(child, direct, child)
        end

        local nested = Nested[cls]
        if nested then
            return place(child, nested, RecursiveTable(child))
        end

        if ScriptClasses[cls] then
            return place(child, "Scripts", {
                ClassName = cls,
                Source = Class.Convert(child, true)
            })
        end

        if ValueClasses[cls] then
            local v = {
                ClassName = cls,
                Instance = child,
                Value = child.Value
            }
            v._conn = child:GetPropertyChangedSignal("Value"):Connect(function()
                v.Value = child.Value
            end)
            return place(child, "Values", v)
        end

        for _, partClass in PartFallback do
            if child:IsA(partClass) then
                return place(child, "Parts", child)
            end
        end
    end

    classify = function(child)
        store(child)
        result._connections[child] = child:GetPropertyChangedSignal("Name"):Connect(function()
            unplace(child)
            classify(child)
        end)
    end

    for _, child in obj:GetChildren() do
        classify(child)
    end

    result._connections.ChildAdded = obj.ChildAdded:Connect(classify)

    result._connections.ChildRemoved = obj.ChildRemoved:Connect(function(child)
        unplace(child)
        if result._connections[child] then
            result._connections[child]:Disconnect()
            result._connections[child] = nil
        end
    end)

    result._connections.Destroying = obj.Destroying:Connect(function()
        for _, c in result._connections do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end
    end)

    return result
end

return {
    SafeService = SafeService,
    GlobalsTable = GlobalsTable,
    LocalPlayer = LocalPlayer,
    Character = Character,
    HumanoidRootPart = HumanoidRootPart,
    Humanoid = Humanoid,
    CharacterPart = CharacterPart,
    RecursiveTable = RecursiveTable
}
