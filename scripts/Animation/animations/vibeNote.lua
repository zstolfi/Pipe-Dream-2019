local lib = require(workspace.lib);
local map,find = lib.map, lib.find;
scale = workspace.Scale.Value;

local function applyFunc(self, T)
	local model = self.model;
	
	local armNumber = tonumber(model.Name:match("%d+"));
	local armAngle = map(armNumber, 0, 40, 0, -2*math.pi) - math.pi/4;
	local vibeCenter = model.Parent.Parent.center.Position;
	local origin = CFrame.new(Vector3.new(1,0,1)*vibeCenter) * CFrame.Angles(0,armAngle,0);
	
	local ball = self.uniqueParts["marble"];
	
	
	local ballX,ballY,	barDisp,glow,	a1,a2,a3;
	do	-- Vibraphone Arm marble https://www.desmos.com/calculator/hwwl4toqll
		
		local ts, tt, px, py;
		do	-- points
			ts = {935, 768};
			tt = {-935,0,768};
			
			px = {0,	12.472,	22.294};
			py = {11.5,	16.347,	5.892};
		end
		
		do	-- vibe arms & block
			local function w(x,f,d)		-- time, frequency, decay
				if x > 0 then
					return math.exp(-d*x/1000) * -math.sin(f*math.pi*x / 1000);
				else
					return 0;
				end
			end
			
			barDisp = w(T,6,2) * 0.2;
			
			a1 = math.rad(w(T,3.1,1.3) * 3);
			a2 = math.rad(w(T,2.8,1.0) * 4);
			a3 = math.rad(w(T,2.3,1.5) * 3);
		end
		
		glow = (T>0) and 0.8*math.exp(-T/200) or 0;
		--glow = (T>0) and 1 - T/500 or 0;
		
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
				local x1 = 6.57;
				local y1 = 33.43;
				return p(
					{x=px[1], y=py[1]},
					{x=x1, y=y1},
					{x=px[2], y=py[2]}
				)(x);
			end
			
			function tg2(x)	-- trajectory 2
				local x2 = 16.86;
				local y2 = 25.5;
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
	end
	
	if ballX ~= nil and ballY ~= nil then
		ball.Position = origin * (scale * Vector3.new(ballX(T), ballY(T), 0));
	else
		ball.Position = Vector3.new(0,-100,0);
	end
	ball.Overlay.Position = ball.Position;
	
	local bar,glowPart = model.block.bar, model.block.glow;
	barDisp = scale * barDisp;
	bar.CFrame = bar.CFrame * CFrame.new(0,0,barDisp);
	glowPart.CFrame = bar.CFrame;
	local strAng = math.atan2(barDisp, scale * 1.095);
	local str1Mod,str2Mod = model.block["string top"], model.block["string bottom"];
	str1Mod:SetPrimaryPartCFrame(str1Mod:GetPrimaryPartCFrame() * CFrame.Angles(0,0,strAng));
	str2Mod:SetPrimaryPartCFrame(str2Mod:GetPrimaryPartCFrame() * CFrame.Angles(0,0,-strAng));
	
	local arm1,arm2,block = model["arm 1"], model["arm 2"], model.block;
	local a1CF,a2CF,bCF = arm1:GetPrimaryPartCFrame(), arm2:GetPrimaryPartCFrame(), block:GetPrimaryPartCFrame();
	
	arm1:SetPrimaryPartCFrame(a1CF												* CFrame.Angles(a1,0,0));
	arm2:SetPrimaryPartCFrame((a2CF - a2CF.Position + arm1.Connect.Position)	* CFrame.Angles(a2,0,0));
	block:SetPrimaryPartCFrame((bCF - bCF.Position + arm2.Connect.Position)		* CFrame.Angles(a3,0,0));
	
	glowPart.Transparency =  glowPart.Transparency - glow;
	
end


local Class = require(workspace.Class);
local AnimEvent = require(script.Parent.Parent.AnimEvent);

vibeNoteAnim = AnimEvent:Extend({
	className = "vibeNoteAnim" ,
	
	animId = "vibeNote" ,
	domain = {-935, 4500} ,
	movingCurves = function(self) return {
		
	}; end ,
	
	apply = applyFunc
})

return vibeNoteAnim;