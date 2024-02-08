function map(value, start1, stop1, start2, stop2)
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
end

function conify(model)
	local center = model.center;
	
	--local edgeNames = {"edge1","m%brace"};
	local edgeNames = {};
	for i = 1, #model:GetChildren() do
		local e = model:GetChildren()[i];
		local name = string.match(e.Name, "^(.+) %d+$");
		if e:IsA("BasePart") and name then
			table.insert(edgeNames, name);
		elseif e:IsA("Model") and name then
			table.insert(edgeNames, "m%"..name);
		end
	end
	
	for i = 1, #edgeNames do
		local copies;
		local edge;
		local md = string.match(edgeNames[i], "^m%%.+$");	-- model name
		local m = false;	-- shorthand if it's a model or not
		for j = 1, #model:GetChildren() do
			local e = model:GetChildren()[j];
			local c = string.match(e.Name, "^"..edgeNames[i].." (%d+)$");
			local msub = string.sub(edgeNames[i],3);
			local mnum = string.match(e.Name, "^"..msub.." (%d+)$");
			if (not md) and c then	-- if it's not a model and the name is correct
				edge = e;
				copies = tonumber(c);
			elseif md and mnum then	-- if it is a model, and correctly named
				edge = e;
				copies = tonumber(mnum);
				e.PrimaryPart = e:GetChildren()[1];
				m = true;
			end
		end
		
		if not model:FindFirstChild("%clones") then
			Instance.new("Model", model).Name = "%clones";
		end
		
		for i = 2, copies do	-- skip the first one which is already there
			local p = edge:Clone();
			local angle = map(i, 1, copies+1, 0, -2*math.pi);
			local offset = center.CFrame:inverse() * (m and p:GetPrimaryPartCFrame() or p.CFrame);
			if m then
				p:SetPrimaryPartCFrame( (center.CFrame * CFrame.Angles(angle,0,0)) * offset );
				p.PrimaryPart = nil;
			else
				p.CFrame = (center.CFrame * CFrame.Angles(angle,0,0)) * offset;
			end
			p.Name = string.match(p.Name,"^(.+) %d+$") .. " clone";
			p.Parent = model["%clones"];
		end
		
	end
end

return function()
	for _,model in pairs (workspace:GetDescendants()) do
		local name = model.Name:match("^(.-)%s*%%spin$");
		
		if name and model:IsA("Model") and model:FindFirstChild("center") then
			conify(model);
			--if name:match("^Master ") then
				model.Name = name;
			--end
		end
	end
	
end