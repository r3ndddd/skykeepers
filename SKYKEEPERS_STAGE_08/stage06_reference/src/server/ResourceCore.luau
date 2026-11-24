-- All inputs are constructed by the server-side adapter, never by a RemoteEvent client.
local Resource = {}
Resource.__index = Resource
function Resource.new(inventory, playerLive, resourceLive)
 return setmetatable({inventory=inventory,playerLive=playerLive,resourceLive=resourceLive,resources={}},Resource)
end
function Resource:register(id)
 if id==nil or self.resources[id] then return false end
 self.resources[id]={available=true}
 return true
end
function Resource:restore(id)
 local state=self.resources[id]
 if not state or not self.resourceLive(id) then return false end
 state.available=true
 return true
end
function Resource:gather(player,id,request,amount,distance,now)
 local session=self.inventory.sessions[player]
 if not session or not self.playerLive(player) then return false,'player' end
 local state=id~=nil and self.resources[id]
 if not state or not self.resourceLive(id) then return false,'resource' end
 if type(request)~='number' or request~=request or request==math.huge or request%1~=0 or request<=session.lastRequest then return false,'request' end
 if type(distance)~='number' or distance~=distance or distance<0 or distance>12 then return false,'distance' end
 if type(now)~='number' or now~=now or now==math.huge or now==-math.huge then return false,'time' end
 if now-session.lastAt<0.5 then return false,'rate' end
 if not state.available then return false,'unavailable' end
 if not self.inventory:award(player,amount) then return false,'award' end
 session.lastRequest=request; session.lastAt=now; state.available=false
 return true,'ok'
end
return Resource
