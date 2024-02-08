local lockEverything = function()
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true;
		end
	end
	
	for i,v in pairs(game.ReplicatedStorage:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true;
		end
	end
end

return lockEverything;