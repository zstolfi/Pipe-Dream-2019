--	autoArc v0.92.??		last updated 12/17/2021

local m3d = require(workspace.m3d);
local lib = require(workspace.lib);
	
local clones = {}; -- clones[model][sec num.]
setmetatable(clones, {
	__index = function(self, model)
		self[model] = {};
		return self[model];
	end
});

function autoArc(model, copies, size, axis)
	local partStart,partEnd;
	for _,v in pairs(model:GetDescendants()) do
		if v.Name:match("^start") then
			partStart = v;
		elseif v.Name:match("^end") then
			partEnd = v;
		end
	end
	
	if type(axis) ~= "string" or axis == "" then axis = "x"; end
	axis = axis:match("^[XYZxyz]$"):lower();
	transformAxis(partStart, axis);  -- The cheat that makes autoArc work with other axies.
	transformAxis(partEnd, axis);    -- if axis isn't 'x' then make it x, then undo it later.
	--local RightVar, UpVar, LookVar  = unpack(axisTranslateData[axis:lower()]);
	--local v3 = {
	--	["x"] = vecNames[axisTranslateData[axis][1]] ,
	--	["y"] = vecNames[axisTranslateData[axis][2]] ,
	--	["z"] = vecNames[axisTranslateData[axis][3]]
	--};
	
	local len1 = tonumber(partStart.Name:match("^start %%(%d+%.?%d*)"));
	local len2 = tonumber(partEnd.Name:match("^end %%(%d+%.?%d*)"));
	local parts = {};
	
	----------------  CALCULATE MATH  ----------------
	local _sp,_ep = partStart.Position, partEnd.Position;
	local _sd,_ed = partStart.CFrame.LookVector, partEnd.CFrame.LookVector;
	local clo1, clo2 = closestPoints(_sp, _sd, _ep, _ed);
	local p1 = partStart.Position;
	local p2 = partEnd.Position;
	local dist1 = (clo1 - p1).magnitude;	-- these are used for the bezier curves!
	local dist2 = (clo2 - p2).magnitude;	-- https://www.desmos.com/calculator/ejtmma9s77
	
	local orig1 = p1 - clo1;
	local orig2 = p2 - clo2;
	local ang = math.acos(orig1:Dot(orig2) / (dist1*dist2));
	
	local m = (4/3) * math.tan(ang/4); -- the magic number for circular arcs
	
	if ang ~= ang then -- NaN case!
		local newLen = (p1-p2).Magnitude/5;
		dist1,dist2 = newLen,newLen;
		m = 1;
	end
	
	len1 = len1 or m * dist2;
	len2 = len2 or m * dist1;
	
	local bez1 = p1 + (partStart.CFrame.RightVector * len1);
	local bez2 = p2 - (partEnd.CFrame.RightVector * len2);
	local pack = {p1, bez1, bez2, p2}; -- makes calling the function easier
	
	local centers, tangents, norms = {},{},{};
	for i = 1, copies-1 do	-- pre-calculate the centers & tangets
		local frac = (i-1)/(copies-1);	-- https://i.imgur.com/TZlzuIu.png
		centers[i] = cubicBezier(frac, pack);
		tangents[i] = cubicDerivative(frac, pack);
		norms[i] = cubicNorm(frac, pack);
	end
	
	
	local RMframes = {}	-- https://pomax.github.io/bezierinfo/#pointvectors3d
	RMframes[1] = {
		o = partStart.Position ,
		t = partStart.CFrame.RightVector ,
		n = -partStart.CFrame.UpVector ,
		b = -partStart.CFrame.LookVector
	}
	
	local function createRMframes(steps)
		local step = 1/steps;
		
		for t0 = 0, 1, step do
			local x0 = RMframes[#RMframes];	-- the lastest one
			
			local t1 = t0 + step;
			local x1 = {
				o = cubicBezier(t1, pack),
				t = cubicDerivative(t1, pack)
			};
			
			local v1 = x1.o - x0.o;
			local c1 = v1:Dot(v1);
			local biL = x0.b - v1 * 2/c1 * v1:Dot(x0.b);
			local tiL = x0.t - v1 * 2/c1 * v1:Dot(x0.t);
			
			local v2 = x1.t - tiL;
			local c2 = v2:Dot(v2);
			
			x1.b = biL - v2 * 2/c2 * v2:Dot(biL);
			x1.n = x1.b:Cross(x1.t);
			RMframes[#RMframes+1] = x1;
		end
	end
	createRMframes(copies);
	
	local endAngle = m3d.signedAngle(RMframes[#RMframes].n, partEnd.CFrame.UpVector, partEnd.CFrame.RightVector);
	
	
	----------------  PARTS FOR-LOOP  ----------------
	for i = 2, copies-1 do
		local p;
		if clones[model][i] == nil then
			p = partStart:Clone();
		else
			p = clones[model][i];
			p.Size = partStart.Size;
		end
		
		local frac = (i-1)/(copies-1);
		
		local center = centers[i];
		local tangent = tangents[i];
		local norm = norms[i];
		--p.CFrame = CFrame.fromMatrix(center, tangent, norm);
		p.CFrame = CFrame.fromMatrix(RMframes[i].o, RMframes[i].t, RMframes[i].n, RMframes[i].b);
		if endAngle ~= 0 then
			p.CFrame = p.CFrame * CFrame.Angles(lerp(0, endAngle, frac), 0, 0);
		end
		
		if copies > 3 then	-- move the ending copy parts to meet the start/end Parts
			if i == 2 then						-- http://geomalgorithms.com/a05-_intersect-1.html
				local v0 = partStart.Position;	-- the plane is startPart, the line is copy 2
				local n = partStart.CFrame.RightVector;
				local p0 = p.Position;
				local u = p.CFrame.RightVector;
				
				local sI = n:Dot(v0-p0)/n:Dot(u);
				local intersect = p0 + sI*u;
				p.Position = intersect;
				p.Position = p.CFrame * (p.Size * Vector3.new(1,0,0) * .5);
			elseif i == copies-1 then
				local v0 = partEnd.Position;
				local n = partEnd.CFrame.RightVector;
				local p0 = p.Position;
				local u = p.CFrame.RightVector;
				
				local sI = n:Dot(v0-p0)/n:Dot(u);
				local intersect = p0 + sI*u;
				p.Position = intersect;
				p.Position = p.CFrame * (p.Size * Vector3.new(-1,0,0) * .5);
			end
		end
		
		
		-- there used to be a bunch of code here
		
		
		local s1, s2 = partStart.Size, partEnd.Size;	-- determine the part's width
		
		p.Size = s1:lerp(s2, frac);
		if size ~= "" then
			if tonumber(size) then
				p.Size = Vector3.new(p.Size.x, size, size);
			elseif size:match("^%d+%.?%d*%%$") then	-- it's a percentage
				local percentage = size:match("^(%d+%.?%d*)%%$")
				p.Size = p.Size * (percentage/100);
			end
		else
			p.Size = p.Size * .8;
		end
		
		p.Locked = true;
		p.Name = string.format("%03d",i) .. " %sec";
		p.Transparency = 0;
	
		parts[i] = p;
	end
	
	
	
	for i = 2, copies-2 do
		antiRidge(parts[i], parts[i+1]);
	end

	transformUndoAxis(partStart, axis);
	transformUndoAxis(partEnd, axis);
	for i,v in pairs(parts) do
		transformUndoAxis(v, axis);
		v.Parent = model;
	end
	
	local hasParts = false;
	for _,v in pairs(model:GetChildren()) do
		if v.Name:match("^0*2 %%sec$") then hasParts = true; break; end
	end
	if hasParts then	-- the model already has parts!
		for _,v in pairs(model:GetChildren()) do
			local secNum = tonumber(v.Name:match("(%d+) %%sec"));
			if secNum then
				clones[model][secNum] = v;
			end
		end
	end
end

closestPoints = m3d.closestPoints;
antiRidge = m3d.antiRidge; -- the 2nd half of the script! Old ver: https://www.youtube.com/watch?v=iruhbDqMIkU

lerp = lib.lerp;

function transformAxis(part, axis)
	if axis == "x" then return; end
	local cf,size = part.CFrame, part.Size;
	if axis == "y" then
		part.CFrame = CFrame.fromMatrix(cf.Position, -cf.YVector, cf.ZVector, -cf.XVector);
		part.Size = Vector3.new(size.y, size.z, size.x);
	elseif axis == "z" then
		part.CFrame = CFrame.fromMatrix(cf.Position, -cf.ZVector, -cf.XVector, cf.YVector);
		part.Size = Vector3.new(size.z, size.x, size.y);
	end
end
function transformUndoAxis(part, axis)
	local t = {["x"]="x", ["y"]="z", ["z"]="y"};
	transformAxis(part, t[axis]);
end

--axisTranslateData = {
--	["x"] = {"RightVector",    "UpVector"   ,    "LookVector" } ,
--	["Y"] = {"LookVector" ,    "RightVector",    "UpVector"   } ,
--	["z"] = {"UpVector"   ,    "LookVector" ,    "RightVector"}
--};
--vecNames = {
--	["RightVector"] = Vector3.new(1, 0, 0) ,
--	["UpVector"]    = Vector3.new(0, 1, 0) ,
--	["LookVector"]  = Vector3.new(0, 0,-1)
--}

function cubicBezier(t, points)	-- shorthand version
	local p0, p1, p2, p3 = unpack(points);
	return (1-t)^3*p0 + 3*(1-t)^2*t*p1 + 3*(1-t)*t^2*p2 + t^3*p3;
end

function cubicDerivative(t, points)	-- https://stackoverflow.com/a/4091430
	local p0, p1, p2, p3 = unpack(points);
	return 3*(1-t)^2*(p1-p0) + 6*(1-t)*t*(p2-p1) + 3*t^2*(p3-p2);
end
function cubicDerivative2(t, points) -- 2nd derivative
	local p0, p1, p2, p3 = unpack(points);
	return 6*(1-t)*(p2-2*p1+p0)+6*t*(p3-2*p2+p1);
end
function cubicNorm(t, points) -- calc normals  https://pomax.github.io/bezierinfo/#pointvectors3d
	local tangent = cubicDerivative(t, points);
	local deriv2 = cubicDerivative2(t, points);

	local a = tangent.Unit;
	local b = (a + deriv2).Unit;
	local r = b:Cross(a).Unit;
	return r:Cross(a).Unit;
end

return autoArc;