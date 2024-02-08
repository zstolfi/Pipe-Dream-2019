-- all time is in milliseconds
switches = workspace.switches;
if not switches.Animated.Value and not switches.RunCameraEditor.Value then  return;  end
local songObj = switches.AnimatedMidi.Value;
--local songObj = "Pipe_Dream (MIDI) v6.mid";
--local songObj = "Instrument Test.mid";
--local songObj = "userSong iMac -- RickAstleyPipeDream.mid";

local S = {
	AnimatedRealTime = switches.AnimatedRealTime.Value;
	songPosition =     switches.AnimatedRealTime.StartTime.Value ,
	songSpeed =        switches.AnimatedRealTime.Speed.Value ,
	fps =              switches.AnimatedFPS.Value ,
}
local frameNum = 1 + S.songPosition*S.fps;
local gameStartTime;

local pluginRunning = switches.RunCameraEditor.Value or switches.ScreenshotAHK.Value;
local showTimecode = switches.Timecode.Value;
local timecodeGui;

local camera = workspace.gameCamera;
local cameraUpdater;

local lib = require(workspace.lib);
local find = lib.find;
local drawArcs = require(workspace["Build scripts"].makeArcs);
local updateKeyframes, motionParamUpdaters;

local animationsFolder;
local animTable;
local midiLib;
local eventProtos;
local songEnd;

function Setup()
	while not workspace["Build scripts"].done.Value do
		wait();
	end
	
	gameStartTime = tick() - S.songPosition/S.songSpeed;
	
	timecodeGui = game.StarterGui.Timecode.label;
	timecodeGui.Parent.Enabled = showTimecode;
	
	camera.CameraType = Enum.CameraType.Custom;
	
	midiLib = require(workspace["MIDI Table"].midiLib);
	local songData = songObj:FindFirstChild("songData") or songObj:FindFirstChildOfClass("ModuleScript");
	songData = songData and require(songData);
	require(script.Parent.importMidi)(songObj, songData); -- imports data to animTable & keyframes table
	
	animationsFolder = script.Parent.animations;
	animTable = require(script.Parent.animationTable);
	
		-- copy the keyframes over BEFORE requiring cameraUpdater
	local kfFolder,copyFrom = workspace.Camera.keyframes , switches.KeyframeTrack.Value;
	kfFolder:ClearAllChildren();
	for _,orig in pairs(copyFrom:GetChildren()) do
		local c = orig:Clone();
		c.Parent = kfFolder;
	end
	cameraUpdater = require(workspace.Camera.cameraUpdater);
	updateKeyframes = require(script.Parent.motionParameters.keyframeUpdater);
	motionParamUpdaters = require(script.Parent.motionParameters.modelUpdaters);
	
	eventProtos = {};
	for i,v in pairs (animationsFolder:GetChildren()) do
		local id = v.Name;
		eventProtos[id] = require(v);
	end
	
	songEnd = 0;
	for i,v in pairs(animTable) do
		local aTime,id,model,pitch = unpack(v);
		v[5] = eventProtos[id]:New(model, pitch, aTime, songData);	-- put the animation object in the table
		
		local evEnd = aTime + v[5].domain[2];			-- also update the end of the song (millis)
		if evEnd > songEnd then
			songEnd = evEnd;
		end
	end
	
	workspace.Animation.SongEnd.Value = songEnd;
	
	script.redraw.Event:Connect(function() onStep(true) end)
end

function Draw(T)
	
	-- reset moving parts to their defaults! 
	local objVals = script.Parent.modelLocations:GetChildren();
	local cloneVals = script.Parent.defaults;
	local partProperties = {"Name", "Size", "Transparency"};
	
	for _,v in pairs(objVals) do
		local object = v.Value;	-- can be a part or model
		local parentModelName = v.Name:match("(.-)%.");
		local parentModel = workspace[parentModelName];
		
		local location = object.Parent;
		local clone = cloneVals[v.Name].Value;
		
		if object:IsA("BasePart") then
			for _,property in pairs(partProperties) do
				object[property] = clone[property];
			end
			object.CFrame = parentModel:GetPrimaryPartCFrame() * clone.CFrame;
		elseif object:IsA("Model") then
			object:SetPrimaryPartCFrame(parentModel:GetPrimaryPartCFrame() * clone:GetPrimaryPartCFrame());
			--for _,part in pairs(object:GetChildren()) do -- I suspect the problem is this search only goes 1 layer deep
			for _,part in pairs(object:GetDescendants()) do
				if not part:IsA("BasePart") then continue; end
				local name = lib.relativeNameDesc(object, part);
				local offset = clone:GetPrimaryPartCFrame():inverse() * find(clone,name).CFrame;
				part.CFrame = object:GetPrimaryPartCFrame() * offset;
			end
		end
	end
	
	-- set then apply the non-%a motion parameters
	updateKeyframes(T);
	
	for name,func in pairs(motionParamUpdaters) do
		if not name:match("%%a$") then
			func();
		end
	end
	
	-- update positions / load-unload
	for i,v in pairs(animTable) do
		local aTime,id,model,pitch,event = unpack(v);
		
		local skip = midiLib.skipFromId(id);
		
		if not skip then
		
			local start,ending = aTime+event.domain[1], aTime+event.domain[2];
			
			if start <= T  and  T <= ending then
				if not event.initialized then
					event:init();
				end
				if not event.visible then
					event:load();
				end
				
				event:resetMovingUniqueParts() -- if any of the unique parts move, reset them here (e.g. marimba)
				
				event:apply(T-aTime);
			else
				if event.visible then
					event:unload();
					--event = nil;	-- delete the event after it's done being used
				end
			end
			
		end
	end
	
	-- apply the motion parameters with the %a flag
	for name,func in pairs(motionParamUpdaters) do
		if name:match("%%a$") then
			func();
		end
	end
	
	-- and redraw arcs (strings and such)
	local curvesQueue = workspace.Animation.curvesToDraw;
	for i,v in pairs(curvesQueue:GetChildren()) do
		drawArcs(v.Value);
	end
end



Setup();


function onStep(newFrame)
	local newFrame = newFrame or false;
	if pluginRunning and not newFrame then
			-- Let the plun in handle the frames
		if script.Parent.FrameCount.Value == frameNum then return; end
		frameNum = script.Parent.FrameCount.Value;
	elseif not pluginRunning then
			-- Animate normally if no plugin
		frameNum = if S.AnimatedRealTime
			then math.floor((tick() - gameStartTime)*S.fps * S.songSpeed) + 1
			else frameNum + 1;
	end
	
	local millis = lib.frameToMillis(frameNum);
	
	Draw(millis);
	cameraUpdater(millis);
	
	script.Parent.FrameCount.Value = frameNum;
	if showTimecode then
		timecodeGui.Text = lib.frameToTimecode(frameNum);
	end
--	Draw(((millis/4)%1909)-817);
end

local RunService = game:GetService("RunService");
RunService.Heartbeat:Connect(function() onStep() end);