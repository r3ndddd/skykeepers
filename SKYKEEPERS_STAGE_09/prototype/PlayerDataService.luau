-- Experimental dependency-injected service; not wired to Roblox gameplay.
-- Store, clock and wait are injected. Callers must gate gameplay on active sessions.
local Service = {}; Service.__index = Service
function Service.new(core, store, clock, wait, owner, lease)
 assert(type(owner) == "string" and #owner > 0 and lease >= 600)
 return setmetatable({core=core, store=store, clock=clock, wait=wait, owner=owner, lease=lease, sessions={}}, Service)
end
function Service:_update(key, transform)
 for attempt=1,3 do
  local ok, value = pcall(function() return self.store:UpdateAsync(key, transform) end)
  if ok then return true, value end
  if attempt < 3 then self.wait(attempt) end
 end
 return false, nil
end
function Service:load(userId)
 if type(userId) ~= "number" or userId ~= userId or userId <= 0 or userId % 1 ~= 0 or userId > 9007199254740991 then return nil, "invalid-user" end
 if self.sessions[userId] then return nil, "already-loading" end
 local session = {state="loading"}; self.sessions[userId] = session
 local key = "user_"..tostring(userId)
 local ok, result = self:_update(key, function(record) return self.core.acquire(record,self.owner,self.clock(),self.lease) end)
 if self.sessions[userId] ~= session or session.state ~= "loading" then
  -- If acquired after departure, release the unchanged snapshot, never publish it.
  if ok and result then self:_update(key,function(record) return self.core.save(record,self.owner,self.clock(),self.lease,result.Profile,true) end) end
  if self.sessions[userId] == session then self.sessions[userId] = nil end
  return nil, "cancelled"
 end
 if not ok or not result then self.sessions[userId] = nil; return nil, ok and "locked-or-invalid" or "load-failed" end
 session.state="active"; session.profile=self.core.copy(result.Profile); session.revision=0; session.savedRevision=0; session.busy=false
 return session.profile
end
function Service:changed(userId)
 local s=self.sessions[userId]; if not s or s.state~="active" then return false end
 s.revision += 1; return true
end
function Service:save(userId, release)
 local s=self.sessions[userId]
 if not s or s.busy or (s.state~="active" and s.state~="closing") then return false,"inactive-or-busy" end
 if release then s.state="closing" end
 if not self.core.valid(s.profile) then s.state="blocked"; return false,"invalid" end
 s.busy=true
 local snapshot=self.core.copy(s.profile); local revision=s.revision
 local ok,result=self:_update("user_"..tostring(userId),function(record) return self.core.save(record,self.owner,self.clock(),self.lease,snapshot,release) end)
 s.busy=false
 if not ok or not result then s.state="blocked"; return false,ok and "lock-lost" or "save-failed" end
 s.savedRevision=revision
 if release then self.sessions[userId]=nil end
 return true
end
function Service:cancelLoading(userId)
 local s=self.sessions[userId]; if s and s.state=="loading" then s.state="cancelled"; return true end
 return false
end
return Service
