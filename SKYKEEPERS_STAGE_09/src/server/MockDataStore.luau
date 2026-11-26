-- Volatile per-server mock. It never accesses Roblox Cloud.
local Mock={};Mock.__index=Mock
function Mock.new() return setmetatable({data={}},Mock) end
function Mock:UpdateAsync(key,callback)
 local nextValue=callback(self.data[key]);if nextValue~=nil then self.data[key]=nextValue end
 return nextValue
end
return Mock
