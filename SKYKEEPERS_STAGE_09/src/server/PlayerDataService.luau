-- Stage 0.9: injected backing store. Not enabled for a real DataStore.
local Service = {}
Service.__index = Service
local states=setmetatable({},{__mode="k"})
local MAX = 9007199254740991
local function integer(n) return type(n)=="number" and n==n and n>=0 and n<=MAX and n%1==0 end
function Service.new(core, store, clock, wait, newOwner, budget)
 local self=setmetatable({core=core,store=store,clock=clock,wait=wait,newOwner=newOwner,budget=budget or function() return true end},Service)
 states[self]={};return self
end
function Service:_update(key, transform)
 for attempt=1,3 do
  if self.budget() then
   local ok,result=pcall(function() return self.store:UpdateAsync(key,transform) end)
   if ok then return true,result end
  end
  if attempt<3 then self.wait(attempt) end
 end
 return false,nil
end
function Service:load(player)
 if not player then return false,"player" end
 local userId=player.UserId
 if type(userId)~="number" or userId~=userId or userId==0 or userId%1~=0 or userId>MAX or userId < -MAX or states[self][player] then return false,"player" end
 local s={state="LOADING",owner=self.newOwner(),key="user_"..tostring(player.UserId)}; states[self][player]=s
 local ok,record=self:_update(s.key,function(old) return self.core.acquire(old,s.owner,self.clock(),900) end)
 if s.state~="LOADING" then
  if ok and record then self:_update(s.key,function(old) return self.core.save(old,s.owner,self.clock(),900,record.Profile,true) end) end
  states[self][player]=nil; return false,"cancelled"
 end
 if not ok or not record then s.state="BLOCKED"; return false,"load-failed" end
 s.profile=self.core.copy(record.Profile);s.expires=record.Lock.ExpiresAt;s.state="ACTIVE";s.revision=0;s.savedRevision=0
 return true
end
function Service:active(player)
 local s=states[self][player]
 if s and s.state=="ACTIVE" and self.clock()<s.expires-30 then return true end
 if s and s.state=="ACTIVE" then s.state="BLOCKED" end
 return false
end
function Service:snapshot(player)
 if not self:active(player) then return nil end
 return self.core.copy(states[self][player].profile)
end
function Service:award(player,id)
 if not self:active(player) then return false end
 if type(id)~="string" then return false end
 local s=states[self][player];local p=s.profile;local amount=p.Inventory[id]
 if not integer(amount) or amount>=MAX then return false end
 p.Inventory[id]=amount+1;s.revision+=1;return true
end
function Service:sell(player,id,quantity,price)
 if not self:active(player) then return false,"inactive" end
 if type(id)~="string" then return false,"resource" end
 local s=states[self][player];local p=s.profile;local count=p.Inventory[id]
 if not integer(count) or not integer(p.SkyCoins) or not integer(price) or price==0 then return false,"resource" end
 if quantity=="all" then quantity=count end
 if not integer(quantity) or quantity==0 then return false,"quantity" end
 if quantity>count then return false,"insufficient" end
 if quantity>math.floor((MAX-p.SkyCoins)/price) then return false,"overflow" end
 local earned=quantity*price
 p.Inventory[id]=count-quantity;p.SkyCoins+=earned;s.revision+=1
 return true,{id=id,quantity=quantity,earned=earned,balance=p.SkyCoins,remaining=p.Inventory[id]}
end
function Service:save(player,release)
 local s=states[self][player]
 if not s or (s.state~="ACTIVE" and s.state~="CLOSING") then return false,"inactive" end
 if s.state=="ACTIVE" and not self:active(player) then return false,"expired" end
 if release then s.state="CLOSING" else s.state="SAVING" end
 local snapshot=self.core.copy(s.profile);local revision=s.revision
 local ok,record=self:_update(s.key,function(old) return self.core.save(old,s.owner,self.clock(),900,snapshot,release) end)
 if not ok or not record then s.state="BLOCKED";return false,"save-failed-or-lock-lost" end
 s.savedRevision=revision
 if release then s.state="RELEASED";states[self][player]=nil else s.expires=record.Lock.ExpiresAt;s.state=s.closeRequested and "CLOSING" or "ACTIVE" end
 return true
end
function Service:close(player)
 local s=states[self][player];if not s then return true end
 if s.state=="LOADING" then s.state="CLOSING";return true end
 if s.state=="SAVING" then
  s.closeRequested=true
  while states[self][player]==s and s.state=="SAVING" do self.wait(.1) end
 end
 if s.state=="ACTIVE" then s.state="CLOSING" end
 if s.state=="CLOSING" then return self:save(player,true) end
 if s.state=="BLOCKED" then states[self][player]=nil end
 return false
end
return Service
