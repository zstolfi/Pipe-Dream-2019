function correctColor()
	for _,part in pairs(workspace:GetDescendants()) do
		if part:IsA("UnionOperation") then
			part.UsePartColor = true;
		end
	end
end

return correctColor;
