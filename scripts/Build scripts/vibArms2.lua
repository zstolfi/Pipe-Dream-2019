-- distribute vib holders
lib = require(workspace.lib);
find = lib.find;

local function map(value, start1, stop1, start2, stop2)	-- by vib holders I mean the things the arm3's connect to
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
end
local function lerp(a, b, c)
	return a + (b - a) * c;
end

local function vibArms2()
	local model = workspace.Vibraphone.arms;
	
	local smallest = 2.805;
	local largest = 6.403;
	
	local center = workspace.Vibraphone.PrimaryPart;
	
	local copies = 40;
	
	local midiPitches = {
		36, 38, 39, 40, 41, 43, 44, 45, 46, 47,
		48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
		60, 61, 62, 63, 64, 65, 66, 67, 69, 70, 71,
		72, 73, 74, 75, 76, 77, 79
	};
	
	for i = 0, copies-1 do	-- dont skip the first and last ones, because we want to put the clones in the arm model
		local arm = model["arm " .. i];
		local midY = find(arm,"block").Hinge.Position.Y;
		
		local curPitch = midiPitches[i+1];
		
		local dist = map(curPitch, midiPitches[1], midiPitches[#midiPitches], largest, smallest);
		
		for i,v in pairs(find(arm,"block"):GetChildren()) do
			if v:IsA("BasePart") then
				local pos = v.Position
				if v.Name:match("top") then
					v.Position = Vector3.new(pos.x, midY + dist, pos.z);
				elseif v.Name:match("bottom") then
					v.Position = Vector3.new(pos.x, midY - dist, pos.z);
				end
			end
		end
		
	end
end

return vibArms2;