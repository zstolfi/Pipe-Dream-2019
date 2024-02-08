function map(value, start1, stop1, start2, stop2)
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
end
function lerp(a, b, c)
	return a + (b - a) * c;
end

		-- this script assumes every part in Bass 1 and Bass 12 have unique, corrisoponding names
		-- and each model has unique, corrisoponding primary parts
		
local bassNotes = {
	26, 31, 34,
	36, 39, 41, 43, 46,
	48, 50, 51, 53
};
local banjoNotes = {
	55, 57, 58, 62
};

local mod = workspace.Stringos;

local t = {};
for i = 1, #mod:GetChildren() do
	local e = mod:GetChildren()[i];
	if e.Name:match("^%%.*$") then
		table.insert(t, e);
	end
end
for i,v in pairs(t) do
	v:Destroy();
end

function stringoLerp(name, notes)
	local modFirst = mod[name.." 1"];
	local modLast = mod[name.." "..#notes];
	
	local function lerpPart(part, fracW, fracH)	-- the parts get positioned and the stretched
		local partF, partL;
		
		if part.Parent == modFirst then
			partF = modFirst[part.Name];
			partL = modLast[part.Name];
		else
			local modName = part.Parent.Name;
			partF = modFirst[modName][part.Name];
			partL = modLast[modName][part.Name];
		end
		
		
		local spF, spL = partF.Position, partL.Position;
		local szF, szL = partF.Size, partL.Size;
		
		local pos = Vector3.new(
			lerp(spF.x, spL.x, fracH) ,
			lerp(spF.y, spL.y, fracH) ,
			lerp(spF.z, spL.z, fracW)
		);
		local size = Vector3.new(
			lerp(szF.x, szL.x, fracH) ,
			lerp(szF.y, szL.y, fracH) ,
			lerp(szF.z, szL.z, fracH)
		);
		
		local p = partF:Clone();
		p.Position = pos;
		p.Size = size;
		
		p.Name = part.Name;
		local isPrimary = partF == modFirst.PrimaryPart
		
		return p, isPrimary;
	end
	
	local function lerpModel(model, fracW, fracH)	-- the models just get moved
		local partF = modFirst[model.Name];
		local partL = modLast[model.Name];
		partF.PrimaryPart = partF.PrimaryPart or partF:FindFirstChildWhichIsA("BasePart");
		partL.PrimaryPart = partL.PrimaryPart or partL:FindFirstChildWhichIsA("BasePart");
		
		local spF = partF:GetPrimaryPartCFrame().Position;
		local spL = partL:GetPrimaryPartCFrame().Position;
		
		local pos = Vector3.new(
			lerp(spF.x, spL.x, fracH) ,
			lerp(spF.y, spL.y, fracH) ,
			lerp(spF.z, spL.z, fracW)
		);
		
		local m = partF:Clone();
		local mCf = m:GetPrimaryPartCFrame();
		local mRot = mCf - mCf.Position;
		m:SetPrimaryPartCFrame(mRot + pos);
		
		m.Name = model.Name;
		return m;
	end
	
	for num = 2, #notes-1 do
		
		local model = Instance.new("Model");
--		model.Name = "%"..name.." "..num;
		model.Name = name.." "..num;
		local min = notes[1];
		local max = notes[#notes];
		
		local fracW = (num-1)/(#notes-1);
		local fracH = map(notes[num], min, max, 0, 1);
		for _,object in pairs(modFirst:getChildren()) do
			
			if object:IsA("BasePart") then
				
				local p, isPrimary = lerpPart(object, fracW, fracH);
				p.Parent = model;
				
				if isPrimary then
					model.PrimaryPart = p;
				end
				
			elseif object.Name:match("string %d") then
				
				local m = Instance.new("Model");
				m.Name = object.Name;
				
				for i,v in pairs(object:GetChildren()) do
					local p = lerpPart(v, fracW, fracH);
					p.Parent = m;
				end
				
				m.Parent = model;
				
			elseif object:IsA("Model") then
				
				local m = lerpModel(object, fracW ,fracH);
				m.Parent = model;
				
			end
			
		end
		
		model.Parent = mod;
	end
end

return function()
	stringoLerp("Bass", bassNotes);
	stringoLerp("Banjo", banjoNotes);
end