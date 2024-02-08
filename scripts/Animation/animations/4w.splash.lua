local lib = require(workspace.lib);
local map,find = lib.map, lib.find;

local function applyFunc(self, T)
	self.super:apply(self, T, nil, 3.5);
	
	local model = self.model;
	
	
	local rotX,rotZ,	armBend;
	local function w_sin(x,f,d)		-- wiggle function
		if x > 0 then
			return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
		else
			return 0;
		end
	end
	
	local function w_cos(x,f,d)		-- cosine variant!
		if x > 0 then
			local peak = 1000/(4*f);
			local num = math.exp(-d*x/1000) * -math.cos(math.rad(40) + f*math.pi*x / 1000);
			if x < peak then
				return num * math.sin(math.pi*x / (2*peak));
			end
			return num;
			
		else
			return 0;
		end
	end
	
	rotZ = w_sin(T,3.5,1.5) * -30;
	rotX = w_cos(T,3.5,1.5) * 40;
	
	
	local cymbal = find(model,"arm 2.Cymbal");
	local cCF = cymbal:GetPrimaryPartCFrame();
	cymbal:SetPrimaryPartCFrame(cCF		* CFrame.Angles(math.rad(rotX), 0, math.rad(rotZ)));
	
end


local Class = require(workspace.Class);
local fourWay = require(script.Parent["4w"]);

splashAnim = fourWay:Extend({
	className = "splashAnim" ,
	
	animId = "4w.splash" ,
	domain = {-680, 2500} , -- possibly lessen 1500
	movingCurves = function(self) return {
		--find(self.model,"arm 2.turn")
	}; end ,
	
	apply = applyFunc
})

return splashAnim;