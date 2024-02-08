local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

-- the parent "4w" animation does the marble, and the flex
local function applyFunc(self, sub, T, pointsDisplace, flexAngle)
	-- "sub" is self, but for the child object
	local model = sub.model
	local ball = sub.uniqueParts["marble"];
	
--	(examples)
--
--	pointsDisplace = {
--		{x=0, y=0} ,
--		{x=0, y=0.198} ,
--		{x=0, y=0}
--	};
--
--	flexAngle = 3 (degrees)
	
	local flex;
	if flexAngle ~= nil and flexAngle ~= 0 then -- Splash Bounce https://www.desmos.com/calculator/owdsu3dsri
		local function w(x,f,d)		-- time, frequency, decay
			if x > 0 then
				return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
			else
				return 0;
			end
		end
		local flexDecay = (6/flexAngle)+2;	
		
		flex = math.rad(w(T,7,flexDecay) * -flexAngle);
	end
	
	local ballX,ballY,ballZ;
	do	-- 4-Way Perc. note https://www.desmos.com/calculator/0f6zik3uwn
		
		local ts, tt, px, py;
		do	-- points
			ts = {680, 317};
			tt = {-680,0,317};
			
			px = {-34.327,	1.691,	11.727};
			py = {14.218,	19.875,	19.212};
			
			if pointsDisplace then
				for i = 1, #pointsDisplace do
					px[i] = px[i] + pointsDisplace[i].x;
					py[i] = py[i] + pointsDisplace[i].y;
				end
			end
		end
		
		-- parabola from 3 points (https://math.stackexchange.com/a/889571)
		local function p(p1,p2,p3)
			return function(x)
				return ((p1.y*(x-p2.x)*(x-p3.x))/((p1.x-p2.x)*(p1.x-p3.x))) +
					((p2.y*(x-p1.x)*(x-p3.x))/((p2.x-p1.x)*(p2.x-p3.x))) +
					((p3.y*(x-p1.x)*(x-p2.x))/((p3.x-p1.x)*(p3.x-p2.x)));
			end
		end
		
		local tg1, tg2;
		do	-- trajectories
			function tg1(x)	-- trajectory 1
				local x1 = -13.6;
				local y1 = 28;
				return p(
					{x=px[1], y=py[1]},
					{x=x1, y=y1},
					{x=px[2], y=py[2]}
				)(x);
			end
			
			function tg2(x)	-- trajectory 2
				local x2 = 6.7;
				local y2 = 21;
				return p(
					{x=px[2], y=py[2]},
					{x=x2, y=y2},
					{x=px[3], y=py[3]}
				)(x);
			end
		end
		
		function ballZ(t)
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
				return tg2(((t-tt[2])*(px[3]-px[2]) / ts[2]) +px[2]);
			end
		end
		
		function ballX(t)
			local z = ballZ(t);
			if not z then return; end
			
			local p1 = {x=-39.12, z=-34.357};
			local p2 = {x=-33.938, z=11.727};
			return (p2.x-p1.x)/(p2.z-p1.z) * (z-p1.z) + p1.x;
		end
	end
	
	if flex ~= nil then
		local fakeHinge = find(model,"arm 1.Fake Hinge");
		local arm1,arm2 = find(model,"arm 1"), find(model,"arm 2");
		local a1CF,a2CF = arm1:GetPrimaryPartCFrame(), arm2:GetPrimaryPartCFrame();
		
		fakeHinge.CFrame = fakeHinge.CFrame * CFrame.Angles(0,0,-flex/2);
		arm1:SetPrimaryPartCFrame(a1CF					* CFrame.Angles(0,0,flex));
		arm2:SetPrimaryPartCFrame(arm1.Connect.CFrame	* CFrame.Angles(0,0,flex));
	end
	
	
	if ballX(T) ~= nil and ballY(T) ~= nil and ballZ(T) ~= nil then
		ball.Position = scale * Vector3.new(ballX(T), ballY(T), ballZ(T));
	else
		ball.Position = Vector3.new(0,-100,0);
	end
	ball.Overlay.Position = ball.Position;
end


local Class = require(workspace.Class);
local AnimEvent = require(script.Parent.Parent.AnimEvent);

fourWay = AnimEvent:Extend({
	className = "fourWay" ,
	
	animId = nil ,
	domain = {-680, 317} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	apply = applyFunc
})

return fourWay;