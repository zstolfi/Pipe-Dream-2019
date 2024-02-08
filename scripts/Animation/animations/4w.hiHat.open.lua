local lib = require(workspace.lib);
local map,find = lib.map, lib.find;

local function applyFunc(self, T)
	local dispTable = {{x=0, y=0} ,
		{x=0, y=0.22} ,
		{x=0, y=0}};
	self.super:apply(self, T, dispTable, 0.5);
	
	local model = self.model;
	
	
	local rotZ,	armBend;
	local function w(x,f,d)		-- wiggle function
		if x > 0 then
			return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
		else
			return 0;
		end
	end
	
	rotZ = w(T,7.5,5.5) * -9;
	
	
	local hatTop,hatBottom = find(model,"arm 2.Cymbals.hatTop"), find(model,"arm 2.Cymbals.hatBottom");
	hatTop:SetPrimaryPartCFrame(hatTop:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(rotZ),0,0));
--	hatBottom:SetPrimaryPartCFrame(hatBottom:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(rotZ),0,0));
	
end


local Class = require(workspace.Class);
local fourWay = require(script.Parent["4w"]);

hiHatOpnAnim = fourWay:Extend({
	className = "hiHatOpnAnim" ,
	
	animId = "4w.hiHat.open" ,
	domain = {-680, 1300} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	apply = applyFunc
})

return hiHatOpnAnim;