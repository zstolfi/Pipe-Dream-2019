function resize()
	local scale = workspace.Scale.Value;
	for i,v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Size     = scale * v.Size;
			v.Position = scale * v.Position;
		end
	end
end

return resize;