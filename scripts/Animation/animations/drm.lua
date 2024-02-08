local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

-- the parent "drumset" animation does the marble path
local function applyFunc(self, sub, T, keyPoints, timeDomain, parabolaPoints)
	-- "sub" is self, but for the child object
	local model = sub.model
	local ball = sub.uniqueParts["marble"];

	--(example)
	
	--keyPoints =
	--	{z=  4.152, y= 12.414, x=-39.388} ,		The z and x axies are swapped for the Desmos graph,
	--	{z= -1.678, y=  3.804, x=-39.388}		as the trajectory depends on the z axis in-game
	--};
	
	--timeDomain = {-500, 370};		just for the marbles, the body/cymbals may have a different domain
	
	--parabolaPoints = {
	--	{x=-12, y=18.2} ,
	--	{x=2.3, y=10.98}
	--}
	
	--	(The starting keyPoint is not stored,
	--	as they're the same for all marbles)

	local ballX,ballY,ballZ;
	do	-- Drum key-points https://www.desmos.com/calculator/grcmy5rbxp

		local td, px, py, pz;
		do	-- points
			td = {timeDomain[1], timeDomain[2]};

			px = {-33.843,	keyPoints[1].z, keyPoints[2].z};
			py = { 14.831,	keyPoints[1].y, keyPoints[2].y};
			pz = {-39.388,	keyPoints[1].x, keyPoints[2].x};
		end

		-- parabola from 3 points (https://math.stackexchange.com/a/889571)
		local function p(p1,p2,p3)
			return function(x)
				return ((p1.y*(x-p2.x)*(x-p3.x))/((p1.x-p2.x)*(p1.x-p3.x))) +
					((p2.y*(x-p1.x)*(x-p3.x))/((p2.x-p1.x)*(p2.x-p3.x))) +
					((p3.y*(x-p1.x)*(x-p2.x))/((p3.x-p1.x)*(p3.x-p2.x)));
			end
		end
		
		-- line from 2 points
		local function l(p1,p2)
			return function(x) 
				return ((p2.y-p1.y)/(p2.x-p1.x)) * (x-p1.x) + p1.y;
			end
		end

		local tg1y,tg2y, tg1x,tg2x;
		do	-- trajectories
			function tg1y(x)	-- Y trajectory 1
				local x1 = parabolaPoints[1].x;
				local y1 = parabolaPoints[1].y;
				return p(
					{x=px[1], y=py[1]},
					{x=x1, y=y1},
					{x=px[2], y=py[2]}
				)(x);
			end
			function tg2y(x)	-- Y trajectory 2
				local x2 = parabolaPoints[2].x;
				local y2 = parabolaPoints[2].y;
				return p(
					{x=px[2], y=py[2]},
					{x=x2, y=y2},
					{x=px[3], y=py[3]}
				)(x);
			end
			
			function tg1x(x)	-- Z trajectory 1
				return l(
					{x=px[1], y=pz[1]},
					{x=px[2], y=pz[2]}
				)(x);
			end
			function tg2x(x)	-- Z trajectory 2
				return l(
					{x=px[2], y=pz[2]},
					{x=px[3], y=pz[3]}
				)(x);
			end
		end
		
		
		function ballZ(t)
			return t < 0
			and	((px[1]-px[2])/td[1]) * t + px[2]
			or	((px[3]-px[2])/td[2]) * t + px[2];
		end
		
		function ballY(t)
			return t < 0
			and	tg1y(map(t, td[1],0, px[1],px[2]))
			or	tg2y(map(t, 0,td[2], px[2],px[3]));
		end
		
		function ballX(t)
			return t < 0
			and	tg1x(map(t, td[1],0, px[1],px[2]))
			or	tg2x(map(t, 0,td[2], px[2],px[3]));
		end
	end

	if timeDomain[1] <= T and T <= timeDomain[2] and ballX(T)~=nil and ballY(T)~=nil and ballZ(T)~=nil then
		ball.Position = scale * Vector3.new(ballX(T), ballY(T), ballZ(T));
	else
		ball.Position = Vector3.new(0,-100,0);
	end
	ball.Overlay.Position = ball.Position;
end


local Class = require(workspace.Class);
local AnimEvent = require(script.Parent.Parent.AnimEvent);

drumset = AnimEvent:Extend({
	className = "drumset" ,

	animId = nil ,
	domain = {} ,
	movingCurves = function(self) return {

	}; end ,

	apply = applyFunc
})

return drumset;