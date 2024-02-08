local folder = workspace.Animation.motionParameters;
lib = require(workspace.lib);
local lerp,find = lib.lerp, lib.find;
scale = workspace.Scale.Value;

local updaters = {};

updaters["vibePosition"] = function()
	local value = script.Parent.vibePosition.Value;
	local model = workspace.Vibraphone.arms;
	
	local a1,a2,a3 =
		lerp(0, math.rad(58), value),
		lerp(0, math.rad(-31), value),
		lerp(0, math.rad(63), value);
	
	for _,v in pairs(model:GetChildren()) do
		local arm1,arm2,block = v["arm 1"], v["arm 2"], v.block;
		
		---- arm 1
		arm1:SetPrimaryPartCFrame(arm1:GetPrimaryPartCFrame() * CFrame.Angles(a1,0,0));
		
		---- arm 2
		arm2:SetPrimaryPartCFrame(arm1.Connect.CFrame * CFrame.Angles(a2,0,0));
		
		---- block
		block:SetPrimaryPartCFrame(arm2.Connect.CFrame * CFrame.Angles(a3,0,0));
	end
end

updaters["bellPosition"] = function()
	local value = script.Parent.bellPosition.Value;
	local model = workspace.Bells;
	
	local top,bottom = 170, 89.5;
	
	local height = lerp(top, bottom, value);
	
	local modelCF = model:GetPrimaryPartCFrame();
	model:SetPrimaryPartCFrame(modelCF +
		Vector3.new(0,-1,0) * modelCF.Position +
		scale * Vector3.new(0,1,0) * height);
	
end	

updaters["drumRotation"] = function()
	local value = script.Parent.drumRotation.Value;
	local model = workspace.Drums["4-Way"].rotating;
	
	local position = Vector3.new(-28.219, 16.441, 1.687);
	model:SetPrimaryPartCFrame(CFrame.Angles(0, value, -math.pi/2) + scale * position);
	
end

local modelTemp = find(workspace.Drums["4-Way"],"rotating.Hi Hat.arm 2.Cymbals");
local hatOffset = modelTemp.Pivot.CFrame:inverse() * modelTemp.hatTop:GetPrimaryPartCFrame();
updaters["hiHatPosition"] = function()
	local value = script.Parent.hiHatPosition.Value;
	local model = workspace.Drums["4-Way"].rotating["Hi Hat"]["arm 2"].Cymbals;
	local pivot,hat = model.Pivot, model.hatTop;
	
	--script.Parent["hiHatRotMult %a"].Value = 2/(1+math.exp(-8*value)) - 1;	-- set rotMult to 0 as hiHatPos goes to 0
	--script.Parent["hiHatRotMult %a"].Value = -math.abs(value-1)^3 + 1;
	script.Parent["hiHatRotMult %a"].Value = value;
	
	
	local relative = model.relative.CFrame;
	
	local height = lerp(0, 0.3, value);
	pivot.CFrame = relative * (CFrame.Angles(math.pi,0,math.pi) + scale * Vector3.new(1.37 + height, 0, 0));
	model.p1.CFrame = pivot.CFrame;
	hat:SetPrimaryPartCFrame(pivot.CFrame * hatOffset);
end

updaters["hiHatRotMult %a"] = function()
	local value = script.Parent["hiHatRotMult %a"].Value;
	local model = workspace.Drums["4-Way"].rotating["Hi Hat"]["arm 2"].Cymbals;
	local pivot,hat = model.Pivot, model.hatTop;
	
	local hatTop,hatBottom = find(model,"hatTop"), find(model,"hatBottom");
	local topCF,bottomCF = hatTop:GetPrimaryPartCFrame(), hatBottom:GetPrimaryPartCFrame();
	local topRotCF,bottomRotCF = topCF-topCF.Position, bottomCF-bottomCF.Position
	
	local newRotCF = bottomRotCF:Lerp(topRotCF, value);
	hatTop:SetPrimaryPartCFrame(newRotCF + hatTop:GetPrimaryPartCFrame().Position);
end

function itterateLights(f, optName) -- optional name
	for _,v in pairs(script.Parent:GetChildren()) do
		local prefix, name = v.Name:match("^(light: )(.+)");
		if v:IsA("NumberValue") and prefix then
			if optName and optName ~= name then continue; end
			for _,part in pairs(v:GetChildren()) do
				for _,light in pairs(part.Value:GetChildren()) do
					f( light , v );
			end end
		end
	end
end
ambientLights = {};
for _,part in pairs(workspace.Lights:GetChildren()) do
	for _,light in pairs(part:GetChildren()) do
		table.insert(ambientLights, light);
end end
itterateLights(function(light) -- remove all lights that are taken, only leaving ambient ones
	for i,ambLight in pairs(ambientLights) do
		if ambLight.Parent == light.Parent then
			ambientLights[i] = nil;
		end
	end
end);

defaultLightVals = {} -- get default light values
itterateLights(function(light)          defaultLightVals[light] = light.Brightness;  end);
for _,light in pairs(ambientLights) do  defaultLightVals[light] = light.Brightness;  end

updaters["lights"] = function()
	itterateLights(function(light, v)
		local default = defaultLightVals[light]; -- set the new brightness based on default
		light.Brightness = default * v.Value;
	end);	
end
updaters["light: ambient"] = function()
	local value = script.Parent["light: ambient"].Value;
	for _,light in pairs(ambientLights) do
		local default = defaultLightVals[light];
		light.Brightness = default * value;
	end
end

return updaters;