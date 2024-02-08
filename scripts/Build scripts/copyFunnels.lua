local function copyFunnels()
	
	local masterFunnel = workspace["Master Funnel"];
	local masterGrandFunnel = workspace["Master Grand Funnel"];
	
	masterFunnel.center.UsePartColor = true;
	
	for _,part in pairs (workspace:GetDescendants()) do
		local name = part.Name:match("^(.-)%s*%%funnel part$") or part.Name:match("^(.-)%s*%%grand funnel part$");
		if part:IsA("Part") and name then
			local cf = part.CFrame;
			--local col2 = part:FindFirstChild("color2");
			
			local n;
			if part.Name:match("%%funnel part$") then
				n = masterFunnel:Clone();
			else	-- grand funnel part
				n = masterGrandFunnel:Clone();
			end
			
			n:SetPrimaryPartCFrame(cf);
			--for _,v in pairs(n:GetDescendants()) do
			--	transferProps(v, part);
			--	if part.Name:match("%%grand funnel part$") and col2 then
			--		if v.Name == "corner" or v.Name == "edge" or v.Name:match("wire") or v.Name:match("brace") then
			--			transferProps(v, col2);
			--		end
			--	end
			--end
			n.Name = name;
			
			n.Parent = part.Parent;
			part:Destroy();
		end
	end
end

local props = {"Color", "Material", "Reflectance", "Transparency"};
function transferProps(to, from)
	if to:IsA("BasePart") and to.Transparency ~= 1 then
		for _,property in pairs(props) do
			to[property] = from[property];
		end
	end
end

return copyFunnels;