local L = game.Lighting;
local skybox = script["pipes dark"];
local Q = workspace.switches.BuildQuality.Value;
function f()
	workspace.Baseplate.Transparency = 1;
	
	-- stage lights
	for i,v in pairs(workspace.Lights:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = 1;
		end
		if Q < 40 and (v.Name:match("^wall") or v.Name:match("^room")) then
			for _,light in pairs(v:GetChildren()) do
				light.Enabled = false;
			end
		end
	end
	
	-- game.Lighting
	for i,v in pairs(L:GetChildren()) do
		if v:IsA("Sky") then
			v.Parent = game.ReplicatedStorage;
		end
		if Q < 50 and v:IsA("PostEffect") then
			v.Enabled = false;
		end
	end
	
	local c = skybox:Clone();
	c.Parent = L;

	L.Ambient =        Color3.fromRGB(37 , 38 , 42 );
	L.OutdoorAmbient = Color3.fromRGB(0  , 0  , 0  );
	L.Brightness = 0.4;

	L.ColorShift_Bottom = Color3.fromRGB(0  ,140,161);
	L.ColorShift_Top    = Color3.fromRGB(143,103,188);

	L.EnvironmentDiffuseScale = 1;
	L.EnvironmentSpecularScale = 0.8;
	L.GlobalShadows = true;
	L.ShadowSoftness = 0.5; -- seems to do nothing
	
	-- L.Technology = Future :D
	
	
	L.ClockTime = 11;
	L.GeographicLatitude = 22.5;
	
	
	L.ExposureCompensation = 0;
	
end

return f;