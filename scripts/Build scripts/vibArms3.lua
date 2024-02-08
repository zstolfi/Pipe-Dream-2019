--create vib arm3's
m3d = require(workspace.m3d);
lib = require(workspace.lib);
find = lib.find;

local function vibArms3()
	local model = workspace.Vibraphone.arms;
	for i,arm in pairs(model:GetChildren()) do
		if arm.Name:match("arm") then
			local center = find(arm,"block").Hinge;
			local top = find(arm,"block").top1;	-- it doesn't matter which one, they all have the same Y value
			local bottom = find(arm,"block").bottom1;
			
			local bar = find(arm,"block.bar");		-- BLOCK
			local len = (top.Position.Y - bottom.Position.Y) - 1.791;
			bar.Size = Vector3.new(.93, len, .4);
			find(arm,"block.glow").Size = bar.Size + Vector3.new(0.01, 0.01, 0.01);
			
			for i = 1, 2 do
				local isTop = i==1;
				
				local arm3 = find(arm,"block")[isTop and "arm3 top" or "arm3 bottom"];		-- ARM3
				
				local d = math.abs(center.Position.Y - top.Position.Y);
				local x = d/math.cos(math.rad(10));
				local w = math.sqrt(x^2 - d^2);	-- this was before I knew trig lol
				local p1 = center.CFrame;	-- target position 1 and 2
				local p2 = center.CFrame * CFrame.new(0,isTop and d or -d,-w);
				
				arm3.Position = (p1.Position + p2.Position) / 2;
				arm3.Size = Vector3.new(.22, .3, x);
				
				local bPos = bar.Position;		-- STRING
				local p1 = CFrame.new(
					bPos.x,
					isTop and top.Position.Y or bottom.Position.Y,
					bPos.z
				);
				local p2 = bar.CFrame * CFrame.new(0,(len/2-.2) * (isTop and 1 or -1),0);
	
				local strMod = find(arm,"block" .. (isTop and ".string top" or ".string bottom"));
				
				strMod.string.Position = (p1.Position + p2.Position) / 2;
				strMod.string.Size = Vector3.new(1.095, 0.175,0.175);
				
				strMod.Hinge.Position = m3d.edgePoint(strMod.string, 1,0,0);
			end
		end
	end
end

return vibArms3;