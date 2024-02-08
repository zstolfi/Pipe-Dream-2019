local toolbar = plugin:CreateToolbar("Camera");
local newScriptButton = toolbar:CreateButton("Studio Camera Editor", "Edit camera keyframes in studio.", "rbxassetid://8427487647");
toolbar.Name = "ZCHR_CameraPlugins"; toolbar.Parent = game;

--------------------------
-- Studio Camera Editor --
--------------------------

local RunService = game:GetService("RunService");
if not RunService:IsRunMode() then return; end
local guiMod = require(script:WaitForChild("GUI Function"));
local container = script:WaitForChild("CameraEditor");

local switches = workspace:FindFirstChild("switches") or game.ServerStorage;
local toggle = switches:FindFirstChild("RunCameraEditor") or Instance.new("BoolValue");
toggle.Name = "RunCameraEditor"; toggle.Parent = switches;
local advanced = toggle:FindFirstChild("Advanced") or Instance.new("BoolValue");
advanced.Name = "Advanced"; advanced.Parent = toggle;


local camera = workspace.CurrentCamera;
local Enabled;

local function update()
	if Enabled then
		guiMod.updateCamera(camera);
	end
end

local function onToggle(bool) -- basically a setup func
	Enabled = bool;
	container.Enabled = bool;
	if bool then
		if not advanced.Value then
			local vals = container.Frame.left.values;
			vals.roll.Visible = false;
			vals.CFrameAngle.Size += UDim2.fromOffset(0, 35); 
		end
		
		guiMod.setup();
		guiMod.updateKeyframes();
		guiMod.updateTime(1);
		guiMod.updateProps();	-- props = properties
		guiMod.setEditable(false);

		update();
	end
end

container.Parent = game:GetService("CoreGui");
camera.Changed:Connect(update);
toggle.Changed:Connect(function() onToggle(toggle.Value) end);
while toggle.Value == true and workspace.Animation.SongEnd.Value == 0 do
	wait();
end
onToggle(toggle.Value);