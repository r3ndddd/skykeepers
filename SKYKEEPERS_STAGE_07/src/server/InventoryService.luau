-- Session-only, no DataStore, no currency. Inventory operations do not yield.
local Inventory={}
Inventory.__index=Inventory
local MAX=9007199254740991
function Inventory.new(catalog)
 return setmetatable({catalog=catalog,sessions={}},Inventory)
end
function Inventory:join(player)
 if player==nil or self.sessions[player] then return false end
 local counts={}
 for id in pairs(self.catalog.ById) do counts[id]=0 end
 self.sessions[player]={counts=counts,lastRequest=0,lastAt=-math.huge}
 return true
end
function Inventory:leave(player) self.sessions[player]=nil end
function Inventory:balance(player,id)
 local s=self.sessions[player]
 if not s or type(id)~="string" or not self.catalog.ById[id] then return nil end
 return s.counts[id]
end
function Inventory:award(player,id,amount)
 local s=self.sessions[player]
 if not s or type(id)~="string" or not self.catalog.ById[id] or amount~=1 then return false end
 local v=s.counts[id]
 if type(v)~="number" or v~=v or v<0 or v%1~=0 or v>=MAX then return false end
 s.counts[id]=v+1
 return true
end
return Inventory
