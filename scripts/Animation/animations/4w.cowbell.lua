local lib = require(workspace.lib);
local map,find = lib.map, lib.find;

local function applyFunc(self, T)
	self.super:apply(self, T, nil, 1.5);
	
	local model = self.model;
	
	
	local bellAng,	armBend;
	local function w(x,f,d)		-- wiggle function
		if x > 0 then
			return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
		else
			return 0;
		end
	end
	
	bellAng = w(T,10,9) * -8;
	
	
	local bell = find(model,"arm 2.Bell");
	local bCF = bell:GetPrimaryPartCFrame();
	bell:SetPrimaryPartCFrame(bCF		* CFrame.Angles(0,0,math.rad(bellAng)));
	
end


local Class = require(workspace.Class);
local fourWay = require(script.Parent["4w"]);

cowbellAnim = fourWay:Extend({
	className = "cowbellAnim" ,
	
	animId = "4w.cowbell" ,
	domain = {-680, 600} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	apply = applyFunc
})

return cowbellAnim;