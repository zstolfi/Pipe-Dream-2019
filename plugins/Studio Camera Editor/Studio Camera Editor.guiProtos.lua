local InputService = game:GetService("UserInputService");
lib = require(workspace.lib);
local map = lib.map;
local lerp = lib.lerp;

local Class = require(workspace.Class);
local GuiObj = Class:Extend({
	className = "GuiObj" ,
	
	updateFuncs = {} ,
	addUpdate = function(self, func)
		table.insert(self.updateFuncs, func);
	end ,
	onUpdate = function(self)
		for _,v in pairs(self.updateFuncs) do	v(self);	end
	end ,

	onEdit = function(self) return; end ,
	--onUpdate = function(self) end
});

local chars = {
	["check"]		= "☑" , 
	["blankCheck"]	= "☐" ,
	["play"]		= "▶" ,
	["pause"]		= "  ▌▌"
};
local imgs = {
	["kf0"]	=	"rbxassetid://6595067559" ,
	["kf1"]	=	"rbxassetid://6595067740" ,
	["kf2"]	=	"rbxassetid://6595067958" ,
	["kf3"]	=	"rbxassetid://6595068187"
};

local guiProtos = {};

guiProtos.Slider = GuiObj:Extend({
	className = "Slider" ,
	
	sliderRange = nil ,	-- {min, max}
	value = 0 ,
	clamp = true;
	
	slider = nil ,	-- the Frame objects for the slider
	scroll = nil ,	-- and the scroll
	
	scrollMin = nil,
	scrollMax = nil;
	
	dragging = false ,
	dragInput = nil ,
	dragStart = nil ,
	startPos = nil ,
	
	update = function(self, input)
		local delta = input.Position.X - self.dragStart
		local newX = math.clamp(self.startPos + delta, self.scrollMin, self.scrollMax);
		if self.clamp == false then newX = self.startPos + delta; end
		self.scroll.Position = UDim2.fromOffset(newX ,
			self.scroll.Position.Y.Offset);
		self.value = map(newX, self.scrollMin,self.scrollMax, self.sliderRange[1],self.sliderRange[2]);
		
		self:onUpdate();
	end ,
	
	set = function(self, value)
		self.value = math.clamp(value, self.sliderRange[1], self.sliderRange[2]);
		if self.clamp == false then self.value = value; end
		
		self.scroll.Position = UDim2.fromOffset(map(self.value, self.sliderRange[1],self.sliderRange[2], self.scrollMin,self.scrollMax) ,
			self.scroll.Position.Y.Offset);
	end ,
	
	New = function(self, slider, scroll)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);
		
		obj.slider = slider;
		obj.scroll = scroll;
		obj.scrollMin,obj.scrollMax = 0, obj.slider.AbsoluteSize.X - obj.scroll.AbsoluteSize.X;

		obj.scroll.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				obj.dragging = true;
				obj.dragStart = input.Position.X;
				obj.startPos = obj.scroll.Position.X.Offset;

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						obj.dragging = false;
					end
				end);
			end
		end);

		obj.scroll.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				obj.dragInput = input;
			end
		end);

		InputService.InputChanged:Connect(function(input)
			if input == obj.dragInput and obj.dragging and not obj.locked then
				obj:update(input);
				obj:onEdit();
			end
		end);
		
		return obj;
	end
});

guiProtos.SliderLockable = guiProtos.Slider:Extend({
	className = "SliderLockable" ,
	
	canEdit = true ,
	setEdit = function(self, canEdit)
		self.canEdit = canEdit;
		self.slider.BackgroundTransparency = canEdit and 0 or 0.5;
	end ,
	
	onEdit = function(self) return; end ,
});

guiProtos.Button = GuiObj:Extend({
	clasName = "Button" ,
	
	button = nil ,
	
	press = function(self) end ,
	
	New = function(self, button)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);

		obj.button = button;

		obj.button.MouseButton1Down:Connect(function()
			obj:press();
		end);

		return obj;
	end
});

guiProtos.PlayPause = GuiObj:Extend({
	className = "PlayPause" ,
	
	value = false ,	-- false => paused,	true => playing
	
	button = nil ,
	
	press = function(self)
		self.value = not self.value;
		self:update();
	end ,
	
	update = function(self)
		local char	= self.value and chars.pause or chars.play;
		local size	= self.value and 14 or 20;
		self.button.Text = char;
		self.button.TextSize = size;
		
		self:onUpdate();
	end ,

	New = function(self, button)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);

		obj.button = button;

		obj.button.MouseButton1Down:Connect(function()
			obj:press();
		end);

		return obj;
	end
});

guiProtos.EditableText = GuiObj:Extend({
	className = "EditableText" ,
	
	value = "" ,
	canEdit = false ,
	
	textEdit = nil ,
	textShow = nil ,
	
	onEdit = function(self) return; end ,
	
	set = function(self, value)
		self.value = value;
		self:display();
	end ,
	
	display = function(self)
		self.textEdit.Text = self.value;
		self.textShow.Text = self.value;
	end ,
	
	setEdit = function(self, canEdit)
		self.canEdit = canEdit;
		self.textEdit.Visible = canEdit;
		self.textShow.Visible = not canEdit;
		self.value = self.textEdit.Text;
		
		self:onUpdate();
	end ,
	
	New = function(self, textEdit, textShow)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);

		obj.textEdit = textEdit;
		obj.textShow = textShow;

		obj.textEdit.FocusLost:Connect(function()
			obj:setEdit(true);
			obj:onEdit();
		end);

		return obj;
	end
});

guiProtos.EditableCheck = GuiObj:Extend({
	className = "EditableCheck" ,
	
	value = false ,
	canEdit = false ,

	checkEdit = nil ,
	checkShow = nil ,
	
	pressFuncs = {} ,
	addPress = function(self, func)	table.insert(self.pressFuncs, func);	end ,
	
	set = function(self, value)
		self.value = value;
		self:display();
	end ,
	
	press = function(self)
		self.value = not self.value;
		self:onEdit();
		for _,v in pairs(self.pressFuncs) do	v(self);	end
		self:display();
	end ,
	
	display = function(self)
		local char = (self.value) and chars.check or chars.blankCheck;
		self.checkEdit.Text = char;
		self.checkShow.Text = char;
	end ,
	
	setEdit = function(self, canEdit)
		self.canEdit = canEdit;
		self.checkEdit.Visible = canEdit;
		self.checkShow.Visible = not canEdit;
		
		self:onUpdate();
	end ,

	New = function(self, checkEdit, checkShow)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);

		obj.checkEdit = checkEdit;
		obj.checkShow = checkShow;
		
		obj.checkEdit.MouseButton1Down:Connect(function()
			obj:press();
		end);
		
		return obj;
	end
});

guiProtos.EditableCheckIcon = GuiObj:Extend({ -- used for the lock
	className = "EditableCheckIcon" ,

	value = false ,
	canEdit = false ,

	checkTrue  = nil ,
	checkFalse = nil ,

	pressFuncs = {} ,
	addPress = function(self, func)  table.insert(self.pressFuncs, func);  end ,

	set = function(self, value)
		self.value = value;
		self:display();
	end ,

	press = function(self)
		self.value = not self.value;
		self:onEdit();
		for _,v in pairs(self.pressFuncs) do  v(self);  end
		self:display();
	end ,

	display = function(self)
		self.checkTrue.Visible  = self.value;
		self.checkFalse.Visible = not self.value;
	end ,

	setEdit = function(self, canEdit)
		self.canEdit = canEdit;
		self.checkTrue.ImageTransparency  = canEdit and 0 or 0.5;
		self.checkFalse.ImageTransparency = canEdit and 0 or 0.5;

		self:onUpdate();
	end ,

	New = function(self, checkTrue, checkFalse)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);

		obj.checkTrue = checkTrue;
		obj.checkFalse = checkFalse;	

		obj.checkTrue.MouseButton1Down:Connect(function()
			if obj.canEdit then
				obj:press();
			end
		end);
		obj.checkFalse.MouseButton1Down:Connect(function()
			if obj.canEdit then
				obj:press();
			end
		end)

		return obj;
	end
});


guiProtos.CameraViewport = GuiObj:Extend({
	className = "CameraViewport" ,
	
	viewport = nil ,
	camera = nil ,
	
	update = function(self, CFrameIn)
		local CFrameAng = CFrame.fromEulerAnglesXYZ(0,math.pi,0) * (CFrameIn - CFrameIn.Position);
		
		self.camera.FieldOfView = 40;
		self.camera.CFrame = CFrameAng:Inverse() * CFrame.new(0,0,15);
		
		self:onUpdate();
	end ,
	
	New = function(self, viewport)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);
		
		obj.viewport = viewport;
		obj.camera = viewport.CurrentCamera;
		
		return obj;
	end
});

local keyframeProto = script.keyframeIcon:Clone();
guiProtos.KeyframeList = GuiObj:Extend({
	className = "KeyframeList" ,
	
	list = {} , -- list of times in millis	
	selected = -1 , -- index of selected keyframe, -1 if none selected
	
	holder = nil ,
	timeLine = nil , -- timeLine object, the keyframes are placed relative to
	labels = {} ,
	--labelAdd -- defined below
	
	kfLabelPos0 = UDim2.new(0, -9, 0.5, 0) ,
	
	onSelect = function(self) end ,
	
	onDeselect = function(self) end ,

	lastClickTime = 0 ,	-- for the double click
	onKfClick = function(self, kfObj)
		local index = kfObj:GetAttribute("index"); --print(index);
		self.selected = index;
		self:onSelect();
		self:draw();
	end ,
	
	onKfDoubleClick = function(self, kfObj) end ,
	
	initalMove = false ,
	onKfRelease = function(self, kfObj) end ,
	
	labelDragInputs = {} , -- table of each label's dragInput
	labelDragging = {} ,   -- boolean for each label
	labelDragStart = {} ,  -- mosue x in asbsolute pos
	
	labelAdd = function(self, amount)
		local startSize = #self.labels;
		for index = 1, amount do -- inialize keyframe Icon
			local i = index + startSize;
			local kfObj = keyframeProto:Clone();
			kfObj:SetAttribute("index", #self.labels + 1);
			kfObj.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
						-- mouse PRESSED!			
					local t = tick(); local diff = t - self.lastClickTime;
					if .050 <= diff and diff <= .400 then	self:onKfDoubleClick(kfObj);
					elseif diff > .400 then					self:onKfClick(kfObj);	end
					self.lastClickTime = t;
					self.labelDragging[i] = true;
					self.labelDragStart[i] = input.Position.x;
					
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End and self.labelDragging[i] then
								-- mouse RELEASED!
							self:onKfRelease(kfObj);
							self.labelDragging[i] = false;
							self.initalMove = false;
						end
					end);
				end
			end);
			
			kfObj.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					self.labelDragInputs[i] = input;
				end
			end);
			InputService.InputChanged:Connect(function(input)
				if input == self.labelDragInputs[i] and self.labelDragging[i]
				and math.abs(self.labelDragStart[i] - input.Position.x) > 2 then -- check if it moves at least 5px
					-- mouse DRAGGED!
					self.initalMove = true;
					kfObj.Position = self.kfLabelPos0
						+ UDim2.fromOffset(input.Position.x - self.holder.AbsolutePosition.x, 0);
				end
			end);
			
			table.insert(self.labels, kfObj);
		end
	end ,
	
	draw = function(self)
		local labels = self.labels;
		local diff = #self.list - #labels
		if diff > 0 then self:labelAdd(diff); end

		for i = 1, #self.list do
			local img = imgs.kf2;
			if #self.list == 1 then
				img = imgs.kf0;
			elseif i == 1 then
				img = imgs.kf1;
			elseif i == #self.list then
				img = imgs.kf3;
			end
			labels[i].Image = img;
			
			local tl = self.timeLine;
			local bound1 = tl.bounds[1] - tl.msp*30;
			local bound2 = tl.bounds[2] - tl.msp*30;
			labels[i].Position = self.kfLabelPos0
				+ UDim2.fromOffset(map(self.list[i], bound1,bound2, 0,tl.zoomWindow.AbsoluteSize.X), 0);
			
			if i == self.selected then
				labels[i].ImageColor3 = Color3.fromRGB(153, 217, 234);
				labels[i].ZIndex = 2;
			else
				labels[i].ImageColor3 = Color3.fromRGB(255, 255, 255);
				labels[i].ZIndex = 1;
			end
		end

		self:onUpdate();

		for i = 1, #labels do
			if i <= #self.list then
				labels[i].Parent = self.holder;
			else
				labels[i].Parent = nil;
			end
		end
	end ,
	
	New = function(self, holder, timeLine)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);
		
		obj.holder = holder;
		obj.timeLine = timeLine;
		obj.timeLine:addUpdate(function(self)
 			obj:draw();
		end);
		
		obj.holder.InputBegan:Connect(function(input)  -- when you click on empty space
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if input.Position.Y >= obj.holder.AbsolutePosition.Y + 20 then
					obj.selected = -1;
					obj:onDeselect();
					obj:draw();
				end
			end
		end);
		
		return obj;
	end
});


local timeLabelProto = script.timeLabel:Clone();
local timeUnits = {100, 500, 1000, 5000, 15000, 30000, 60000, 300000, 900000, 1800000, 3600000, 21600000};
local function timeText(time, unit)
	local hours,minutes,seconds,millis = "", "", "", "";
	
	if math.floor(time/3600000) ~= 0 then	-- HOURS
		hours = string.format("%i", time/3600000)..":";
	end
	
	if unit <= 21600000 then	-- MINUTES
		if math.floor(time/60000) ~= 0 then
			if time < 3600000 then
				minutes = string.format("%i", time/60000 % 60)..":";
			else
				minutes = string.format("%.2i", time/60000 % 60)..":";
			end
		end
	else
		minutes = string.format("%.2i", time/60000 % 60)..":";
	end
	
	if time < 60000 then	-- SEONCDS
		seconds = string.format("%i", time/1000 % 60);
	else
		seconds = string.format("%.2i", time/1000 % 60);
	end	
	
	if unit <= 100 then		-- MILLIS
		millis = "."..string.format("%.2i", time/10 % 100);
	elseif unit <= 1000 then
		millis = "."..string.format("%.1i", time/100 % 10);
	end
	
	return hours .. minutes .. seconds .. millis;
end
guiProtos.TimeLine = GuiObj:Extend({
	className = "TimeLine" ,
	
	maxBounds = {0, 86400000} , -- the min/max the window is alowed to stretch (default to 24 hrs in millis)
	minZoom = 200;
	bounds = nil ,	-- {left, right}
	zoomFactor = 1.5 ,
	
	timeLabels = {} ,	-- {}, store the timeLabels in the script
	--timeLabelAdd -- defined below
	
	timeHolder = nil ,	-- where the time gui's are stored
	zoomWindow = nil ,	-- what zooms in if you scroll
	
	mouseIn = false ,
	scrollInput = nil ,
	
	timeLabelAdd = function(self, amount)
		for i = 1, amount do	table.insert(self.timeLabels, timeLabelProto:Clone());	end
	end ,
	
	draw = function(self)
		local winSize = self.zoomWindow.AbsoluteSize.X;
		local minTextSpace = 50;
		self.msp = (self.bounds[2]-self.bounds[1]) / winSize;		-- milliseconds per pixel
		
		local unit;
		for i = 1, #timeUnits do
			if minTextSpace*self.msp < timeUnits[i] then
				unit = timeUnits[i];
				break;
			elseif i == #timeUnits then
				unit = timeUnits[#timeUnits]
			end
		end
		
		local drawTimes = {};	-- https://www.desmos.com/calculator/lcvrwhifr4
		drawTimes[1] = math.floor(self.bounds[1] / unit) * unit;
		local steps = math.ceil(self.bounds[2] / unit) - math.floor(self.bounds[1] / unit);
		for i = 2, steps + 1 do
			drawTimes[i] = drawTimes[1] + (i-1)*unit;
		end
		
		
		local labels = self.timeLabels;
		local diff = #drawTimes - #labels;
		if diff > 0 then self:timeLabelAdd(diff); end
		
		for i = 1, #drawTimes do
			labels[i].Text = timeText(drawTimes[i], unit);
			labels[i].Position = UDim2.new(0, -25, 0, 0)
				+ UDim2.fromOffset((drawTimes[i] - self.bounds[1])/self.msp +30, 0);
		end
		
		for i = 1, #labels do
			if i <= #drawTimes then
				labels[i].Parent = self.timeHolder;
			else
				labels[i].Parent = nil;
			end
		end
	end ,
	
	update = function(self, input)
		local scrollDir = input.Position.Z;
		local mouseX = input.Position.X;
		local winPos,winSize = self.zoomWindow.AbsolutePosition.X, self.zoomWindow.AbsoluteSize.X;
		
		
		local zoomInto = map(mouseX-30, winPos,winPos+winSize, self.bounds[1],self.bounds[2]);
		
		local mult = self.zoomFactor ^ -scrollDir;
		local newDist = (self.bounds[2] - self.bounds[1]) * mult;
		if newDist > self.maxBounds[2] - self.maxBounds[1] then		-- zoomed further than 24hrs
			self.bounds[1],self.bounds[2] = self.maxBounds[1], self.maxBounds[2];
		elseif lerp(self.bounds[1], zoomInto, 1 - mult) < self.maxBounds[1] then	-- left size goes past 0 (left min)
			self.bounds[1] = self.maxBounds[1]	;
			self.bounds[2] = newDist;
		elseif newDist > self.minZoom then							-- normal case
				-- https://i.imgur.com/ZNLSA6Y.png
			local alpha = 1 - mult;
			self.bounds[1] = lerp(self.bounds[1], zoomInto, alpha);
			self.bounds[2] = lerp(self.bounds[2], zoomInto, alpha);
		end
		
		self:draw();
		self:onUpdate();
	end ,

	New = function(self, timeHolder, window)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		GuiObj:_initTables(obj);

		obj.timeHolder = timeHolder;
		obj.zoomWindow = window;
		
		obj.bounds = {0, 60000};
		
		obj.zoomWindow.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				obj.mouseIn = true;
				obj:update(input);
			end
		end);

		obj.zoomWindow.MouseEnter:Connect(function() obj.mouseIn = true; end);
		obj.zoomWindow.MouseLeave:Connect(function() obj.mouseIn = false; end);
		
		obj.zoomWindow.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				obj.scrollInput = input;
			else
				obj.scrollInput = nil;
			end
		end);
		
		InputService.InputChanged:Connect(function(input)
			if input == obj.scrollInput and obj.mouseIn then
				obj:update(input);
			end
		end);

		return obj;
	end
});

return guiProtos;