getgenv().RecursiveTable = function(obj)
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

        _connections = {}
    }

    if typeof(obj) ~= "Instance" then
        return result
    end
    local function classify(child)
        if child:IsA("Folder") then
            result.Folders[child.Name] = getgenv().RecursiveTable(child)

        elseif child:IsA("RemoteEvent") then
            result.RemoteEvents[child.Name] = child

        elseif child:IsA("RemoteFunction") then
            result.RemoteFunctions[child.Name] = child

        elseif child:IsA("ModuleScript") or child:IsA("Script") or child:IsA("LocalScript") then
            result.Scripts[child.Name] = {
                ClassName = child.ClassName,
                Source = Class.Convert(child, true)
            }

        elseif child:IsA("StringValue") or child:IsA("NumberValue")
            or child:IsA("BoolValue") or child:IsA("ObjectValue")
            or child:IsA("CFrameValue") or child:IsA("Vector3Value") then

            local v = {
                ClassName = child.ClassName,
                Instance = child,
                Value = child.Value
            }

            v._conn = child:GetPropertyChangedSignal("Value"):Connect(function()
                v.Value = child.Value
            end)

            result.Values[child.Name] = v

        elseif child:IsA("Part") or child:IsA("MeshPart") or child:IsA("UnionOperation") then
            result.Parts[child.Name] = child

        elseif child:IsA("Model") then
            result.Models[child.Name] = getgenv().RecursiveTable(child)

        elseif child:IsA("ScreenGui") then
            result.ScreenGuis[child.Name] = getgenv().RecursiveTable(child)

        elseif child:IsA("Frame") then
            result.Frames[child.Name] = getgenv().RecursiveTable(child)

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
        result._connections[child] = child:GetPropertyChangedSignal("Name"):Connect(function()
            for _, cat in pairs(result) do
                if type(cat) == "table" then
                    cat[child.Name] = nil
                end
            end
            classify(child)
        end)
    end
    for _, child in ipairs(obj:GetChildren()) do
        classify(child)
    end
    result._connections.ChildAdded = obj.ChildAdded:Connect(classify)
    result._connections.ChildRemoved = obj.ChildRemoved:Connect(function(child)
        for _, cat in pairs(result) do
            if type(cat) == "table" then
                cat[child.Name] = nil
            end
        end
        if result._connections[child] then
            result._connections[child]:Disconnect()
            result._connections[child] = nil
        end
    end)
    result._connections.Destroying = obj.Destroying:Connect(function()
        for _, c in pairs(result._connections) do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end
    end)

    return result
end
