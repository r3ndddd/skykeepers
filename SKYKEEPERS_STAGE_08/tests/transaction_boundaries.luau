-- Test-only boundary harness. Never pauses or modifies EconomyCore:sell.
local Catalog=require('../src/shared/ResourceCatalog')
local Inventory=require('../src/server/InventoryService')
local Economy=require('../src/server/EconomyCore')
local results={}
local function test(name,fn)
 local ok,err=pcall(fn);table.insert(results,{name=name,ok=ok,error=ok and nil or tostring(err)});print((ok and 'PASS ' or 'FAIL ')..name..(ok and '' or ': '..tostring(err)))
end
local function fixture()
 local inv=Inventory.new(Catalog);local a={live=true,near=true};local b={live=true,near=true};assert(inv:join(a));assert(inv:join(b));assert(inv:award(a,'Cloudwood',1));assert(inv:award(b,'Cloudwood',1));local core=Economy.new(inv,Catalog,function(p)return p.live end,function(p)return p.near end);return inv,core,a,b
end
local function verifyB(inv,core,b)
 assert(inv:balance(b,'Cloudwood')==1 and inv.sessions[b].coins==0)
 assert(core:sell(b,'Cloudwood',1,'b'));assert(inv:balance(b,'Cloudwood')==0 and inv.sessions[b].coins==5)
 assert(not core:sell(b,'Cloudwood',1,'b'));assert(inv.sessions[b].coins==5)
end
test('A disconnect before transaction',function()
 local inv,core,a,b=fixture();local saved=inv.sessions[a];a.live=false;inv:leave(a)
 assert(not core:sell(a,'Cloudwood',1,'a'));assert(inv.sessions[a]==nil and saved.counts.Cloudwood==1 and saved.coins==0)
 assert(not core:sell(a,'Cloudwood',1,'a'));verifyB(inv,core,b)
end)
test('B test preflight then disconnect before real sell',function()
 local inv,core,a,b=fixture();local saved=inv.sessions[a]
 -- Independent preflight is not the production validation; sell revalidates on entry.
 assert(a.live and a.near and inv:balance(a,'Cloudwood')>=1 and Catalog.ById.Cloudwood.value==5)
 a.live=false;inv:leave(a)
 assert(not core:sell(a,'Cloudwood',1,'a'));assert(inv.sessions[a]==nil and saved.counts.Cloudwood==1 and saved.coins==0)
 assert(not core:sell(a,'Cloudwood',1,'a'));verifyB(inv,core,b)
end)
test('C commit then disconnect before harness response',function()
 local inv,core,a,b=fixture();local saved=inv.sessions[a];local ok,result=core:sell(a,'Cloudwood',1,'a')
 assert(ok and result.remaining==0 and result.balance==5 and saved.counts.Cloudwood==0 and saved.coins==5)
 a.live=false;inv:leave(a);local responseSent=false;if a.live then responseSent=true end
 assert(not responseSent and inv.sessions[a]==nil and saved.counts.Cloudwood==0 and saved.coins==5)
 assert(not core:sell(a,'Cloudwood',1,'a'));verifyB(inv,core,b)
end)
local n=0;for _,r in ipairs(results)do if r.ok then n+=1 end end;print(string.format('TOTAL %d PASS %d FAIL %d',#results,n,#results-n));assert(n==#results,'boundary harness failed')
