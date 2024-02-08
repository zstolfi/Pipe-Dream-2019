local m3d = require(workspace.m3d); 
local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	local block = self.uniqueParts["marimbaBlock"];
	local ball = self.uniqueParts["marble"];
	
	local ballX,ballY,ballZ,	blockCF, barDisp
	do	-- Marimba Path https://www.desmos.com/calculator/z3e847hjig
		-- Marimba marble https://www.desmos.com/calculator/legvciv3mm
		
			--BLOCK STUFF
		
		local speed = 54.03 -- studs per second
		
		local p1,p2,p3,p4,p5,p6 =
			{x=-72.224,	y= 4.945} ,
			{x=-72.224,	y=23.095} ,
			{x=-64.841,	y=30.478} ,
			{x=-23.458,	y=30.478} ,
			{x=-16.075,	y=23.095} ,
			{x=-16.075,	y= 4.945}
		local r1 = math.abs(p3.x - p2.x);
		local r2 = math.abs(p5.x - p4.x);
		
		local l = {};
		l[1] = math.abs(p2.y - p1.y);
		l[2] = 0.5 * math.pi * r1;
		l[3] = math.abs(p4.x - p3.x);
		l[4] = 0.5 * math.pi * r2;
		l[5] = math.abs(p6.y - p5.y);
		
		local function s(index)
			local sum = 0;
			for i=1, index do
				sum = sum + l[i];
			end
			return sum;
		end
		
		local blkPosX, blkPosY, blkNormX, blkNormY;
		blockCF = function(T)
			local x = map(T, -2400,2400, s(0),s(5));
			if  x<s(1) then
				blkPosX, blkPosY =	p1.x, x+p1.y;
				blkNormX, blkNormY =	-1, 0;
			elseif s(1)<=x and x<s(2) then
				blkPosX, blkPosY =		-r1*math.cos(map(x, s(1),s(2), 0,math.pi/2))+p3.x ,
										r1*math.sin(map(x, s(1),s(2), 0,math.pi/2))+p2.y;
				blkNormX, blkNormY =	-math.cos(map(x, s(1),s(2), 0,math.pi/2)) ,
										math.sin(map(x, s(1),s(2), 0,math.pi/2));
			elseif s(2)<=x and x<s(3) then
				blkPosX, blkPosY =		(x-s(2))+p3.x, p3.y;
				blkNormX, blkNormY =	0, 1;
			elseif s(3)<=x and x<s(4) then
				blkPosX, blkPosY =		r2*math.sin(map(x, s(3),s(4), 0,math.pi/2))+p4.x ,
										r2*math.cos(map(x, s(3),s(4), 0,math.pi/2))+p5.y;
				blkNormX, blkNormY =	math.sin(map(x, s(3),s(4), 0,math.pi/2)) ,
										math.cos(map(x, s(3),s(4), 0,math.pi/2));
			elseif s(4)<=x then
				blkPosX, blkPosY =		p5.x, -(x-s(4))+p5.y;
				blkNormX, blkNormY =	1, 0;
			end
			
			local pos = Vector3.new(blkPosX, blkPosY, 17.245);
			local norm = Vector3.new(blkNormX, blkNormY, 0);
			return CFrame.fromMatrix(
				pos ,
				norm:Cross(Vector3.new(0, 0, 1)) ,
				norm ,
				Vector3.new(0, 0, 1)
			);
		end
		
		local function w(x,f,d)		-- wiggle function
			if x > 0 then
				return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
			else
				return 0;
			end
		end
		
		barDisp = w(T,6,5) * 0.4;
		
		
		
			-- BALL STUFF
		local ts, tt, px, py;
		do	-- points
			ts = {534, 601};
			tt = {-534,0,601};
			
			px = {-28.674,	-44.15,	-56.652};
			py = {33.496,	33.12,	18.837};
		end
		
		-- parabola from 3 points
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
				local x1 = -36.13;
				local y1 = 39;
				return p(
					{x=px[1], y=py[1]},
					{x=x1, y=y1},
					{x=px[2], y=py[2]}
				)(x);
			end
			
			function tg2(x)	-- trajectory 2
				local x2 = -48.7;
				local y2 = 35.6;
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
				return tg2(((t-tt[2])*(px[3]-px[2]) / ts[2]) +px[2]);
			end
		end
		
		function ballZ(t)
			local x = ballX(t);
			if not x then return; end
			
			local p1 = {x=-28.674, y=29.193};
			local p2 = {x=-56.652, y=7.318};
			return (p2.y-p1.y)/(p2.x-p1.x) * (x-p1.x) + p1.y;
		end
		
	end 
	
	if ballX(T) ~= nil and ballY(T) ~= nil and ballZ(T) ~= nil then
		ball.Position = scale * Vector3.new(ballX(T), ballY(T), ballZ(T));
	else
		ball.Position = Vector3.new(0,-100,0);
	end
	ball.Overlay.Position = ball.Position;
	
	local bCF = blockCF(T);
	block:SetPrimaryPartCFrame(bCF-bCF.Position + scale * bCF.Position);
	barDisp = scale * barDisp;
	find(block,"bar").CFrame = find(block,"bar").CFrame * CFrame.new(0,0,barDisp);
	local strAng = math.atan2(barDisp, scale * 1.095);
	local str1Mod,str2Mod = find(block,"string top"), find(block,"string bottom");
	str1Mod:SetPrimaryPartCFrame(str1Mod:GetPrimaryPartCFrame() * CFrame.Angles(0,0,strAng));
	str2Mod:SetPrimaryPartCFrame(str2Mod:GetPrimaryPartCFrame() * CFrame.Angles(0,0,-strAng));
	
end

local function loadBlock(self)
	local largest,smallest = scale * 6.919, scale * 1.519;
	local param = self.importInfo.marimba;
	local maxPitch = param and param.note_high or 79;
	local minPitch = param and param.note_low  or 36;
	
	local pitch = self.pitch;
	local barLength = map(pitch, minPitch,maxPitch, largest, smallest);
	
	local b = self.uniqueParts["marimbaBlock"];
	local bar = find(b,"bar");
	
	bar.Size = Vector3.new(0,1,1) * find(b,"bar").Size +
						Vector3.new(1,0,0) * barLength;
	local disp = (barLength - smallest)/2;	-- displacement
	for _,v in pairs(b:GetDescendants()) do
		if v.Name:match("^bottom") then
			v.CFrame = v.CFrame + Vector3.new(0,0,-disp);
		elseif v.Name:match("^top") then
			v.CFrame = v.CFrame + Vector3.new(0,0,disp);
		elseif v.Name:match("arm3") then
			m3d.shrink(v, Enum.NormalId.Back, -disp/math.cos(math.rad(15)));
		end
	end
	local str1,str2 = find(b,"string bottom"), find(b,"string top");
	str1:SetPrimaryPartCFrame(str1:GetPrimaryPartCFrame() + Vector3.new(0,0,-disp));
	str2:SetPrimaryPartCFrame(str2:GetPrimaryPartCFrame() + Vector3.new(0,0,disp));
	
	local tex = bar:FindFirstChildOfClass("Texture");
	if tex then
		tex.OffsetStudsU = 0.5 * (tex.StudsPerTileU - bar.Size.x);
	end
end

local Class = require(workspace.Class);
local AnimEvent = require(script.Parent.Parent.AnimEvent);

marimbaAnim = AnimEvent:Extend({
	className = "marimbaAnim" ,
	
	animId = "marimba" ,
	domain = {-2400, 2400} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	loadFunctions = {loadBlock};
	apply = applyFunc
})

return marimbaAnim;