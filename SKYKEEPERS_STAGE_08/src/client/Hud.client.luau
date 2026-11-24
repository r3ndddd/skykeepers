local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui");gui.Name="SK07_HUD";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame");panel.Size=UDim2.fromOffset(190,112);panel.Position=UDim2.fromOffset(16,16);panel.BackgroundColor3=Color3.fromRGB(28,42,66);panel.BackgroundTransparency=.15;panel.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=panel
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-16,0,30);title.Position=UDim2.fromOffset(8,4);title.BackgroundTransparency=1;title.Text="SKYKEEPERS";title.Font=Enum.Font.GothamBold;title.TextSize=20;title.TextColor3=Color3.fromRGB(205,242,255);title.Parent=panel
local count=Instance.new("TextLabel");count.Name="InventoryCount";count.Size=UDim2.new(1,-16,0,32);count.Position=UDim2.fromOffset(8,38);count.BackgroundTransparency=1;count.Font=Enum.Font.Gotham;count.TextSize=16;count.TextColor3=Color3.new(1,1,1);count.Text="Gather a resource";count.Parent=panel
local coins=Instance.new("TextLabel");coins.Name="SkyCoins";coins.Size=UDim2.new(1,-16,0,24);coins.Position=UDim2.fromOffset(8,76);coins.BackgroundTransparency=1;coins.Font=Enum.Font.Gotham;coins.TextSize=16;coins.TextColor3=Color3.fromRGB(255,225,140);coins.Parent=panel
local function refreshCoins() coins.Text="Sky Coins: "..tostring(player:GetAttribute("SK08_SkyCoins") or 0) end
player:GetAttributeChangedSignal("SK08_SkyCoins"):Connect(refreshCoins);refreshCoins()
local notice=Instance.new("TextLabel");notice.Name="GatherNotice";notice.AnchorPoint=Vector2.new(.5,0);notice.Position=UDim2.new(.5,0,0,145);notice.Size=UDim2.fromOffset(260,38);notice.BackgroundTransparency=.25;notice.BackgroundColor3=Color3.fromRGB(28,70,81);notice.TextColor3=Color3.new(1,1,1);notice.Font=Enum.Font.GothamBold;notice.TextSize=18;notice.Visible=false;notice.Parent=gui
local serial=0
ReplicatedStorage:WaitForChild("SK_Stage07_Notice").OnClientEvent:Connect(function(id,name,amount,balance)
 if type(id)~="string" or type(name)~="string" or amount~=1 or type(balance)~="number" then return end
 count.Text=name..": "..tostring(balance)
 serial+=1;local n=serial;notice.Text="+"..amount.." "..name;notice.Visible=true
 task.delay(2,function() if serial==n then notice.Visible=false end end)
end)
