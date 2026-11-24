-- Test-only RemoteEvent. Limits apply after Roblox transports/deserializes arguments.
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local validate = require(game.ServerStorage.SK_Stage05_Test.RequestValidator)
local folder = Instance.new('Folder')
folder.Name = 'SK_Stage05_Remote_Test'
folder.Parent = ReplicatedStorage
local remote = Instance.new('RemoteEvent')
remote.Name = 'Exchange'
remote.Parent = folder
local state = {}
local pending = 0
local function metrics()
 local count = 0
 for _ in state do count += 1 end
 folder:SetAttribute('ActiveStates', count)
 folder:SetAttribute('Pending', pending)
end
metrics()
Players.PlayerRemoving:Connect(function(player) state[player] = nil; metrics() end)
remote.OnServerEvent:Connect(function(player, data)
 local now = os.clock()
 local s = state[player] or {times = {}, ids = {}, count = 0}
 state[player] = s; metrics()
 local times = s.times
 while times[1] and now - times[1] >= 1 do table.remove(times, 1) end
 local valid, reason = validate(data)
 local id = if type(data) == 'table' and type(data.id) == 'string' and #data.id <= 64 then data.id else ''
 if #times >= 5 then remote:FireClient(player, {id = id, status = 'rate_limited'}); return end
 table.insert(times, now)
 if not valid then
  warn('[STAGE05][REJECT] user=' .. tostring(player.UserId) .. ' reason=' .. reason)
  remote:FireClient(player, {id = id, status = reason}); return
 end
 if s.ids[id] then remote:FireClient(player, {id = id, status = 'duplicate'}); return end
 if s.count >= 64 then remote:FireClient(player, {id = id, status = 'quota'}); return end
 s.ids[id] = true; s.count += 1
 if data.kind == 'delay' then
  pending += 1; metrics()
  print('[STAGE05][DELAY_ACCEPTED] user=' .. tostring(player.UserId) .. ' id=' .. id)
  task.wait(2)
  pending -= 1; metrics()
  if player.Parent ~= Players or state[player] ~= s then
   print('[STAGE05][DELAY_CANCELLED] user=' .. tostring(player.UserId) .. ' id=' .. id)
   return
  end
 end
 remote:FireClient(player, {id = id, status = 'ok', value = data.value * 2, userId = player.UserId})
end)