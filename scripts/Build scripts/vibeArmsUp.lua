lib = require(workspace.lib);
find = lib.find;

local function vibeArmsUp()
	local model = workspace.Vibraphone.arms;
	
	for i,v in pairs(model:GetChildren()) do
		local a1,a2,a3 = math.rad(58), math.rad(-31), math.rad(63);
		local arm1,arm2,block = find(v,"arm 1"), find(v,"arm 2"), find(v,"block");
		
		---- arm 1
		arm1:SetPrimaryPartCFrame(arm1:GetPrimaryPartCFrame() * CFrame.Angles(a1,0,0));
		
		---- arm 2
		arm2:SetPrimaryPartCFrame(arm1.Connect.CFrame * CFrame.Angles(a2,0,0));
		
		---- block
		block:SetPrimaryPartCFrame(arm2.Connect.CFrame * CFrame.Angles(a3,0,0));
	end
end

return vibeArmsUp;