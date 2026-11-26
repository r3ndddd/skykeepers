local Core=require('../prototype/ProfileCore');local Data=require('../src/server/PlayerDataService');local Mock=require('../src/server/MockDataStore')
local base=Mock.new();local now=1000;local uid=0;local fails=0;local calls=0;local replay=false;local pause=false;local budget=true
local proxy={}
function proxy:UpdateAsync(key,fn)
 calls+=1;if fails>0 then fails-=1;error('test fault') end
 if pause then coroutine.yield('waiting') end
 if replay then fn(base.data[key]) end
 return base:UpdateAsync(key,fn)
end
local svc=Data.new(Core,proxy,function()return now end,function()coroutine.yield('wait')end,function()uid+=1;return 'id-'..uid end,function()return budget end)
local n=0;local function check(name,ok)n+=1;assert(ok,'FAIL '..name);print('PASS '..name)end
local p={UserId=71};replay=true;check('repeated UpdateAsync callback acquisition',svc:load(p));replay=false
check('reward before save',svc:award(p,'Cloudwood'))
local before=base.data.user_71.Profile.Inventory.Cloudwood
fails=3
local co=coroutine.create(function()return svc:save(p,false)end)
local ok,phase=coroutine.resume(co);check('failed write retry 1',ok and phase=='wait')
ok,phase=coroutine.resume(co);check('failed write retry 2',ok and phase=='wait')
ok,phase=coroutine.resume(co);check('failed write blocks future award',ok and phase==false and not svc:award(p,'Cloudwood'))
check('failed write does not replace data',base.data.user_71.Profile.Inventory.Cloudwood==before)
local p2={UserId=72};budget=false;local previous=calls
local load=coroutine.create(function()return svc:load(p2)end)
coroutine.resume(load);coroutine.resume(load);local ended,result=coroutine.resume(load)
check('budget exhaustion rejects without store call',ended and result==false and calls==previous and not svc:award(p2,'Cloudwood'))
budget=true;local p3={UserId=73};pause=true
local loading=coroutine.create(function()return svc:load(p3)end);local started,event=coroutine.resume(loading)
check('load in flight',started and event=='waiting')
check('exit while loading',svc:close(p3))
pause=false;local finished,loaded=coroutine.resume(loading)
check('late load released',finished and loaded==false and base.data.user_73.Lock==nil and not svc:award(p3,'Cloudwood'))
local p4={UserId=74};check('saving player loaded',svc:load(p4));check('saving player award',svc:award(p4,'Cloudwood'))
pause=true;local saving=coroutine.create(function()return svc:save(p4,false)end);coroutine.resume(saving)
check('action denied while saving',not svc:award(p4,'Cloudwood'))
local closing=coroutine.create(function()return svc:close(p4)end);local c,w=coroutine.resume(closing);check('exit waits for save',c and w=='wait')
pause=false;local s,saved=coroutine.resume(saving);check('in-flight save completes',s and saved)
check('closing blocks new actions',not svc:award(p4,'Cloudwood'))
local q,closed=coroutine.resume(closing);check('final save releases lock',q and closed and base.data.user_74.Lock==nil and base.data.user_74.Profile.Inventory.Cloudwood==1)
local p5={UserId=75};check('load stale-owner fixture',svc:load(p5));check('award stale-owner fixture',svc:award(p5,'Cloudwood'))
base.data.user_75.Lock={Owner='other-server',ExpiresAt=now+900}
check('confirmed lock loss blocks save',not svc:save(p5,false))
check('confirmed lock loss blocks awards',not svc:award(p5,'Cloudwood'))
check('other owner data remains intact',base.data.user_75.Lock.Owner=='other-server' and base.data.user_75.Profile.Inventory.Cloudwood==0)
local p6={UserId=76};base.data.user_76={Profile=Core.newProfile(),Lock=nil};base.data.user_76.Profile.SkyCoins=42
local original=base.data.user_76;fails=3
local failedLoad=coroutine.create(function()return svc:load(p6)end)
coroutine.resume(failedLoad);coroutine.resume(failedLoad);local done,loadedAgain=coroutine.resume(failedLoad)
check('failed load preserves existing data',done and not loadedAgain and base.data.user_76==original and base.data.user_76.Profile.SkyCoins==42 and not svc:award(p6,'Cloudwood'))
local p7={UserId=77};base.data.user_77={Profile=Core.newProfile()};base.data.user_77.Profile.SchemaVersion=9
check('unknown migration rejected without overwrite',not svc:load(p7) and base.data.user_77.Profile.SchemaVersion==9)
print('TOTAL '..n..' PASS / 0 FAIL')
