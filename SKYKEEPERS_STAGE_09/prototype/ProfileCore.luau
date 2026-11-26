-- Prototype only: pure UpdateAsync transforms. Not connected to gameplay or cloud.
local Core = {}
local MAX = 9007199254740991
local ids = {"Cloudwood", "Skyglass", "Starbloom", "Mistwood", "Moonstone", "AncientBark", "StormEssence", "CelestialOre", "TempestCore"}
local allowed = {}
for _, id in ipairs(ids) do allowed[id] = true end
local function integer(n)
 return type(n) == "number" and n == n and n >= 0 and n <= MAX and n % 1 == 0
end
function Core.newProfile()
 local inventory = {}
 for _, id in ipairs(ids) do inventory[id] = 0 end
 return {SchemaVersion = 1, SkyCoins = 0, Inventory = inventory}
end
function Core.valid(p)
 if type(p) ~= "table" or p.SchemaVersion ~= 1 or not integer(p.SkyCoins) or type(p.Inventory) ~= "table" then return false end
 for key in pairs(p) do if key ~= "SchemaVersion" and key ~= "SkyCoins" and key ~= "Inventory" then return false end end
 for id, n in pairs(p.Inventory) do if not allowed[id] or not integer(n) then return false end end
 for _, id in ipairs(ids) do if not integer(p.Inventory[id]) then return false end end
 return true
end
function Core.copy(p)
 local inv = {}
 for _, id in ipairs(ids) do inv[id] = p.Inventory[id] end
 return {SchemaVersion = 1, SkyCoins = p.SkyCoins, Inventory = inv}
end
local function validRecord(record)
 return type(record) == "table" and Core.valid(record.Profile) and
  (record.Lock == nil or (type(record.Lock) == "table" and type(record.Lock.Owner) == "string" and #record.Lock.Owner > 0 and integer(record.Lock.ExpiresAt)))
end
function Core.acquire(record, owner, now, lease)
 if type(owner) ~= "string" or #owner == 0 or not integer(now) or not integer(lease) or lease < 600 or now > MAX - lease then return nil end
 if record ~= nil and not validRecord(record) then return nil end
 if record and record.Lock and record.Lock.Owner ~= owner and record.Lock.ExpiresAt > now then return nil end
 return {Profile = record and Core.copy(record.Profile) or Core.newProfile(), Lock = {Owner = owner, ExpiresAt = now + lease}}
end
function Core.save(record, owner, now, lease, snapshot, release)
 if not validRecord(record) or not record.Lock or record.Lock.Owner ~= owner or not integer(now) or record.Lock.ExpiresAt <= now or not Core.valid(snapshot) then return nil end
 if not release and (not integer(lease) or lease < 600 or now > MAX - lease) then return nil end
 local result = {Profile = Core.copy(snapshot)}
 if not release then result.Lock = {Owner = owner, ExpiresAt = now + lease} end
 return result
end
return Core
