-- Server-only, session-scoped inventory. No client chooses an award.
local Inventory = {}
Inventory.__index = Inventory
local MAX = 9007199254740991
function Inventory.new()
 return setmetatable({sessions={}},Inventory)
end
function Inventory:join(player)
 if player == nil or self.sessions[player] then return false end
 self.sessions[player] = {Cloudwood=0, lastRequest=0, lastAt=-math.huge}
 return true
end
function Inventory:leave(player)
 self.sessions[player] = nil
end
function Inventory:balance(player)
 local session=self.sessions[player]
 return session and session.Cloudwood or nil
end
function Inventory:award(player, amount)
 local session=self.sessions[player]
 if not session or type(amount)~='number' or amount~=1 then return false end
 local v=session.Cloudwood
 if type(v)~='number' or v~=v or v<0 or v%1~=0 or v>=MAX then return false end
 session.Cloudwood=v+1
 return true
end
return Inventory
