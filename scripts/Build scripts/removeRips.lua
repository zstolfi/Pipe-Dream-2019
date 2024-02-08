local function removeRips()
	for _,part in pairs(workspace:GetChildren()) do
		if part:IsA("Model") and part.Name:match("^rip ") then
			part:Destroy();
		end
	end
end

return removeRips;