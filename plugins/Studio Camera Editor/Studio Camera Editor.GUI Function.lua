gui = require(script.Parent.guiProtos);
lib = require(workspace.lib);

local frame = script.Parent.CameraEditor.Frame;

-- DECLARE VARIABLES --
local windowObj = frame.right.window;		-- right side
local timeLineObj = windowObj.timeTop;
local pointerObj = timeLineObj.pointer;
local setObj = frame.right.keySet;
local addObj = frame.right.keyAdd;
local subObj = frame.right.keySub;
local playPauseObj = frame.right.playPause;
local frameCountObj = frame.right.frameNum;
local timeCodeObj = frame.right.frameTimeCode;
local btmSliderObj = frame.right.sliderBottom;

local vals = frame.left.values; local roll = vals.roll;
local keyframeName = frame.left.name;		-- left side
local timeEditObj,timeShowObj = vals.timeEdit, vals.timeShow;
local fovEditObj,fovShowObj = vals.fovEdit, vals.fovShow;
local splideEditObj,splineShowObj = vals.splineEdit, vals.splineShow;
local transEditObj,transShowObj = vals.transitionEdit, vals.transitionShow;
local CFramePosObj = vals.CFrame;
local CFrameAngObj = vals.CFrameAngle;
local rollEditObj, rollShowObj, rollSliderObj = roll.rollEdit, roll.rollShow, roll.slider;
local rollLockedObj, rollUnlockObj = roll.iconLocked, roll.iconUnlocked;

local hideObj = frame.hide;					-- misc
local unhideObj = frame.Parent.unhide;

local module = {};
local camera = workspace.CurrentCamera;
local kfProto = workspace.Camera.kfProto:Clone();
local keyframes = workspace.Camera.keyframes;
local keyframeTable = require(workspace.Camera.keyframeTable);
local cameraFunc = workspace.Camera.cameraUpdater;
local Animator = workspace.Animation.Animator;
local FPS = workspace.switches.AnimatedFPS.Value;
local songEnd;
local scale;

local timeLine, pointer, keyframeList, playPause, btmSlider, set, add, sub,
	timeEdit, fovEdit, transEdit, splineEdit, CameraAng,
	rollLock, rollNumber, rollSlider;
local bindToPlay, unbindToPlay;

	-- SETUP --
module.setup = function()
	songEnd = workspace.Animation.SongEnd.Value;
	local scaleObj = workspace:FindFirstChild("Scale");
	scale = if scaleObj then scaleObj.Value else 1;
	
	local folder,copyFrom = workspace.Camera.keyframes , workspace.switches.KeyframeTrack.Value;
	folder:ClearAllChildren();
	for name,orig in pairs(copyFrom:GetChildren()) do
		local c = orig:Clone();
		c.Parent = folder;
	end
		-- GUI OBJS, AND UPDATE FUNCTIONS --
																---- RIGHT SIDE ----
	timeLine = gui.TimeLine:New(timeLineObj, windowObj);			-- timeline
	timeLine.maxBounds = {0, songEnd * 1.5};
	pointer = gui.Slider:New(timeLineObj, pointerObj);				-- pointer
	pointer.sliderRange = {0,0};
	pointer.clamp = false;
	pointer:addUpdate(function(self)
		self:set(math.clamp(self.value, 0, songEnd + 5*FPS));
		local frameVal = lib.millisToFrame(self.value);
		module.updateTime(frameVal, self);
		workspace.Animation.FrameCount.Value = frameVal;
	end);
	timeLine:addUpdate(function(self)
		pointer.sliderRange = {
			self.bounds[1] - self.msp*30 ,
			self.bounds[2] - self.msp*30};
		pointer:set(pointer.value);
	end);
	keyframeList = gui.KeyframeList:New(windowObj, timeLine);		-- keyframe list
	keyframeList:addUpdate(function() module.updateProps(); end);
	keyframeList.onSelect = function(self) module.updateCamera() end;
	keyframeList.onDeselect = function(self) module.updateCamera(camera) end;
	keyframeList.onKfRelease = function(self, kfObj)
		if not self.initalMove then return; end
		local kf = kfObjFromIndex(kfObj:GetAttribute("index"));
		local time = lib.map((kfObj.Position.X - self.kfLabelPos0.X).Offset ,
		                     0, self.holder.AbsoluteSize.x ,
		                     pointer.sliderRange[1], pointer.sliderRange[2]);
		kf:SetAttribute("time", math.floor(time + 0.5));
		module.updateKeyframes();
	end
	keyframeList.onKfDoubleClick = function(self, kfObj)
		local index = kfObj:GetAttribute("index");
		local millis = kfObjFromIndex(index):GetAttribute("time");
		local frameVal = lib.millisToFrame(millis + 1000/FPS);
		module.updateTime(frameVal);
		workspace.Animation.FrameCount.Value = frameVal;
	end;
	set = gui.Button:New(setObj);									-- add / remove buttons
	set.press = function(self) module.set(); end;
	add = gui.Button:New(addObj);
	add.press = function(self) module.add(); keyframeList:draw(); end;
	sub = gui.Button:New(subObj);
	sub.press = function(self) module.sub(); keyframeList:draw(); end;
	playPause = gui.PlayPause:New(playPauseObj);					-- play / pause
	playPause:addUpdate(function(self)
		(self.value and bindToPlay or unbindToPlay)();
	end);
	btmSlider = gui.Slider:New(btmSliderObj, btmSliderObj.scroll);	-- btm scroll bar
	btmSlider.sliderRange = {1, lib.millisToFrame(songEnd) + 5*FPS};
	btmSlider:addUpdate(function(self)
		module.updateTime(self.value, self);
		workspace.Animation.FrameCount.Value = self.value;
	end);
																---- LEFT SIDE ----
	timeEdit = gui.EditableText:New(timeEditObj, timeShowObj);		-- edit values
	fovEdit = gui.EditableText:New(fovEditObj, fovShowObj);
	transEdit = gui.EditableText:New(transEditObj, transShowObj);
	splineEdit = gui.EditableCheck:New(splideEditObj, splineShowObj);
	timeEdit.onEdit = kfUpdater("time");	-- possible sort them as well
	fovEdit.onEdit = kfUpdater("fov");
	transEdit.onEdit = kfUpdater("transition");
	splineEdit.onEdit = kfUpdater("spline");
	
	rollLock = gui.EditableCheckIcon:New(rollLockedObj, rollUnlockObj);		-- camera roll
	rollLock.onEdit = kfUpdater("rollLock");
	rollNumber = gui.EditableText:New(rollEditObj, rollShowObj);
	rollNumber.onEdit = kfUpdater("roll");
	rollSlider = gui.SliderLockable:New(rollSliderObj, rollSliderObj.scroll);	
	rollSlider.sliderRange = {-45,45};
	rollSlider.onEdit = function(self) kfUpdater("roll")(self); end
	rollSlider:addUpdate(function(self)
		kfObjFromIndex():SetAttribute("roll", self.value);
		rollNumber:set(string.format("%.1f", self.value) .. "°");
	end);
	
	local cameraObj = Instance.new("Camera",CFrameAngObj);		-- camera display
	CFrameAngObj.CurrentCamera = cameraObj;
	CameraAng = gui.CameraViewport:New(CFrameAngObj);
	
																	-- hide/unhide buttons
	hideObj.MouseButton1Down:Connect(	function() frame.Visible = false;	unhideObj.Visible = true; end);
	unhideObj.MouseButton1Down:Connect(	function() frame.Visible = true;	unhideObj.Visible = false; end);
end


function kfObjFromIndex(index)
	index = index or keyframeList.selected;
	local kfList = keyframes:GetChildren();
	for i = 1, #kfList do
		if tonumber(kfList[i].Name:match("%d+$")) == index then
			return kfList[i];
		end
	end
end
function kfUpdater(prop)
	return function(self)
		local val = self.value;
		if typeof(self.value) == "string" then
			local clean = self.value:gsub("°", "");
			val = tonumber(clean) or val;
		end
		
		kfObjFromIndex():SetAttribute(prop, val);
		module.updateKeyframes();
		keyframeList:draw();
	end;
end

	-- UPDATERS --
module.setEditable = function(canEdit)
	timeEdit:setEdit(canEdit);
	fovEdit:setEdit(canEdit);
	splineEdit:setEdit(canEdit);
	transEdit:setEdit(canEdit);
	
	rollLock:setEdit(canEdit);
	--rollNumber:setEdit(canEdit and not rollLock.value);
	--rollSlider:setEdit(canEdit and not rollLock.value);
	rollNumber:setEdit(canEdit);
	rollSlider:setEdit(canEdit);
end

module.updateTime = function(frameNum, ignore)				-- ignore object, i.e. if I'm calling this function from the slidebar
	frameCountObj.Text = string.format("%.0f", frameNum);	-- don't update the slidebar, so updateTime(frame, slidebar)
	timeCodeObj.Text = lib.frameToTimecode(frameNum);
	if ignore ~= timeLine then		timeLine:draw(); timeLine:onUpdate(); end
	if ignore ~= pointer then		pointer:set(lib.frameToMillis(frameNum)); end
	if ignore ~= btmSlider then		btmSlider:set(frameNum); end
end

module.updateCamera = function(camera)
	local cf, fov;
	if keyframeList.selected == -1 then
		cf,fov = camera.CFrame.Rotation + camera.CFrame.Position/scale, camera.FieldOfView;
	else
		local kf = kfObjFromIndex();
		cf, fov = kf.Value, kf:GetAttribute("fov");
	end
	CFramePosObj.X.Text = string.format("%.1f", cf.Position.X)..",";
	CFramePosObj.Y.Text = string.format("%.1f", cf.Position.Y)..",";
	CFramePosObj.Z.Text = string.format("%.1f", cf.Position.Z);
	
	CameraAng:update(cf);
	
	fovEdit:set(string.format("%.2f", fov));
end

module.updateProps = function()
	local time, i = pointer.value, keyframeList.selected;
	local kf = (i ~= -1)
		and	kfObjFromIndex()
		or	kfObjFromIndex(keyframeTable.lastIndex(time));
	
	local timeVal,fov,spline,trans,rollVal,rollLockVal;
	if kf ~= nil then
		timeVal = tostring(kf:GetAttribute("time"));
		fov     = tostring(kf:GetAttribute("fov"));
		spline  = kf:GetAttribute("spline");
		trans   = kf:GetAttribute("transition");
		rollVal     = kf:GetAttribute("roll");
		rollLockVal = kf:GetAttribute("rollLock");
	end
	if timeVal == nil then  timeVal = "N/A";  	 end
	if fov     == nil then  fov     = "N/A";  	 end
	if spline  == nil then  spline  = false;  	 end
	if trans   == nil then  trans   = "linear";  end
	if rollVal     == nil then  rollVal     = 0;     end
	if rollLockVal == nil then  rollLockVal = true;  end
	
	timeEdit:set(timeVal);
	--fovEdit:set(fov);
	splineEdit:set(spline);
	transEdit:set(trans);
	keyframeName.Text = (i ~= -1) and "Keyframe "..i	or "Properties";
	
	rollSlider:set(rollVal);
	rollNumber:set(string.format("%.1f", rollVal) .. "°");
	rollLock:set(rollLockVal);
	
	
	module.setEditable(i ~= -1);
end

function keyframesSort()
	local t = {};
	for i,v in pairs(keyframes:GetChildren()) do
		table.insert(t, v);
	end
	table.sort(t, function(a,b) return a:GetAttribute("time") < b:GetAttribute("time") end);
	
	for i = 1, #t do
		t[i].Name = "camera "..string.format("%.4d", i);
	end
end
module.updateKeyframes = function()
	keyframesSort();
	
	cameraFunc.setup:Fire();
	
	keyframeList.list = {};
	for _,v in pairs(keyframes:GetChildren()) do
		local i = tonumber(v.Name:match("%d+$"));
		keyframeList.list[i] = v:GetAttribute("time");
	end
	keyframeTable.update();
	Animator.redraw:Fire();
	module.updateCamera(camera);
end


	-- KEYFRAMES ADD / REMOVE --
module.add = function(timePos)
	timePos = timePos or pointer.value;
	
	local prev = keyframeTable.lastIndex(timePos);
	local lastKf = kfObjFromIndex(prev) or kfProto;
	local kf = lastKf:Clone();
	kf:SetAttribute("time", math.floor(timePos));
	
	local tempIndex = #keyframes:GetChildren() + 1;
	kf.Name = "camera "..tostring(tempIndex);
	kf.Parent = keyframes;

	module.set(tempIndex);
	--module.updateKeyframes();
	keyframeList.selected = -1;
end
module.sub = function(index)
	index = index or keyframeList.selected;
	if index == -1 or #keyframeList.list == 1 then return; end

	keyframeList.selected = -1;
	local kfSelected;
	for _,v in pairs(keyframes:GetChildren()) do
		if tonumber(v.Name:match("camera (%d+)")) == index then
			kfSelected = v;
			break;
		end
	end
	kfSelected:Destroy();
	module.updateKeyframes();
end

module.set = function(index)
	index = index or keyframeList.selected;
	if index == -1 then return; end

	local kf = kfObjFromIndex(index);
	if kf then
		local cf = camera.CFrame;
		kf.Value = cf-cf.Position + cf.Position/scale;
	end
	--kf:SetAttribute("fov", camera.FieldOfView);

	module.updateKeyframes();
end


	-- REAL-TIME PLAY --
local RunService = game:GetService("RunService");
local startTime, startFrame, bind;

function onStep(frameNum)
	frameNum = frameNum or startFrame + math.floor((tick() - startTime)*FPS/1);
	workspace.Animation.FrameCount.Value = frameNum;
	module.updateTime(frameNum);
	module.updateCamera(camera);
end

bindToPlay = function()
	startTime = tick();
	startFrame = workspace.Animation.FrameCount.Value;
	bind = RunService.Heartbeat:Connect(function() onStep() end);
	module.setEditable(false);
end
unbindToPlay = function()
	bind:Disconnect();
	module.setEditable(true);
end


return module;