-- One shared session store for collection and transactions in this server.
local Inventory=require(script.Parent.InventoryService)
local Catalog=require(script.Parent.ResourceCatalog)
return Inventory.new(Catalog)
