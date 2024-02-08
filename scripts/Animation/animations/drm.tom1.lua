local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	self.super:apply(self, T,
		{{z=-2.749,	y=20.116,	x=-53.528},
		 {z=9.61,	y=23.041,	x=-59.152}} ,
		{-834, 367} ,
		{{x=-16.3,	y=28.76},
		 {x=4.04,	y=24.3}}
	);
	
	local model = self.model

	local head = find(model,"Head");
	local body = model.Body;

	local headDisp, radiusAdd;
	do	-- Bass drum bounce https://www.desmos.com/calculator/0f6zik3uwn

		local function w(x,f,d)		-- wiggle function
			if x > 0 then
				return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
			else
				return 0;
			end
		end

		headDisp = w(T,8,10) * -0.15;
		radiusAdd = headDisp * 0.05;

	end

	local headCF = head:GetPrimaryPartCFrame();
	headDisp  = scale * headDisp;
	radiusAdd = scale * radiusAdd;
	head:SetPrimaryPartCFrame(headCF * CFrame.new(-headDisp,0,0));
	body.CFrame = body.CFrame * CFrame.new(-headDisp/2,0,0);
	body.Size = body.Size + Vector3.new(-headDisp, 2*radiusAdd, 2*radiusAdd);
	
end


local Class = require(workspace.Class);
local drumset = require(script.Parent["drm"]);

tom1Anim = drumset:Extend({
	className = "tom1" ,

	animId = "drm.tom1" ,
	domain = {-834, 367} ,
	movingCurves = function(self) return {

		}; end ,

	apply = applyFunc
})

return tom1Anim;