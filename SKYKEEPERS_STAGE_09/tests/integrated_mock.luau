local Core=require('../prototype/ProfileCore')
local Data=require('../src/server/PlayerDataService')
local Mock=require('../src/server/MockDataStore')
local Inventory=require('../src/server/InventoryService')
local Economy=require('../src/server/EconomyCore')
local Catalog=require('../src/shared/ResourceCatalog')
local Resource=require('../src/server/ResourceCore')
local Drop=require('../src/server/DropService')
local now=1000;local seq=0;local store=Mock.new()
local function newData(s)
 return Data.new(Core,s,function()return now end,function()end,function()seq+=1;return 'owner'..seq end)
end
local data=newData(store);local inv=Inventory.new(Catalog,data)
local player={UserId=42};local player2={UserId=43}
local econ=Economy.new(inv,Catalog,function()return true end,function()return true end)
local rc=Resource.new(inv,Catalog,Drop,function()return 0 end,function()return true end,function()return true end)
local node={};assert(rc:register(node,'WhisperingMeadows'))
local n=0
local function check(name,condition) n+=1;assert(condition,'FAIL '..name);print('PASS '..name) end
check('gather denied before load',not rc:gather(player,node,1,1,1000))
check('sell denied before load',not econ:sell(player,'Cloudwood',1,'a'))
check('load then join',data:load(player) and inv:join(player))
check('server gather',rc:gather(player,node,1,1,1000) and inv:balance(player,'Cloudwood')==1)
check('second server reward',inv:award(player,'Cloudwood',1))
local ok,res=econ:sell(player,'Cloudwood',1,'sale-1')
check('atomic sale 1 to 5',ok and res.remaining==1 and res.balance==5)
check('duplicate sale denied',not econ:sell(player,'Cloudwood',1,'sale-1') and inv:balance(player,'Cloudwood')==1)
local snap=inv:snapshot(player);snap.Inventory.Cloudwood=99;snap.SkyCoins=999
check('snapshot cannot mutate profile',inv:balance(player,'Cloudwood')==1 and inv:snapshot(player).SkyCoins==5)
check('concurrent server locked',not newData(store):load({UserId=42}))
check('second player isolated',data:load(player2) and inv:join(player2) and inv:balance(player2,'Cloudwood')==0)
check('save consistent pair',data:save(player,false) and store.data.user_42.Profile.SkyCoins==5 and store.data.user_42.Profile.Inventory.Cloudwood==1)
inv:leave(player);check('close releases',data:close(player) and store.data.user_42.Lock==nil)
local reconnect={UserId=42};check('same userid reconnect',data:load(reconnect) and inv:join(reconnect) and inv:balance(reconnect,'Cloudwood')==1 and inv:snapshot(reconnect).SkyCoins==5)
now=2000
check('expired lease blocks awards and sales',not inv:award(reconnect,'Cloudwood',1) and not econ:sell(reconnect,'Cloudwood',1,'expired'))
check('blocked cannot save',not data:save(reconnect,false))
local failure={UpdateAsync=function()error('transient failure')end}
local bad=newData(failure);local p3={UserId=44};check('load failure blocks profile',not bad:load(p3) and not bad:award(p3,'Cloudwood'))
local corrupt=Mock.new();corrupt.data.user_45={Profile={SchemaVersion=2},Lock=nil}
local wrong=newData(corrupt);local p4={UserId=45};check('corrupt data not overwritten',not wrong:load(p4) and corrupt.data.user_45.Profile.SchemaVersion==2)
print('TOTAL '..n..' PASS / 0 FAIL')
