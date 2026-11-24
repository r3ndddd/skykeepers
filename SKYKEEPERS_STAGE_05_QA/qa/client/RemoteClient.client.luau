local Players = game:GetService('Players')
local remote = game:GetService('ReplicatedStorage'):WaitForChild('SK_Stage05_Remote_Test'):WaitForChild('Exchange')
local id = tostring(Players.LocalPlayer.UserId) .. '-initial'
remote.OnClientEvent:Connect(function(reply)
	print(('[STAGE05][CLIENT] user=%s id=%s status=%s value=%s owner=%s'):format(Players.LocalPlayer.UserId, tostring(reply.id), tostring(reply.status), tostring(reply.value), tostring(reply.userId)))
end)
remote:FireServer({id = id, kind = 'probe', value = 7})
