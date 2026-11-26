local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Catalog=require(script.Parent.ResourceCatalog)
local Drop=require(script.Parent.DropService)
local Inventory=require(script.Parent.InventoryService)
local Core=require(script.Parent.ResourceCore)
local island=workspace:WaitForChild("SK_Stage06_Island")
local zone="WhisperingMeadows"
assert(Drop.validate(Catalog.Zones[zone].drops,Catalog.ById,zone),"invalid zone drops")
local notice=Instance.new("RemoteEvent");notice.Name="SK_Stage07_Notice";notice.Parent=ReplicatedStorage
local inventory=require(script.Parent.SessionInventory)
local metrics=Instance.new("Folder");metrics.Name="SK_Stage07_Metrics";metrics.Parent=game:GetService("ServerStorage")
local function updateMetrics() local n=0 for _ in pairs(inventory.sessions) do n+=1 end metrics:SetAttribute("ActiveSessions",n) end
local function initialize(player)
 local ok=inventory.data:load(player)
 if not ok then if player.Parent==Players then player:Kick("Не удалось загрузить профиль. Попробуйте снова.") end;return end
 if player.Parent~=Players then inventory.data:close(player);return end
 if not inventory:join(player) then inventory.data:close(player);return end
 local profile=inventory:snapshot(player)
 for id in pairs(Catalog.ById) do player:SetAttribute("SK07_"..id,profile.Inventory[id]) end
 player:SetAttribute("SK08_SkyCoins",profile.SkyCoins)
 updateMetrics()
end
Players.PlayerAdded:Connect(function(player) task.spawn(initialize,player) end)
Players.PlayerRemoving:Connect(function(player) inventory:leave(player);updateMetrics();inventory.data:close(player) end)
for _,player in Players:GetPlayers() do task.spawn(initialize,player) end
task.spawn(function()
 while true do
  task.wait(180)
  for player in pairs(inventory.sessions) do task.spawn(function()
   if not inventory.data:save(player,false) and player.Parent==Players then player:Kick("Не удалось сохранить профиль. Попробуйте снова.") end
  end) end
 end
end)
game:BindToClose(function()
 local pending=0
 for player in pairs(inventory.sessions) do
  inventory:leave(player);pending+=1
  task.spawn(function() inventory.data:close(player);pending-=1 end)
 end
 local deadline=os.clock()+25
 while pending>0 and os.clock()<deadline do task.wait(.1) end
end)
local nodes={}
for _,node in island:WaitForChild("Resources"):GetChildren() do if node:IsA("Model") then nodes[node]=true end end
for _,name in {"Skyglass_Decor","Starbloom_Decor"} do local node=island:FindFirstChild(name);if node and node:IsA("Model") then nodes[node]=true end end
local function nodeLive(node)
 return typeof(node)=="Instance" and nodes[node]==true and node:IsDescendantOf(island) and node:FindFirstChildWhichIsA("BasePart",true)~=nil
end
local rng=Random.new()
local core=Core.new(inventory,Catalog,Drop,function() return rng:NextNumber() end,function(p) return p.Parent==Players end,nodeLive)
local serial=0
local function install(node)
 local part=node:FindFirstChild("Trunk",true) or node:FindFirstChildWhichIsA("BasePart",true)
 if not part or not part:IsA("BasePart") or not core:register(node,zone) then warn("[SK07] Cannot install node "..node.Name);return end
 node.Destroying:Connect(function() nodes[node]=nil;core.resources[node]=nil end)
 local prompt=Instance.new("ProximityPrompt");prompt.Name="GatherResource";prompt.ActionText="Gather";prompt.ObjectText="Whispering Meadows";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.MaxActivationDistance=10;prompt.HoldDuration=.35;prompt.RequiresLineOfSight=false;prompt.Parent=part
 local indicator=Instance.new("BillboardGui");indicator.Name="Regrowth";indicator.Size=UDim2.fromOffset(150,34);indicator.StudsOffset=Vector3.new(0,5,0);indicator.AlwaysOnTop=true;indicator.Enabled=false;indicator.Parent=part
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=.25;label.BackgroundColor3=Color3.fromRGB(35,63,72);label.TextColor3=Color3.new(1,1,1);label.Font=Enum.Font.GothamBold;label.TextSize=14;label.Text="Regrowing...";label.Parent=indicator
 local flash=Instance.new("Highlight");flash.FillColor=Color3.fromRGB(160,240,255);flash.FillTransparency=.3;flash.OutlineTransparency=1;flash.Enabled=false;flash.Parent=node
 node:SetAttribute("Available",true)
 prompt.Triggered:Connect(function(player)
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not root then return end
  serial+=1
  local ok,selected=core:gather(player,node,serial,(root.Position-part.Position).Magnitude,os.clock())
  if not ok then return end
  node:SetAttribute("Available",false);prompt.Enabled=false;indicator.Enabled=true;flash.Enabled=true
  task.delay(.35,function() if flash.Parent then flash.Enabled=false end end)
  local balance=inventory:balance(player,selected.id)
  player:SetAttribute("SK07_"..selected.id,balance)
  notice:FireClient(player,selected.id,selected.name,1,balance)
  task.delay(15,function()
   if not core:restore(node) then return end
   node:SetAttribute("Available",true);prompt.Enabled=true;indicator.Enabled=false
  end)
 end)
end
for node in pairs(nodes) do install(node) end
print("[SK07] resource service ready")
