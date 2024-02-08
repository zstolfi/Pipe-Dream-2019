lib = require(workspace.lib);
m3d = require(workspace.m3d);
scale = workspace.Scale.Value;
local lerp = lib.lerp;
local map = lib.map;
local kfFolder = script.Parent.keyframes;
local keyframes = require(script.Parent.keyframeTable);

local transitionFunctions = lib.transitionFunctions;
local cubicBezier = function(t, p0, p1, p2, p3)	return		(1-t)^3*p0 + 3*(1-t)^2*t*p1 + 3*(1-t)*t^2*p2 + t^3*p3;	end
local cubicBezDeriv = function(t, p0, p1, p2 ,p3) return	3*(1-t)^2*(p1-p0) + 6*(1-t)*t*(p2-p1) + 3*t^2*(p3-p2);	end
local tfFromSlopes = lib.tfFromSlopes;

local bezFromIndex;
local function setup()
	keyframes.update();
	bezFromIndex = {};
	
	for i = 1, #keyframes-1 do
		local from, to = keyframes[i], keyframes[i+1];
		local axis = from.splineAxis or "x";
		if axis == "" then axis = "x"; end
		local RightVar, UpVar, LookVar = unpack(axisTranslateData[axis]);

		-- autoArc stuff, for the CFrame's position
		local p1,p2 = from.CFrame.Position, to.CFrame.Position;

		--	https://i.imgur.com/zVhGgqg.png	if the arc is "revesed", set to -1
		local revMult = math.sign(from.CFrame[RightVar]:Dot(p2 - p1));

		local clo1, clo2 = m3d.closestPoints(p1, from.CFrame[LookVar], p2, to.CFrame[LookVar]);
		local dist1,dist2 = (clo1 - p1).magnitude, (clo2 - p2).magnitude;
		local orig1,orig2 = p1 - clo1, p2 - clo2;

		local ang = math.acos(orig1:Dot(orig2) / (dist1*dist2)); -- assume dist1 nor dist 2 is zero!
		local m = (4/3) * math.tan(ang/4); -- the magic number for circular arcs

		local bez1 = p1 + revMult*(from.CFrame[RightVar]	* m * dist2);
		local bez2 = p2 - revMult*(to.CFrame[RightVar]	* m * dist1);
		-- end of autoArc

		bezFromIndex[i] = {p1, bez1, bez2, p2};
	end
end

local function cameraFunction(T)
	local cf,fov;
	
	if #keyframes == 0 then	return CFrame.new(), 50; end

	local first,last = keyframes[1], keyframes[#keyframes];
	if T <= first.time then
		cf,fov = first.CFrame * rollCF(first.roll),    first.fov;
	elseif T >= last.time then
		cf,fov = last.CFrame  * rollCF(last.roll),     last.fov;

	else
			-- set variables
		local from, to, iPrev, i, iNext;
		for j = 1, #keyframes-1 do
			if keyframes[j+1].time > T then
				from,to = keyframes[j], keyframes[j+1];
				iPrev = (j-1 >= 1)				and j-1;
				i = j;
				iNext = (j+1 <= #keyframes-1)	and j+1;
				break;
			end
		end
		local tf = (from.transition ~= "") and transitionFunctions[from.transition] or transitionFunctions["linear"];
		
		local alpha = tf(map(T, from.time, to.time, 0,1));
		
		-- main spline code
		local pos = if from.spline then
			cubicBezier(alpha, unpack(bezFromIndex[i]))
			else from.CFrame.Position:Lerp(to.CFrame.Position, alpha);
		local fromAng = (from.CFrame - from.CFrame.Position);
		local toAng   = (to.CFrame   - to.CFrame.Position);
		
		cf = lerpAngle(fromAng, toAng, alpha, from.rollLock)* rollCF(lerp(from.roll or 0,to.roll or 0, alpha)) + pos;
		fov = lerp(from.fov, to.fov, alpha);
	end
	
	return cf-cf.Position + scale * cf.Position, fov;
end

function lerpAngle(a, b, alpha, rollLocked)
	rollLocked = if rollLocked ~= nil then rollLocked else true;
	local ang1 = a:Lerp(b, alpha);
	if not rollLocked then
		return ang1;
	end
	local up = Vector3.new(0,1,0);
	local newX = (up:Cross(ang1.ZVector)).Unit;
	local newY = ang1.ZVector:Cross(newX);
	return CFrame.fromMatrix(Vector3.new(), newX, newY, ang1.ZVector);
end

function rollCF(rollAng) -- given in degrees
	return CFrame.Angles(0,0,-math.rad(rollAng or 0));
end

axisTranslateData = {
	["x"] = {"RightVector",    "UpVector"   ,    "LookVector" } ,	-- Right face
	["y"] = {"UpVector"   ,    "LookVector" ,    "RightVector"}	,	-- Up dir. (not really used)
	["z"] = {"LookVector" ,    "RightVector",    "UpVector"   }  	-- Front face
};

local camera = workspace.gameCamera;
local function cameraUpdater(T)
	if (workspace.switches.ToggleCamera.Value == false) then return; end
	local cf,fov = cameraFunction(T)
	
	camera.CameraType = Enum.CameraType.Custom;
	camera.CFrame = cf;
	camera.Focus = cf + cf.LookVector;
	camera.FieldOfView = fov;
end

setup();
script.setup.Event:Connect(setup);
return cameraUpdater;