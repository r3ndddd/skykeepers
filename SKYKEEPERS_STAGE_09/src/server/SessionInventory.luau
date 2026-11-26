-- Explicit mock-only configuration. Never opens a Roblox DataStore.
local Inventory=require(script.Parent.InventoryService)
local Catalog=require(script.Parent.ResourceCatalog)
local Service=require(script.Parent.PlayerDataService)
local Core=require(script.Parent.ProfileCore)
local Mock=require(script.Parent.MockDataStore)
local HttpService=game:GetService("HttpService")
local data=Service.new(Core,Mock.new(),os.time,task.wait,function() return HttpService:GenerateGUID(false) end)
return Inventory.new(Catalog,data)
