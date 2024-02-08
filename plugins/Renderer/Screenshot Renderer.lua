local toolbar = game:WaitForChild("ZCHR_CameraPlugins");
local newScriptButton = toolbar:CreateButton("Renderer", "Render screenshots to default folder.", "rbxassetid://8427487971");

-------------------------
-- Screenshot Renderer --
-------------------------

local InputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
if not RunService:IsRunMode() then return; end
if not workspace.switches.ScreenshotAHK.Value then return; end


while not workspace["Build scripts"].done do  wait();  end
local frameCountObj = workspace.Animation.FrameCount;

function stepFrame() -- steps forward 1 frame
	frameCountObj.Value += 1;
end


frameCountObj.Value = -1;
InputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local key = input.KeyCode;
		if key == Enum.KeyCode.KeypadPlus then
			stepFrame();
		end
	end
end);