lib = require(workspace.lib);
local find = lib.find;

local function cloneBells()
	local model = workspace.Bells.arms;
	local armOrigin =	Vector3.new(1,0,1) * model.Parent.PrimaryPart.Position +
						Vector3.new(0,1,0) *model["arm 10 part"].Position;
	local radius = 16.3/2;
	
	local function bellLength(bellPart, length) -- already placed bell, and height in studs
		local negate = bellPart.Parent.bellNegate;
		local bellTop = bellPart.CFrame * (bellPart.Size * Vector3.new(-1,0,0) * .5);
		
		bellPart.Position = bellTop + Vector3.new(0,-1,0) * length/2;
		negate.Position = bellPart.Position;
						
		bellPart.Size =	Vector3.new(0,1,1) * bellPart.Size +
						Vector3.new(1,0,0) * length;
		negate.Size =	Vector3.new(0,1,1) * 1.05 +
						Vector3.new(1,0,0) * (length+1);
	end
	
	
	local armAng = {};
	armAng[1] = model["arm 1"]:GetPrimaryPartCFrame();
	armAng[10] = model["arm 10 part"].CFrame;
	
	for i = 2, 9 do
		local a1,a10 = armAng[1], armAng[10];
		armAng[i] = a1:lerp(a10, (i-1)/9);
	end
	
	for i = 1, 10 do
		armAng[i] = armAng[i] - armAng[i].Position;
	end
	
	
	local noteLength = {};
	noteLength[1] = 9.47
	noteLength[10] = 21.6
	
	for i = 2, 9 do
		local ln1,ln10 = noteLength[1], noteLength[10];
		noteLength[i] = lib.lerp(ln1, ln10, (i-1)/9);
	end
	
	
	model["arm 10 part"]:Destroy();
	
	for i = 2, 10 do
		local c = model["arm 1"]:Clone();
		local bellNote = find(c,"bell.Bell");
		
		c:SetPrimaryPartCFrame((armAng[i] + armOrigin) * CFrame.new(radius,0,0));
		
		bellLength(bellNote, noteLength[i])
		
		c.Name = "arm " .. i;
		c.Parent = model;
	end
	
	for i = 1, 10 do
		local c = model["arm "..i]
		local bellNote = find(c,"bell.Bell");
		
		local negate = bellNote.Parent.bellNegate;
		negate.Parent = workspace;
		local success, bellUnion = pcall(function()
			return bellNote:SubtractAsync({negate});
		end);
		
		if success and bellUnion then
			bellUnion.Name = "bellUnion";
			bellUnion.Parent = bellNote.Parent;
			bellNote:Destroy();
			negate:Destroy();
		end
	end
	
end

return function()
	pcall(cloneBells);
end
