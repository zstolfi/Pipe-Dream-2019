local lib = require(workspace.lib);
local map,find = lib.map, lib.find;

local function applyFunc(self, T)
	self.super:apply(self, T,
		{{z=3.011,	y=22.001,	x=-56.017},
		 {z=14.645,	y=20.008,	x=-55.852}} ,
		{-801, 334} ,
		{{x=-13.45,	y=30.54},
		 {x=8.5,	y=24.84}}
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

		rotZ = wx(T,2  ,1) * 17;
		rotX = wy(T,1.8,1) * -12;
	end

	local cCF = cymbal:GetPrimaryPartCFrame();
	cymbal:SetPrimaryPartCFrame(cCF		* CFrame.Angles(math.rad(rotX), 0, math.rad(rotZ)));

end


local Class = require(workspace.Class);
local drumset = require(script.Parent["drm"]);

crash2Anim = drumset:Extend({
	className = "crash2" ,

	animId = "drm.crash2" ,
	--domain = {-801, 334} ,
	domain = {-801, 6500} ,
	movingCurves = function(self) return {

		}; end ,

	apply = applyFunc
})

return crash2Anim;