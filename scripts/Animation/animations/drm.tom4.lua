local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	self.super:apply(self, T,
		{{z=9.784,	y=23.522,	x=-42.124},
		 {z=-9.86,	y=3.459,	x=-40.953}} ,
		{-685, 567} ,
		{{x=-4.5,	y=28.7},
		 {x=0.4,	y=21.3}}
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

		headDisp = w(T,8,8) * -0.15;
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

tom4Anim = drumset:Extend({
	className = "tom4" ,

	animId = "drm.tom4" ,
	domain = {-685, 567} ,
	movingCurves = function(self) return {

		}; end ,

	apply = applyFunc
})

return tom4Anim;