local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
local m3d = require(workspace.m3d);
local imagePointToWorld = m3d.imagePointToWorld;
scale = workspace.Scale.Value;

local convFactor = 3.86;

local function applyFunc(self, t)
	local model = self.model;
	
	local guide;
	local guideFace;
	local function graphToWorld(x,y)
		if typeof(x) == "Vector2" then
			x,y = unpack{x.x, x.y};
		end
		
		local imageSize = Vector2.new(2400, 1600);
		local image0 = Vector2.new(252, 1374); -- x & y pixel point where (0,0) lies.
		local image1 = Vector2.new(389, 1235); -- point (1,1)
		
		local imgPoint =  Vector2.new(
			map(x, 0, 1, image0.x, image1.x),
			map(y, 0, 1, image0.y, image1.y)
		);
		
		local pos = imagePointToWorld(guide, guideFace, imgPoint, imageSize);
		pos = pos*Vector3.new(1,1,0) + model.PrimaryPart.Position*Vector3.new(0,0,1);
		
		return pos;
	end
	
	if not guide or not guideFace then
		local guideName = model.Name:match("Bass") and "Stringo Bass Guide" or "Stringo Banjo Guide";
		guide = game.ReplicatedStorage[guideName];
		guideFace = guide.Decal.Face;
	end
	
	local ball = self.uniqueParts["marble"];
	
	
	local ballX,ballY,	bongoDisp,	s1BezLen,s2BezLen, s1w,s2w, holder1Ang,holder2Ang;
	do	-- Bass v2 https://www.desmos.com/calculator/diixrqacil
	
		local px, py, ts, tt;
		do	-- points
			px = {	1.89,	6.294,	2.316,	4.191,	3.02};
			py = {	5.87,	3.339,	3.1177,	1.894,	0.603};
			
			ts = {817, 405, 203, 484};
			tt = {-817, 0, 405, 608, 1092};
		end
		
		-- parabola from 3 points (https://math.stackexchange.com/a/889571)
		local function p(p1,p2,p3)
			return function(x)
				return ((p1.y*(x-p2.x)*(x-p3.x))/((p1.x-p2.x)*(p1.x-p3.x))) +
					((p2.y*(x-p1.x)*(x-p3.x))/((p2.x-p1.x)*(p2.x-p3.x))) +
					((p3.y*(x-p1.x)*(x-p2.x))/((p3.x-p1.x)*(p3.x-p2.x)));
			end
		end
		
		-- bezier curve stuff
		local function b1(t, p0, p1, p2, p3)
			return (1-t)^3*p0 + 3*(1-t)^2*t*p1 + 3*(1-t)*t^2*p2 + t^3*p3;
		end
		local function b2(t, p0, p1, p2, p3)
			return 3*(1-t)^2*(p1-p0) + 6*(1-t)*t*(p2-p1) + 3*t^2*(p3-p2);
		end
		local function bn(t, p0, p1, p2 ,p3)
			return Vector2.new(-b2.y, b2.x).Unit;
		end
		
		
		-- string stuff
		local function sw(x)	-- string bounce
			if x > 0 then
				return math.exp(-10*x/1000) * -math.sin(60*math.pi*x / 1000);
			else
				return 0;
			end
		end
		
		s1w,s2w = sw(t-tt[3]), sw(t-tt[2]);
		
		function s1BezLen(strLen)
			return 4/(3*math.pi) * math.sqrt(strLen^2 + math.pi^2 * s1w*0.15*convFactor);
		end
		function s2BezLen(strLen)
			return 4/(3*math.pi) * math.sqrt(strLen^2 + math.pi^2 * s2w*0.15*convFactor);
		end
		
		local function hw(x)	-- holder bounce
			if x > 0 then
				return math.exp(-13*x/1000) * -math.sin(10*math.pi*x / 1000);
			else
				return 0;
			end
		end
		holder1Ang = 9 * hw(t-tt[3]); -- given in degreees
		holder2Ang = 9 * hw(t-tt[2]);
		
		
		-- bongos
		local function bw(x)	-- bongo bounce
			if x > 0 then
				return math.exp(-13*x/1000) * -math.sin(10*math.pi*x / 1000);
			else
				return 0;
			end
		end
		bongoDisp = 0.2 * bw(t-tt[4]);
		
		local tg1, tg2, tg3, tg4;
		do	-- trajectories
			function tg1(x)	-- trajectory 1
				local x1 = 3.61;
				local y1 = 7.72;
				return p(
					{x=px[1], y=py[1]},
					{x=x1, y=y1},
					{x=px[2], y=py[2]}
				)(x);
			end
			function tg2(x)	-- trajectory 2
				local x2 = 3.46;
				local y2 = 4.01;
				return p(
					{x=px[2], y=py[2]},
					{x=x2, y=y2},
					{x=px[3], y=py[3]}
				)(x);
			end
			function tg3(x)	-- trajectory 3
				local x3 = 3.10;
				local y3 = 2.75;
				return p(
					{x=px[3], y=py[3]},
					{x=x3, y=y3},
					{x=px[4], y=py[4]}
				)(x);
			end
			function tg4(x)	-- trajectory 4
				local x4 = 3.71;
				local y4 = 2.60;
				return p(
					{x=px[4], y=py[4]},
					{x=x4, y=y4},
					{x=px[5], y=py[5]}
				)(x);
			end
		end
		
		
		function ballX(t)
			if t < tt[2] then
				return ((px[2]-px[1])/ts[1]) * (t-tt[1]) +px[1];
			elseif tt[2]<=t and t<tt[3] then
				return ((px[3]-px[2])/ts[2]) * (t-tt[2]) +px[2];
			elseif tt[3]<=t and t<tt[4] then
				return ((px[4]-px[3])/ts[3]) * (t-tt[3]) +px[3];
			else
				return ((px[5]-px[4])/ts[4]) * (t-tt[4]) +px[4];
			end
		end
		
		function ballY(t)
			if t < tt[2] then
				return tg1(((t-tt[1])*(px[2]-px[1]) / ts[1]) +px[1]);
			elseif tt[2]<=t and t<tt[3] then
				return tg2((-(t-tt[2])*(px[2]-px[3]) / ts[2]) +px[2]);
			elseif tt[3]<=t and t<tt[4] then
				return tg3(((t-tt[3])*(px[4]-px[3]) / ts[3]) +px[3]);
			else
				return tg4((-(t-tt[4])*(px[4]-px[5]) / ts[4]) +px[4]);
			end
		end
		
	end
	if ballX(t) ~= nil and ballY(t) ~= nil then
		ball.Position = graphToWorld(ballX(t), ballY(t));
	else
		ball.Position = Vector3.new(0,-100,0);
	end
	ball.Overlay.Position = ball.Position;
	
	bongoDisp = scale * bongoDisp;
	model.b1.Position = model.b1.CFrame * Vector3.new(bongoDisp,0,0);
	model.b2.Position = model.b2.CFrame * Vector3.new(bongoDisp,0,0);
	model.b3.Position = model.b3.CFrame * Vector3.new(bongoDisp/2,0,0);
	
	
	local holders = {
		{find(model,"str 1 top"), find(model,"str 1 bottom")} ,
		{find(model,"str 2 top"), find(model,"str 2 bottom")}
	};
	
	for i = 1, 2 do	-- make the holders bounce!
		for j = 1, 2 do
			local ang = (i==1 and -holder1Ang or holder2Ang);
			local ang = ang * (j==1 and 1 or -1);
			local newCF = holders[i][j]:GetPrimaryPartCFrame() * CFrame.fromEulerAnglesXYZ(0,0, math.rad(ang));
			holders[i][j]:SetPrimaryPartCFrame(newCF);
		end
	end
	
	local str1S = find(model,"string 1.start");
	local str1E = find(model,"string 1.end");
	local str2S = find(model,"string 2.start");
	local str2E = find(model,"string 2.end");
	
	str1S.Position = holders[1][1].Connect.Position;
	str1E.Position = holders[1][2].Connect.Position;
	str2S.Position = holders[2][2].Connect.Position;
	str2E.Position = holders[2][1].Connect.Position;
	
	local str1Len = (str1S.Position - str1E.Position).Magnitude;
	local str2Len = (str2S.Position - str2E.Position).Magnitude;
	local str1BezLen = scale * s1BezLen(str1Len / scale);
	local str2BezLen = scale * s2BezLen(str2Len / scale);
	
	local str1NewAng = math.atan2(scale * math.pi*s1w, str1BezLen * convFactor);
	local str2NewAng = math.atan2(scale * math.pi*s2w, str2BezLen * convFactor);
	
	str1S.CFrame = str1S.CFrame * CFrame.fromEulerAnglesXYZ(0,0, -str1NewAng);
	str1E.CFrame = str1E.CFrame * CFrame.fromEulerAnglesXYZ(0,0, str1NewAng);
	str2S.CFrame = str2S.CFrame * CFrame.fromEulerAnglesXYZ(0,0, -str2NewAng);
	str2E.CFrame = str2E.CFrame * CFrame.fromEulerAnglesXYZ(0,0, str2NewAng);
	
	str1S.Name = "start %" .. str1BezLen;
	str1E.Name = "end %" .. str1BezLen;
	str2S.Name = "start %" .. str2BezLen;
	str2E.Name = "end %" .. str2BezLen;
end


local Class = require(workspace.Class);
local AnimEvent = require(script.Parent.Parent.AnimEvent);

stringoAnim = AnimEvent:Extend({
	className = "stringoAnim" ,
	
	animId = "stringo" ,
	domain = {-817, 1092} ,
	movingCurves = function(self) return {
		find(self.model,"string 1") ,
		find(self.model,"string 2")
	}; end ,
	
	apply = applyFunc
})

return stringoAnim;