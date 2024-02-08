local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	self.super:apply(self, T,
		{{z=1.761,	y=19.382,	x=-44.303},
		 {z=15.99,	y=24.622,	x=-45.139}} ,
		{-701, 401} ,
		{{x=-13.3,	y=28.5},
		 {x=10.8,	y=25.92}}
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

		headDisp = w(T,8,12) * -0.12;
		radiusAdd = headDisp * 1;

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

snareAnim = drumset:Extend({
	className = "snare" ,

	animId = "drm.snare" ,
	domain = {-701, 401} ,
	movingCurves = function(self) return {

		}; end ,

	apply = applyFunc
})

return snareAnim;