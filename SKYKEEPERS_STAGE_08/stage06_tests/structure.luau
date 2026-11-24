local island=workspace:FindFirstChild('SK_Stage06_Island')
local passed,failed=0,0
local function check(name, ok) if ok then passed+=1 else failed+=1 end print((ok and 'PASS ' or 'FAIL ')..name) end
check('island exists', island ~= nil)
if island then
 local ground=island:FindFirstChild('Meadow')
 check('80x80 surface at Y=40', ground and ground.Size==Vector3.new(80,4,80) and math.abs(ground.Position.Y+ground.Size.Y/2-40)<0.001)
 local sp=island:FindFirstChild('IslandSpawn')
 check('enabled safe spawn', sp and sp:IsA('SpawnLocation') and sp.Enabled and sp.Anchored and sp.CanCollide and sp.Position.Y>=40)
 check('three tree nodes', island:FindFirstChild('Resources') and #island.Resources:GetChildren()==3)
 for _,name in {'SkyHeart','Skyglass_Decor','Starbloom_Decor','Cottage'} do check(name..' exists', island:FindFirstChild(name)~=nil) end
 local anchored=true local invisibleBlocking=false
 for _,v in island:GetDescendants() do if v:IsA('BasePart') then if not v.Anchored then anchored=false end if v.Transparency>=1 and v.CanCollide then invisibleBlocking=true end end end
 check('island parts anchored',anchored)
 check('no fully invisible colliders',not invisibleBlocking)
end
check('server service exists',game.ServerScriptService:FindFirstChild('SK_Stage06') and game.ServerScriptService.SK_Stage06:FindFirstChild('ResourceService')~=nil)
check('client HUD script exists',game.StarterPlayer.StarterPlayerScripts:FindFirstChild('SK_Stage06') and game.StarterPlayer.StarterPlayerScripts.SK_Stage06:FindFirstChild('Hud')~=nil)
return game.HttpService:JSONEncode({passed=passed,failed=failed})
