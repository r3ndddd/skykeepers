-- Local-only mock; injected failures precede the transform. Not a Cloud emulator.
local Store = {}; Store.__index = Store
function Store.new() return setmetatable({data = {}, failures = 0, writes = 0}, Store) end
function Store:UpdateAsync(key, transform)
 if self.failures > 0 then self.failures -= 1; error("simulated datastore unavailable") end
 local result = transform(self.data[key])
 if result ~= nil then self.data[key] = result; self.writes += 1 end
 return result
end
return Store
