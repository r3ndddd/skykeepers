local Core=require("../prototype/ProfileCore")
local Service=require("../prototype/PlayerDataService")
local Store=require("./mock_store")
local base=Store.new(); local count=0; local pause=false; local now=1000
local proxy={}
function proxy:UpdateAsync(key, callback)
 if pause then coroutine.yield("in-flight") end
 return base:UpdateAsync(key, callback)
end
local function check(name,ok) count+=1;assert(ok,"FAIL "..name); print("PASS "..name) end
local a=Service.new(Core,proxy,function()return now end,function()end,"A",900)
pause=true
local loader=coroutine.create(function() return a:load(8) end)
local ok,event=coroutine.resume(loader)
check("load paused",ok and event=="in-flight")
check("departure cancels loading",a:cancelLoading(8))
check("same identity blocked while load pending",a:load(8)==nil)
pause=false
local resumed,profile,why=coroutine.resume(loader)
check("late load releases and never activates",resumed and profile==nil and why=="cancelled" and a.sessions[8]==nil and base.data.user_8.Lock==nil)
local p=a:load(9); p.Inventory.Cloudwood=1; a:changed(9)
pause=true
local saver=coroutine.create(function() return a:save(9,false) end)
check("save pauses",coroutine.resume(saver))
check("concurrent save rejected",not a:save(9,false))
p.Inventory.Cloudwood=2; a:changed(9); pause=false
check("snapshot completes",coroutine.resume(saver))
check("later change remains dirty",base.data.user_9.Profile.Inventory.Cloudwood==1 and a.sessions[9].revision>a.sessions[9].savedRevision)
check("next save persists change",a:save(9,false) and base.data.user_9.Profile.Inventory.Cloudwood==2)
now=2000
local b=Service.new(Core,base,function()return now end,function()end,"B",900)
check("replacement after expiry",b:load(9)~=nil)
check("old owner blocks after lock lost",not a:save(9,false) and a.sessions[9].state=="blocked")
print("TOTAL "..count.." PASS / 0 FAIL")
