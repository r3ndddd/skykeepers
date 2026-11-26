-- Server-only transaction; injected liveness checks must not yield.
local Economy={};Economy.__index=Economy
local MAX=9007199254740991
local MAX_REQUESTS=4096
local function integer(n)
 return type(n)=="number" and n==n and n>=0 and n<=MAX and n%1==0
end
function Economy.new(inventory,catalog,isPlayerLive,canTrade)
 return setmetatable({inventory=inventory,catalog=catalog,isPlayerLive=isPlayerLive,canTrade=canTrade},Economy)
end
function Economy:sell(player,id,quantity,requestId)
 local session=self.inventory.sessions[player]
 if not session or not self.isPlayerLive(player) then return false,"player" end
 if type(requestId)~="string" or #requestId<1 or #requestId>64 or not requestId:match("^[%w_%-]+$") then return false,"request" end
 if session.saleRequests[requestId] then return false,"duplicate" end
 if session.saleRequestCount>=MAX_REQUESTS then return false,"request_limit" end
 session.saleRequests[requestId]=true
 session.saleRequestCount+=1
 if not self.canTrade(player) then return false,"merchant" end
 if type(id)~="string" or #id>64 then return false,"resource" end
 local item=self.catalog.ById[id]
 if not item then return false,"resource" end
 local owned=session.counts[id]
 if not integer(owned) or not integer(session.coins) then return false,"state" end
 if quantity=="all" then quantity=owned end
 if not integer(quantity) or quantity==0 then return false,"quantity" end
 if quantity>owned then return false,"insufficient" end
 local price=item.value
 if not integer(price) or price==0 then return false,"price" end
 if quantity>math.floor((MAX-session.coins)/price) then return false,"overflow" end
 local earned=quantity*price
 if not integer(earned) or earned>MAX-session.coins then return false,"overflow" end
 -- No yielding calls from checks through these writes: one Luau task commits together.
 session.counts[id]=owned-quantity
 session.coins+=earned
 return true,{id=id,quantity=quantity,earned=earned,balance=session.coins,remaining=session.counts[id]}
end
return Economy
