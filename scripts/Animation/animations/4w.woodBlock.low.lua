local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	local dispTable = {{x=0, y=0} ,
		{x=-1.212, y=0} ,
		{x=0, y=0}};
	self.super:apply(self, T, dispTable, 0.5);
	
	local model = self.model;
	
	
	local barDisp,	armBend;
	local function w(x,f,d)		-- wiggle function
		if x > 0 then
			return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
		else
			return 0;
		end
	end
	
	barDisp = w(T,5,9) * .4;
	
	
	local block = find(model,"arm 2.Low Woodblock");
	local blockParts = {
		find(block,"Block") ,
		find(block,"b1") ,
		find(block,"b2")
	};
	barDisp = scale * barDisp;
	for i,v in pairs(blockParts) do
		v.CFrame = v.CFrame * CFrame.new(0,barDisp,0);
	end
	
	local strAng = math.atan2(barDisp, scale * 0.8);
	local str1Mod,str2Mod = find(block,"string left"), find(block,"string right");
	str1Mod:SetPrimaryPartCFrame(str1Mod:GetPrimaryPartCFrame() * CFrame.Angles(0,0,-strAng));
	str2Mod:SetPrimaryPartCFrame(str2Mod:GetPrimaryPartCFrame() * CFrame.Angles(0,0,strAng));
	
end


local Class = require(workspace.Class);
local fourWay = require(script.Parent["4w"]);

wdBlkLoAnim = fourWay:Extend({
	className = "wdBlkLoAnim" ,
	
	animId = "4w.woodBlock.high" ,
	domain = {-680, 1000} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	apply = applyFunc
})

return wdBlkLoAnim;