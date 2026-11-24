local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Inventory = require(script.Parent.InventoryService)
local Resource = require(script.Parent.ResourceCore)
local island = workspace:WaitForChild('SK_Stage06_Island')
local remote = Instance.new('RemoteEvent'); remote.Name = 'SK_Stage06_Notice'; remote.Parent = ReplicatedStorage
local inventory = Inventory.new()
local metrics = Instance.new('Folder'); metrics.Name = 'SK_Stage06_SessionMetrics'; metrics.Parent = game:GetService('ServerStorage')
local function updateMetrics()
 local count=0
 for _ in inventory.sessions do count+=1 end
 metrics:SetAttribute('ActiveSessions',count)
end
updateMetrics()
local function resourceLive(tree)
 return typeof(tree)=='Instance' and tree:IsA('Model') and tree:IsDescendantOf(island.Resources) and tree:FindFirstChild('Trunk',true) ~= nil
end
local core=Resource.new(inventory,function(p) return p.Parent==Players end,resourceLive)
local serial=0
local function initialize(p)
 if inventory:join(p) then p:SetAttribute('SK06_Cloudwood',0); updateMetrics() end
end
Players.PlayerAdded:Connect(initialize)
Players.PlayerRemoving:Connect(function(p) inventory:leave(p); updateMetrics() end)
for _,p in Players:GetPlayers() do initialize(p) end
local function install(tree)
 local trunk=tree:FindFirstChild('Trunk',true)
 if not trunk or not trunk:IsA('BasePart') then warn('[SK06] Missing trunk '..tree.Name); return end
 core:register(tree)
 tree.Destroying:Connect(function() core.resources[tree]=nil end)
 local prompt=Instance.new('ProximityPrompt'); prompt.Name='GatherCloudwood'; prompt.ActionText='Gather'; prompt.ObjectText='Cloudwood'; prompt.KeyboardKeyCode=Enum.KeyCode.E; prompt.MaxActivationDistance=10; prompt.HoldDuration=.35; prompt.RequiresLineOfSight=false; prompt.Parent=trunk
 local indicator=Instance.new('BillboardGui'); indicator.Name='Regrowth'; indicator.Size=UDim2.fromOffset(150,34); indicator.StudsOffset=Vector3.new(0,5,0); indicator.AlwaysOnTop=true; indicator.Enabled=false; indicator.Parent=trunk
 local label=Instance.new('TextLabel'); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=.25; label.BackgroundColor3=Color3.fromRGB(35,63,72); label.TextColor3=Color3.new(1,1,1); label.Font=Enum.Font.GothamBold; label.TextSize=14; label.Text='Regrowing...'; label.Parent=indicator
 local flash=Instance.new('Highlight'); flash.FillColor=Color3.fromRGB(160,240,255); flash.FillTransparency=.3; flash.OutlineTransparency=1; flash.Enabled=false; flash.Parent=tree
 tree:SetAttribute('Available',true)
 prompt.Triggered:Connect(function(p)
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  if not root then return end
  serial+=1
  local ok=core:gather(p,tree,serial,1,(root.Position-trunk.Position).Magnitude,os.clock())
  if not ok then return end
  tree:SetAttribute('Available',false); prompt.Enabled=false; indicator.Enabled=true; flash.Enabled=true
  task.delay(.35,function() if flash.Parent then flash.Enabled=false end end)
  p:SetAttribute('SK06_Cloudwood',inventory:balance(p)); remote:FireClient(p,'gathered')
  local original=trunk.Color; trunk.Color=Color3.fromRGB(130,135,141)
  task.delay(15,function()
   if not core:restore(tree) then return end
   trunk.Color=original; tree:SetAttribute('Available',true); prompt.Enabled=true; indicator.Enabled=false
  end)
 end)
end
for _,tree in island.Resources:GetChildren() do install(tree) end
print('[SK06] resource service ready')
