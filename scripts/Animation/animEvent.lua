Class = require(workspace.Class);
local lib = require(workspace.lib);
local find = lib.find;

local tempParts = workspace.Animation.tempParts;
local modelVals,cloneVals = script.Parent.modelLocations, script.Parent.defaults;

AnimEvent = Class:Extend({
	className = "AnimEvent" ,
	
	animId = nil ,
	domain = {} ,
	
	model = nil ,
	pitch = nil ,
	
	importInfo = {} ,
	
	uniqueParts = nil ,
	movingUniquePartsOffsets = nil ,	-- {[<object>] = <CFrame offset> ...}
	getUniqueParts = function(self)
		local ClonedParts = {};
		self.uniqueParts = {}; 
		self.movingUniquePartsOffsets = {};
		
		local animFolder = workspace.Animation.animations;
		local animModule = animFolder[self.animId];
		
		for i,v in pairs(animModule:GetChildren()) do
			if v:IsA("ObjectValue") then
				local clone = v.Value:Clone();
				
				self.uniqueParts[v.Name] = clone;
			end
		end
	end ,
	
	getMovingUniquePartsOffsets = function(self)
		for _,model in pairs(self.uniqueParts) do
			for _,part in pairs(model:GetChildren()) do	-- search for %m flags (assumes unique part is a model)
				if part.Name:match(" %%m$") then
					local primaryCF = model:GetPrimaryPartCFrame();
					local partCF;
					if part:IsA("BasePart") then
						partCF = part.CFrame;
					elseif part:IsA("Model") then
						partCF = part:GetPrimaryPartCFrame();
					end
					
					self.movingUniquePartsOffsets[part] = primaryCF:inverse() * partCF;
				end
			end
		end
	end ,
	
	resetMovingUniqueParts = function(self)
		for part,offset in pairs(self.movingUniquePartsOffsets) do
			local primaryCF = part.Parent:GetPrimaryPartCFrame(); -- LIMITATION!: Only direct descendants will be checked for %m flags
			
			if part:IsA("BasePart") then
				part.CFrame = primaryCF * offset;
			elseif part:IsA("Model") then
				part:SetPrimaryPartCFrame(primaryCF * offset);
			end
		end
	end ,
	
	movingCurves = function() return nil; end ,	-- function that returns the autoArcs which need to be redrawn every frame
	
	queueCurves = function(self)
		local model = self.model;
		local folder = workspace.Animation.curvesToDraw;
		for _,curveModel in pairs(self:movingCurves()) do
			local id = lib.relativeName(model, curveModel);
			
			if lib.findChild(folder,id) == nil then
				local v = Instance.new("ObjectValue");
				v.Value = curveModel;
				
				v.Name = id .. " %1"; -- the flag is the multiplicity
				v.Parent = folder;
			else
				local objVal = lib.findChild(folder,id);
				local mult = tonumber(lib.flag(objVal)); 
				
				objVal.Name = id .. " %" .. mult+1;
			end
		end
	end ,
	
	unqueueCurves = function(self)
		local model = self.model;
		local folder = workspace.Animation.curvesToDraw;
		
		for _,curveModel in pairs(self:movingCurves()) do
			local id = lib.relativeName(model, curveModel);
			
			local objVal = lib.findChild(folder,id);
			local mult = tonumber(lib.flag(objVal)); 
			
			if mult > 1 then
				objVal.Name = id .. " %" .. mult-1;
			else
				objVal:Destroy();
			end
		end
	end ,
	
	apply = nil ,	-- function of time, main animation function
	
	initialized = false;
	visible = false ,
	
	loadFunctions = {} ,
	
	init = function(self)
		for _,v in pairs(self.loadFunctions) do
			v(self);
		end
		self.initialized = true;
	end ,
	
	load = function(self)
		self:getMovingUniquePartsOffsets();
		
		for i,v in pairs(self.uniqueParts) do
			v.Parent = tempParts
		end
		self:queueCurves();
		
		self.visible = true;
	end ,
	
	unload = function(self)
		self:unqueueCurves();
		for i,v in pairs(self.uniqueParts) do
			v.Parent = nil;
			--v:Destroy();
		end
		
		self.visible = false;
	end ,
	
	New = function(self, model, pitch, aTime, importInfo)
		local obj = Class:New();
		setmetatable(obj, self);
		self.__index = self;
		
		obj.model = model;
		obj.pitch = pitch;
		obj.time = aTime;
		obj.importInfo = importInfo;
		obj:getUniqueParts();
		
		return obj;
	end
})

return AnimEvent;