local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	local model = self.model;
	
	local armNumber = tonumber(model.Name:match("%d+"));
	local armAngle = map(armNumber, 1, 10, math.rad(-40.5), math.rad(40.5))
	local vibeCenter = workspace.Vibraphone.center.Position;
	local origin = CFrame.new(Vector3.new(1,0,1)*vibeCenter) * CFrame.Angles(0,armAngle,0);
	
	local ball = self.uniqueParts["marble"];
	
	
	local ballX,ballY,	bellAng;
	do	-- bell note https://www.desmos.com/calculator/wvjp3ate4w
		
		local ts, tt, px, py;
		do	-- points
			ts = {350, 800};
			tt = {-350,0,800};
			
			px = {0,	11.674,	1.87};
			py = {11,	37.716,	3.4};
		end
		
		-- parabola from 3 points (https://math.stackexchange.com/a/889571)
		local function p(p1,p2,p3)
			return function(x)
				return ((p1.y*(x-p2.x)*(x-p3.x))/((p1.x-p2.x)*(p1.x-p3.x))) +
					((p2.y*(x-p1.x)*(x-p3.x))/((p2.x-p1.x)*(p2.x-p3.x))) +
					((p3.y*(x-p1.x)*(x-p2.x))/((p3.x-p1.x)*(p3.x-p2.x)));
			end
		end
		
		do	-- bell swing
			local function w(x,f,d)		-- time, frequency, decay
				if x > 0 then
					return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
				else
					return 0;
				end
			end
			
			bellAng = w(T,1.2,0.3) * 4;
		end
		
		
		
		local tg1, tg2;
		do	-- trajectories
			function tg1(x)	-- trajectory 1
				local x1 = 18.2;
				local y1 = 39.7;
				return p(
					{x=px[1], y=py[1]},
					{x=x1, y=y1},
					{x=px[2], y=py[2]}
				)(x);
			end
			
			function tg2(x)	-- trajectory 2
				local x2 = 9.8;
				local y2 = 39.9;
				return p(
					{x=px[2], y=py[2]},
					{x=x2, y=y2},
					{x=px[3], y=py[3]}
				)(x);
			end
		end
		
		function ballX(t)
			if tt[1] <= t and t < tt[2] then
				return ((px[2]-px[1])/ts[1]) * (t-tt[1]) +px[1];
			elseif tt[2] <= t and t <= tt[3] then
				return ((px[3]-px[2])/ts[2]) * (t-tt[2]) +px[2];
			end
		end
		
		function ballY(t)
			if tt[1] <= t and t < tt[2] then
				return tg1(((t-tt[1])*(px[2]-px[1]) / ts[1]) +px[1]);
			elseif tt[2] <= t and t <= tt[3] then
					return tg2((-(t-tt[2])*(px[2]-px[3]) / ts[2]) +px[2]);
			end
		end
	end
	
	
	
	if ballX ~= nil and ballY ~= nil then
		ball.Position = origin * (scale * Vector3.new(ballX(T), ballY(T), 0));
	else
		ball.Position = Vector3.new(0,-100,0);
	end
	
	local bellNote = model.bell;
	bellNote:SetPrimaryPartCFrame(bellNote:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(bellAng),0,0));
	
end


local Class = require(workspace.Class);
local AnimEvent = require(script.Parent.Parent.AnimEvent);

bellNoteAnim = AnimEvent:Extend({
	className = "bellNoteAnim" ,
	
	animId = "bellNote" ,
	domain = {-350, 15000} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	apply = applyFunc
})

return bellNoteAnim;