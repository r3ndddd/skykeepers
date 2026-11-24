-- Move only the character that actually fell; hysteresis and per-character cooldown prevent loops.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local island=workspace:WaitForChild('SK_Stage06_Island')
local spawn=island:WaitForChild('IslandSpawn')
local last={}
Players.PlayerRemoving:Connect(function(p) last[p]=nil end)
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt
 if elapsed<.25 then return end
 elapsed=0
 for _,p in Players:GetPlayers() do
  local char=p.Character
  local root=char and char:FindFirstChild('HumanoidRootPart')
  local hum=char and char:FindFirstChildOfClass('Humanoid')
  if root and hum and hum.Health>0 and root.Position.Y<15 and (not last[p] or os.clock()-last[p]>2) then
   last[p]=os.clock(); char:PivotTo(spawn.CFrame+Vector3.new(0,4,0)); root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
  end
 end
end)
