-- Adapter creates every input on the server. Gather path and RNG must not yield.
local Resource={};Resource.__index=Resource
local function finite(x) return type(x)=="number" and x==x and math.abs(x)<math.huge end
function Resource.new(inventory,catalog,drop,random,playerLive,resourceLive)
 return setmetatable({inventory=inventory,catalog=catalog,drop=drop,random=random,playerLive=playerLive,resourceLive=resourceLive,resources={}},Resource)
end
function Resource:register(node,zone)
 if node==nil or self.resources[node] or type(zone)~="string" or not self.catalog.Zones[zone] then return false end
 self.resources[node]={available=true,zone=zone};return true
end
function Resource:restore(node)
 local state=self.resources[node]
 if not state or not self.resourceLive(node) then return false end
 state.available=true;return true
end
function Resource:gather(player,node,request,distance,now)
 local session=self.inventory.sessions[player]
 if not session or not self.playerLive(player) then return false,"player" end
 local state=node~=nil and self.resources[node]
 if not state or not self.resourceLive(node) then return false,"resource" end
 if not finite(request) or request%1~=0 or request<=session.lastRequest then return false,"request" end
 if not finite(distance) or distance<0 or distance>12 then return false,"distance" end
 if not finite(now) then return false,"time" end
 if now-session.lastAt<0.5 then return false,"rate" end
 if not state.available then return false,"unavailable" end
 local selected,reason=self.drop.choose(self.catalog,state.zone,self.random())
 if not selected then return false,reason end
 if not self.inventory:award(player,selected.id,1) then return false,"award" end
 session.lastRequest=request;session.lastAt=now;state.available=false
 return true,selected
end
return Resource
