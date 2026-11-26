local core = require("../prototype/ProfileCore")
local total = 0
local function check(name, condition)
 total += 1
 if not condition then error("FAIL " .. name) end
 print("PASS " .. name)
end
local p = core.newProfile()
check("new profile", core.valid(p) and p.Inventory.Cloudwood == 0 and p.SkyCoins == 0)
local a = core.acquire(nil, "server-a", 1000, 900)
check("first acquire", a and a.Lock.Owner == "server-a")
check("conflict", core.acquire(a, "server-b", 1100, 900) == nil)
check("short lease rejected", core.acquire(nil, "x", 0, 30) == nil)
local b = core.acquire(a, "server-b", 1900, 900)
check("expired lock recovered", b and b.Lock.Owner == "server-b")
p.Inventory.Cloudwood = 2; p.SkyCoins = 5
check("stale owner cannot save", core.save(b, "server-a", 1901, 900, p, false) == nil)
check("expired owner cannot save", core.save(a, "server-a", 1900, 900, p, false) == nil)
local saved = core.save(b, "server-b", 1901, 900, p, true)
check("save and release", saved and saved.Lock == nil and saved.Profile.Inventory.Cloudwood == 2 and saved.Profile.SkyCoins == 5)
p.Inventory.Cloudwood = 99
check("snapshot detached", saved.Profile.Inventory.Cloudwood == 2)
local reload = core.acquire(saved, "server-c", 2000, 900)
check("reload", reload and reload.Profile.Inventory.Cloudwood == 2 and reload.Profile.SkyCoins == 5)
local invalid = core.newProfile(); invalid.SkyCoins = -1
check("negative rejected", not core.valid(invalid) and core.save(reload,"server-c",2001,900,invalid,false)==nil)
invalid.SkyCoins = 0/0; check("nan rejected", not core.valid(invalid))
invalid.SkyCoins = math.huge; check("infinity rejected", not core.valid(invalid))
invalid = core.newProfile(); invalid.Inventory.Unknown = 1; check("unknown resource rejected", not core.valid(invalid))
invalid = core.newProfile(); invalid.SchemaVersion = 2; check("future schema rejected", not core.valid(invalid))
invalid = core.newProfile(); invalid.Inventory.Cloudwood = nil; check("missing field rejected", not core.valid(invalid))
check("corrupt record not replaced", core.acquire({Profile = invalid},"server-d",2000,900)==nil)
print("TOTAL " .. total .. " PASS / 0 FAIL")
