-- Request metadata only; persistent fields belong to PlayerDataService.
local Inventory={};Inventory.__index=Inventory
function Inventory.new(catalog,data) return setmetatable({catalog=catalog,data=data,sessions={}},Inventory) end
function Inventory:join(player)
 if not self.data or not self.data:active(player) or self.sessions[player] then return false end
 self.sessions[player]={lastRequest=0,lastAt=-math.huge,saleRequests={},saleRequestCount=0};return true
end
function Inventory:leave(player) self.sessions[player]=nil end
function Inventory:balance(player,id)
 if type(id)~="string" or not self.catalog.ById[id] then return nil end
 local p=self.data:snapshot(player);return p and p.Inventory[id] or nil
end
function Inventory:award(player,id,amount)
 if not self.sessions[player] or type(id)~="string" or not self.catalog.ById[id] or amount~=1 then return false end
 return self.data:award(player,id)
end
function Inventory:snapshot(player) return self.data:snapshot(player) end
function Inventory:sell(player,id,quantity,price) return self.data:sell(player,id,quantity,price) end
return Inventory
