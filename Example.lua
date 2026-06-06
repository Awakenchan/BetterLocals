local Boot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/BetterLocals/refs/heads/main/BetterLocal.lua"))()

local RecursiveTable = Boot.RecursiveTable
local GlobalsTable = Boot.GlobalsTable
local CharacterPart = Boot.CharacterPart
local LocalPlayer = Boot.LocalPlayer

local ReplicatedStorage = GlobalsTable.ReplicatedStorage
local ReplicatedStorageData = RecursiveTable(ReplicatedStorage)

local Data2Code = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV3/refs/heads/main/Utility/Data2Code.luau"))()

print(
    Data2Code.Convert(ReplicatedStorageData, true),
    " other usage >",
    CharacterPart.Head().Position,
    LocalPlayer():GetFullName()
)
