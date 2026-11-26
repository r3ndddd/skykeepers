-- CLOUD TEST ONLY: hard-bound to the newly created, private test universe.
-- The regular default.project.json continues to use MockDataStore.
local EXPECTED_UNIVERSE_ID=10779228953
assert(game.GameId==EXPECTED_UNIVERSE_ID,"Refusing DataStore access outside Stage 0.9 test universe")
local Inventory=require(script.Parent.InventoryService)
local Catalog=require(script.Parent.ResourceCatalog)
local Service=require(script.Parent.PlayerDataService)
local Core=require(script.Parent.ProfileCore)
local Cloud=require(script.Parent.IsolatedCloudStore)
local http=game:GetService("HttpService")
local store,budget=Cloud.open(EXPECTED_UNIVERSE_ID)
return Inventory.new(Catalog,Service.new(Core,store,os.time,task.wait,function() return http:GenerateGUID(false) end,budget))
