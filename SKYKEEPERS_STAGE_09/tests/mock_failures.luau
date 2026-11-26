local Core = require("../prototype/ProfileCore")
local Store = require("./mock_store")
local count = 0
local function check(name, ok) count += 1; assert(ok, "FAIL "..name); print("PASS "..name) end
local store = Store.new()
local function acquire(owner, now)
 return store:UpdateAsync("user_42", function(current) return Core.acquire(current, owner, now, 900) end)
end
local a = acquire("A",1000)
local profile = Core.copy(a.Profile); profile.Inventory.Cloudwood = 3
profile.Inventory.Cloudwood -= 1; profile.SkyCoins += 5
local function save(owner, release)
 return store:UpdateAsync("user_42", function(current) return Core.save(current,owner,1001,900,profile,release) end)
end
store.failures = 1
local ok = pcall(function() save("A",true) end)
check("failed write leaves old profile untouched", not ok and store.data.user_42.Profile.Inventory.Cloudwood == 0)
check("write retry saves consistent sale", save("A",true).Profile.SkyCoins == 5 and store.data.user_42.Profile.Inventory.Cloudwood == 2)
local b = acquire("B",1002)
check("same key reloads saved values", b.Profile.SkyCoins == 5 and b.Profile.Inventory.Cloudwood == 2)
local before = store.writes
check("competing server cannot acquire", acquire("C",1003) == nil and store.writes == before)
check("stale writer cannot change state", save("A",false) == nil and store.data.user_42.Lock.Owner == "B")
store.failures = 1
ok = pcall(function() acquire("B",1004) end)
check("load failure does not create empty profile", not ok and store.data.user_42.Profile.Inventory.Cloudwood == 2)
print("TOTAL "..count.." PASS / 0 FAIL")
