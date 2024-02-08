local lib = require(workspace.lib);
local map,find = lib.map, lib.find;

local function applyFunc(self, T)
	self.super:apply(self, T,
		{{z=11.271,	y=22.831,	x=-27.057},
		 {z=23.111,	y=21.471,	x=-28.527}} ,
		{-935, 367} ,
		{{x=-10.37,	y=30.9},
		 {x=16.95,	y=23.85}}
	);
	
	local model = self.model
	
	local cymbal = model.Cymbal;
	
	local rotX, rotZ;
	do	-- Wave sin cos https://www.desmos.com/calculator/elnw2bestk
		local function wx(x,f,d)		-- wiggle function
			if x > 0 then
				return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
			else
				return 0;
			end
		end
		local function wy(x,f,d)		-- wiggle function (but with cosine!!!)
			if x > 0 then
				return math.min((f*x/1000),1) *
					math.exp(-d*x/1000) *math.cos(math.rad(50) + f*math.pi*x / 1000);
			else
				return 0;
			end
		end

		rotZ = wx(T,2.3,1) * -20;
		rotX = wy(T,2  ,1) * -15;
	end

	local cCF = cymbal:GetPrimaryPartCFrame();
	cymbal:SetPrimaryPartCFrame(cCF		* CFrame.Angles(math.rad(rotX), 0, math.rad(rotZ)));
	
end


local Class = require(workspace.Class);
local drumset = require(script.Parent["drm"]);

crash1Anim = drumset:Extend({
	className = "crash1" ,

	animId = "drm.crash1" ,
	--domain = {-935, 367} ,
	domain = {-935, 6500} ,
	movingCurves = function(self) return {

		}; end ,

	apply = applyFunc
})

return crash1Anim;