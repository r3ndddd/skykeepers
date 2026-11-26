local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Catalog=require(script.Parent.ResourceCatalog)
local inventory=require(script.Parent.SessionInventory)
local Economy=require(script.Parent.EconomyCore)
local merchant=workspace:WaitForChild("SK_Stage08_Merchant")
local point=merchant:WaitForChild("InteractionPoint")
local remote=Instance.new("RemoteEvent");remote.Name="SK08_Merchant";remote.Parent=ReplicatedStorage
local function live(player) return player.Parent==Players end
local function near(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return root~=nil and merchant:IsDescendantOf(workspace) and point:IsDescendantOf(merchant) and (root.Position-point.Position).Magnitude<=12
end
local core=Economy.new(inventory,Catalog,live,near)
local function snapshot(player)
 local session=inventory.sessions[player]
 if not session then return nil end
 local rows={}
 for id,item in pairs(Catalog.ById) do table.insert(rows,{id=id,name=item.name,price=item.value,count=session.counts[id]}) end
 table.sort(rows,function(a,b)return a.name<b.name end)
 return {coins=session.coins,rows=rows}
end
local function send(player,kind,info)
 if live(player) then remote:FireClient(player,kind,info,snapshot(player)) end
end
local function ready(player)
 if inventory.sessions[player] then player:SetAttribute("SK08_SkyCoins",inventory.sessions[player].coins) end
end
Players.PlayerAdded:Connect(function(player) task.defer(function() ready(player) end) end)
for _,player in Players:GetPlayers() do task.defer(function() ready(player) end) end
local prompt=Instance.new("ProximityPrompt");prompt.Name="MerchantPrompt";prompt.ActionText="Trade";prompt.ObjectText="Sky Merchant";prompt.MaxActivationDistance=10;prompt.HoldDuration=.35;prompt.RequiresLineOfSight=false;prompt.Parent=point
prompt.Triggered:Connect(function(player) if near(player) and snapshot(player) then send(player,"open","") end end)
remote.OnServerEvent:Connect(function(player,action,id,quantity,requestId,...)
 if action~="sell" or select("#",...)~=0 then return end
 local ok,result=core:sell(player,id,quantity,requestId)
 if ok then
  player:SetAttribute("SK07_"..result.id,result.remaining)
  player:SetAttribute("SK08_SkyCoins",result.balance)
  send(player,"sold",result)
 else
  send(player,"rejected",type(result)=="string" and result or "error")
 end
end)
print("[SK08] merchant ready")
