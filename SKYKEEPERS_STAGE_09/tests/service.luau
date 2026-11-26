local Core=require("../prototype/ProfileCore")
local Service=require("../prototype/PlayerDataService")
local Store=require("./mock_store")
local total=0
local function check(name,value) total+=1; assert(value,"FAIL "..name); print("PASS "..name) end
local store=Store.new(); local now=1000; local waits=0
local a=Service.new(Core,store,function() return now end,function() waits+=1 end,"A",900)
local b=Service.new(Core,store,function() return now end,function() end,"B",900)
store.failures=2
local profile=a:load(42)
check("transient load retries",profile and waits==2 and profile.SkyCoins==0)
check("same user cannot load twice",a:load(42)==nil)
check("second owner denied",b:load(42)==nil)
profile.Inventory.Cloudwood=2; profile.SkyCoins=5; check("mark dirty",a:changed(42))
check("save",a:save(42,false) and store.data.user_42.Profile.SkyCoins==5 and store.data.user_42.Profile.Inventory.Cloudwood==2)
check("release",a:save(42,true) and a.sessions[42]==nil)
local nextProfile=b:load(42)
check("new session loads state",nextProfile and nextProfile.SkyCoins==5 and nextProfile.Inventory.Cloudwood==2)
store.failures=3
check("failed final save blocks session",not b:save(42,true) and b.sessions[42].state=="blocked")
check("failed save leaves last snapshot",store.data.user_42.Profile.SkyCoins==5)
check("blocked session cannot mark dirty",not b:changed(42))
local c=Service.new(Core,store,function()return now end,function()end,"C",900)
store.failures=3; check("failed load creates no session",c:load(43)==nil and c.sessions[43]==nil and store.data.user_43==nil)
now=2000
local recovered=c:load(42)
check("expired lock recovered",recovered and recovered.SkyCoins==5)
print("TOTAL "..total.." PASS / 0 FAIL")
