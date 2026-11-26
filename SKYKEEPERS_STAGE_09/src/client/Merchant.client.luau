local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")
local remote=game:GetService("ReplicatedStorage"):WaitForChild("SK08_Merchant")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui");gui.Name="SK08_MerchantUI";gui.ResetOnSpawn=false;gui.DisplayOrder=10;gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame");frame.Name="MerchantPanel";frame.AnchorPoint=Vector2.new(.5,.5);frame.Position=UDim2.fromScale(.5,.5);frame.Size=UDim2.new(1,-24,.8,0);frame.BackgroundColor3=Color3.fromRGB(28,42,66);frame.Visible=false;frame.Parent=gui
local limits=Instance.new("UISizeConstraint");limits.MaxSize=Vector2.new(440,600);limits.Parent=frame
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=frame
local function text(parent,name,pos,size,textSize)
 local x=Instance.new("TextLabel");x.Name=name;x.Position=pos;x.Size=size;x.BackgroundTransparency=1;x.Font=Enum.Font.Gotham;x.TextSize=textSize;x.TextColor3=Color3.new(1,1,1);x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=parent;return x
end
local title=text(frame,"Title",UDim2.fromOffset(14,8),UDim2.new(1,-72,0,32),20);title.Text="Sky Merchant"
local close=Instance.new("TextButton");close.Name="Close";close.Position=UDim2.new(1,-48,0,8);close.Size=UDim2.fromOffset(40,40);close.Text="×";close.TextSize=24;close.Font=Enum.Font.Gotham;close.Parent=frame
close.Activated:Connect(function()frame.Visible=false end)
local coins=text(frame,"Coins",UDim2.fromOffset(14,45),UDim2.new(1,-28,0,26),16);coins.Text="Sky Coins: 0"
local message=text(frame,"Message",UDim2.fromOffset(14,72),UDim2.new(1,-28,0,30),14);message.Text="Select a resource to sell."
local list=Instance.new("ScrollingFrame");list.Name="Resources";list.Position=UDim2.fromOffset(10,106);list.Size=UDim2.new(1,-20,1,-118);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=6;list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.Parent=frame
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,6);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
local rows={}
local function mkButton(parent,label,x)
 local b=Instance.new("TextButton");b.Name=label=="1" and "SellOne" or "SellAll";b.AnchorPoint=Vector2.new(1,0);b.Position=UDim2.new(1,x,0,2);b.Size=UDim2.fromOffset(54,46);b.Text=label;b.TextSize=16;b.Font=Enum.Font.GothamBold;b.BackgroundColor3=Color3.fromRGB(54,100,114);b.TextColor3=Color3.new(1,1,1);b.Parent=parent;return b
end
local function render(data)
 if type(data)~="table" or type(data.rows)~="table" then return end
 coins.Text="Sky Coins: "..tostring(data.coins)
 for index,item in ipairs(data.rows) do
  local row=rows[item.id]
  if not row then
   local container=Instance.new("Frame");container.Name=item.id;container.Size=UDim2.new(1,-4,0,50);container.BackgroundColor3=Color3.fromRGB(42,61,82);container.Parent=list
   local label=text(container,"Label",UDim2.fromOffset(8,2),UDim2.new(1,-130,1,-4),14);label.TextWrapped=true
   local one=mkButton(container,"1",-64);local all=mkButton(container,"All",-4)
   local id=item.id
   local function sell(amount) remote:FireServer("sell",id,amount,HttpService:GenerateGUID(false)) end
   one.Activated:Connect(function() sell(1) end);all.Activated:Connect(function() sell("all") end)
   row={container=container,label=label,name=item.name,price=item.price};rows[id]=row
   player:GetAttributeChangedSignal("SK07_"..id):Connect(function()
    local count=player:GetAttribute("SK07_"..id)
    if type(count)=="number" then row.label.Text=row.name.."  ×"..tostring(count).."\n"..tostring(row.price).." SC each" end
   end)
  end
  row.name=item.name;row.price=item.price;row.container.LayoutOrder=index
  row.label.Text=item.name.."  ×"..tostring(item.count).."\n"..tostring(item.price).." SC each"
 end
end
remote.OnClientEvent:Connect(function(kind,info,data)
 if kind=="open" then frame.Visible=true;message.Text="Select a resource to sell."
 elseif kind=="sold" and type(info)=="table" then message.Text="Sold "..tostring(info.quantity).." for "..tostring(info.earned).." SC."
 elseif kind=="rejected" then message.Text="Sale declined: "..tostring(info) end
 render(data)
end)
