local Catalog=require('../src/shared/ResourceCatalog')
local Drop=require('../src/server/DropService')
local Inventory=require('../src/server/InventoryService')
local Core=require('../src/server/ResourceCore')
local tests,passes=0,0
local function test(name,fn)
 tests+=1;local ok,err=pcall(fn)
 if ok then passes+=1;print('PASS '..name) else print('FAIL '..name..' '..tostring(err)) end
end
local function near(a,b) return math.abs(a-b)<1e-9 end
local expected={
 WhisperingMeadows={72,{3.5,3,1.5},{.70,.25,.05},{5,12,30},9},
 CrystalRuins={158.2,{6.6,12,4},{.55,.40,.05},{12,30,80},7},
 StormTemple={211.2,{18,30.4,4.4},{.60,.38,.02},{30,80,220},4},
}
for zoneId,e in pairs(expected) do
 test(zoneId..' contributions, sum, route',function()
  local z=Catalog.Zones[zoneId];local sum,value=0,0
  assert(z.gathers==e[5]);assert(Drop.validate(z.drops,Catalog.ById,zoneId))
  for i,row in ipairs(z.drops) do
   assert(near(row.probability,e[3][i]) and row.value==e[4][i]);local term=row.probability*row.value
   assert(near(term,e[2][i]));sum+=row.probability;value+=term
  end
  assert(near(sum,1) and near(value*z.gathers,e[1]))
 end)
end
test('nine resources and five unassigned rarity tiers',function() local n=0 for _,v in pairs(Catalog.ById) do n+=1;assert(v.rarity==nil and v.rarityStatus=='PENDING_APPROVAL') end assert(n==9 and #Catalog.RarityLevels==5) end)
test('inventory accepts each approved resource independently',function()
 local inv=Inventory.new(Catalog);local player={};assert(inv:join(player))
 for id in pairs(Catalog.ById) do assert(inv:award(player,id,1));assert(inv:balance(player,id)==1) end
end)
test('CDF boundary and random validation',function()
 local z='WhisperingMeadows'
 assert(Drop.choose(Catalog,z,0).id=='Cloudwood')
 assert(Drop.choose(Catalog,z,.699999999).id=='Cloudwood')
 assert(Drop.choose(Catalog,z,.70).id=='Skyglass')
 assert(Drop.choose(Catalog,z,.95).id=='Starbloom')
 assert(not Drop.choose(Catalog,z,1) and not Drop.choose(Catalog,z,0/0) and not Drop.choose(Catalog,z,math.huge))
end)
test('unknown zone',function() assert(not Drop.choose(Catalog,'fake',.1)) end)
local function invalid(rows)
 local by={} for _,r in pairs(rows) do if type(r)=='table' and r.id then by[r.id]=r end end
 return not Drop.validate(rows,by,'z')
end
test('empty table',function() assert(invalid({})) end)
test('probability totals below and above 1',function() assert(invalid({{id='a',zone='z',probability=.9,value=1}}));assert(invalid({{id='a',zone='z',probability=1.01,value=1}})) end)
test('negative probability',function() assert(invalid({{id='a',zone='z',probability=-.1,value=1}})) end)
test('wrong types, NaN and Infinity',function() for _,v in {'bad',0/0,math.huge,-math.huge} do assert(invalid({{id='a',zone='z',probability=v,value=1}})) end;assert(not Drop.validate('bad',{},'z')) end)
test('unknown resource and hole',function() assert(not Drop.validate({{id='fake',zone='z',probability=1,value=1}},Catalog.ById,'z'));assert(invalid({[2]={id='a',zone='z',probability=1,value=1}})) end)
local function fixture()
 local inv=Inventory.new(Catalog);local a={live=true};local b={live=true};local node={live=true};inv:join(a);inv:join(b)
 local core=Core.new(inv,Catalog,Drop,function()return .1 end,function(p)return p.live end,function(n)return n.live end)
 assert(core:register(node,'WhisperingMeadows'));return inv,core,a,b,node
end
test('concurrent claims: one award',function() local i,c,a,b,n=fixture();assert(c:gather(a,n,1,1,1));assert(not c:gather(b,n,1,1,1));assert(i:balance(a,'Cloudwood')+i:balance(b,'Cloudwood')==1) end)
test('replay and cooldown',function()local i,c,a,b,n=fixture();assert(c:gather(a,n,7,1,1));assert(not c:gather(b,n,1,1,2));assert(c:restore(n));assert(not c:gather(a,n,7,1,3));assert(i:balance(a,'Cloudwood')==1)end)
test('distance and nonexistent node',function()local i,c,a,_,n=fixture();assert(not c:gather(a,n,1,12.01,1));assert(not c:gather(a,{},1,1,1));assert(i:balance(a,'Cloudwood')==0)end)
test('removed node and player disconnect',function()local i,c,a,_,n=fixture();n.live=false;assert(not c:gather(a,n,1,1,1));n.live=true;i:leave(a);assert(not c:gather(a,n,1,1,1));assert(i:balance(a,'Cloudwood')==nil)end)
test('invalid zone registration',function()local _,c,_,_,_=fixture();assert(not c:register({},'fake'))end)
test('inventory invalid ids amounts and overflow',function()local i,_,a=fixture();assert(not i:award(a,'fake',1));for _,v in {-1,0,2,1e100,0/0,math.huge} do assert(not i:award(a,'Cloudwood',v)) end;i.sessions[a].counts.Cloudwood=9007199254740991;assert(not i:award(a,'Cloudwood',1))end)
test('player isolation and fresh reconnect',function()local i,c,a,b,n=fixture();assert(c:gather(a,n,1,1,1));assert(i:balance(b,'Cloudwood')==0);i:leave(a);assert(i:join(a));for id in pairs(Catalog.ById) do assert(i:balance(a,id)==0) end end)
test('NaN Infinity and wrong argument types',function()local i,c,a,_,n=fixture();for _,v in {0/0,math.huge,-math.huge,'bad'} do assert(not c:gather(a,n,1,v,1));assert(not c:gather(a,n,v,1,1));assert(not c:gather(a,n,1,1,v)) end;assert(i:balance(a,'Cloudwood')==0)end)
-- Deterministic LCG and fixed tolerance 0.006, declared before sampling.
local samples=100000;local tolerance=0.006
for zoneId in pairs(expected) do
 test('simulation '..zoneId,function()
  local state=12648430;local counts={}
  for _=1,samples do
   state=(1664525*state+1013904223)%4294967296
   local item=assert(Drop.choose(Catalog,zoneId,state/4294967296));counts[item.id]=(counts[item.id] or 0)+1
  end
  for _,item in ipairs(Catalog.Zones[zoneId].drops) do
   local count=counts[item.id] or 0;local observed=count/samples
   print(string.format('SIM %s %s n=%d count=%d observed=%.5f expected=%.5f tolerance=%.5f',zoneId,item.id,samples,count,observed,item.probability,tolerance))
   assert(math.abs(observed-item.probability)<=tolerance)
  end
 end)
end
print(string.format('TOTAL %d PASS %d FAIL %d',tests,passes,tests-passes))
assert(tests==passes,'Stage07 tests failed')
