local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	self.super:apply(self, T,
		{{z=4.152,	y=12.414,	x=-39.388},
		 {z=-1.678,	y=3.804,	x=-39.388}} ,
		{-668, 185} ,
		{{x=-13.42,	y=22.7},
		 {x=1.66,	y=9.9}}
	);
	
	local model = self.model;
	
	local head = find(model,"Head");
	local body = model.Body;
	local legParts = {
		find(model,"turn1.end"), find(model,"turn1.legPart") ,
		find(model,"turn2.end"), find(model,"turn2.legPart")};
	
	local headDisp, radiusAdd;
	do	-- Bass drum bounce https://www.desmos.com/calculator/0f6zik3uwn
		
		local function w(x,f,d)		-- wiggle function
			if x > 0 then
				return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
			else
				return 0;
			end
		end
		
		headDisp = w(T,8,8) * -0.20;
		radiusAdd = headDisp * 0.3;
		
	end
	
		-- drum head displace
	local headCF = head:GetPrimaryPartCFrame();
	headDisp  = scale * headDisp;
	radiusAdd = scale * radiusAdd;
	head:SetPrimaryPartCFrame(headCF * CFrame.new(-headDisp,0,0));
	body.CFrame = body.CFrame * CFrame.new(-headDisp/2,0,0);
	body.Size = body.Size + Vector3.new(-headDisp, 2*radiusAdd, 2*radiusAdd);
	
	
		-- legs displace
	local legDisp = 0.6 * headDisp;
	for i,v in pairs(legParts) do
		v.CFrame = v.CFrame + Vector3.new(0,0,legDisp);
	end
	
end


local Class = require(workspace.Class);
local drumset = require(script.Parent["drm"]);

bassAnim = drumset:Extend({
	className = "bass" ,

	animId = "drm.bass" ,
	--domain = {-668, 185} ,
	domain = {-668, 350} ,
	movingCurves = function(self) return {
		find(self.model,"turn1") ,
		find(self.model,"turn2")
	}; end ,

	apply = applyFunc
})

return bassAnim;