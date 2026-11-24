local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = Players.LocalPlayer
local gui = Instance.new('ScreenGui'); gui.Name = 'SK06_HUD'; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild('PlayerGui')
local panel = Instance.new('Frame'); panel.Size = UDim2.fromOffset(220,74); panel.Position = UDim2.new(0,16,0,16); panel.BackgroundColor3 = Color3.fromRGB(28,42,66); panel.BackgroundTransparency = 0.15; panel.Parent = gui
local corner=Instance.new('UICorner'); corner.CornerRadius=UDim.new(0,12); corner.Parent=panel
local title=Instance.new('TextLabel'); title.Size=UDim2.new(1,-16,0,30); title.Position=UDim2.fromOffset(8,4); title.BackgroundTransparency=1; title.Text='SKYKEEPERS'; title.Font=Enum.Font.GothamBold; title.TextSize=20; title.TextColor3=Color3.fromRGB(205,242,255); title.Parent=panel
local count=Instance.new('TextLabel'); count.Size=UDim2.new(1,-16,0,28); count.Position=UDim2.fromOffset(8,36); count.BackgroundTransparency=1; count.Font=Enum.Font.Gotham; count.TextSize=16; count.TextColor3=Color3.new(1,1,1); count.Parent=panel
local function update() count.Text='Cloudwood: '..tostring(player:GetAttribute('SK06_Cloudwood') or 0) end
player:GetAttributeChangedSignal('SK06_Cloudwood'):Connect(update); update()
local notice=Instance.new('TextLabel'); notice.AnchorPoint=Vector2.new(.5,0); notice.Position=UDim2.new(.5,0,0,100); notice.Size=UDim2.fromOffset(220,38); notice.BackgroundTransparency=.25; notice.BackgroundColor3=Color3.fromRGB(28,70,81); notice.TextColor3=Color3.new(1,1,1); notice.Font=Enum.Font.GothamBold; notice.TextSize=18; notice.Text='+1 Cloudwood'; notice.Visible=false; notice.Parent=gui
local serial=0
ReplicatedStorage:WaitForChild('SK_Stage06_Notice').OnClientEvent:Connect(function(kind) if kind ~= 'gathered' then return end serial+=1 local n=serial notice.Visible=true task.delay(2,function() if serial==n then notice.Visible=false end end) end)
