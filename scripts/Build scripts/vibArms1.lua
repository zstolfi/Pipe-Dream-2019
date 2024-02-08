-- distribute vib arms
local function map(value, start1, stop1, start2, stop2)
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
end

local function vibArms1()
	local model = workspace.Vibraphone.arms;
	local arm = workspace["Master Vib Arm"];
	local center = workspace.Vibraphone.PrimaryPart;
	
	local copies = 40;
	
	local function makeCopy(i)
		local p = arm:Clone();
		
		local angle = map(i, 0, copies, 0, -2*math.pi) - math.pi/4;
		p:SetPrimaryPartCFrame( center.CFrame * CFrame.Angles(angle,0,0) );
		p.PrimaryPart:Destroy();
		
		local funnelPart = p["%funnel part"];
		funnelPart.Name = i .. " %funnel part";
		funnelPart.Parent = workspace.Vibraphone.funnels;
		
		p.Name = "arm ".. i;
		p.Parent = model;
	end
	
	for i = 0, copies-1 do
		makeCopy(i);
	end
end

return vibArms1;