local BetterLocals = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/BetterLocals/refs/heads/main/BetterLocal.lua"))()
repeat task.wait() until RecursiveTable ~= nil
local ReplicatedStorageData = RecursiveTable(ReplicatedStorage)
local Data2code = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV3/refs/heads/main/Utility/Data2Code.luau"))()
print(Data2code.Convert(ReplicatedStorageData,true), " other usage >",CharacterPart.Head().Position,LocalPlayer():GetFullName())
