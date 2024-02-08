
		-- Math 3D Script --

local e = Enum.NormalId;
local map = require(workspace.lib).map;

local m3d = {};

m3d.edgePoint = function(part, x, y ,z)
	return part.CFrame * (part.Size * Vector3.new(x,y,z) * 0.5);
end


m3d.cosangle = function(vec1, vec2)
	return vec1.Unit:Dot(vec2.Unit);
end

m3d.angle = function(vec1, vec2)
	local angle = math.acos(vec1.Unit:Dot(vec2.Unit));
	if angle ~= angle then -- NaN check!
		angle = 0;
	end
	
	return angle;
end

m3d.signedAngle = function(vec1, vec2, normal)
	local angle = m3d.angle(vec1, vec2);
	if normal:Dot(vec1:Cross(vec2)) < 0 then
	  angle = -angle;
	end
	return angle;
end


m3d.antiRidge = function(cs, ce)
	local csr,cer = cs.CFrame.RightVector, ce.CFrame.RightVector;
	local cosangle = m3d.cosangle(csr, cer);
	local width1,width2 = math.min(cs.Size.y, cs.Size.z), math.min(ce.Size.y, ce.Size.z);
	
	if csr:FuzzyEq(cer, 0.001) then
		local point1 = m3d.edgePoint(cs, -1,0,0);
		local point2 = m3d.edgePoint(ce,  1,0,0);
		
		local distBetween = (point1 - point2).magnitude;
		local expTo = distBetween/2;
		local exp1,exp2 = expTo-cs.Size.x, expTo-ce.Size.x;

		m3d.expand(cs, e.Right, exp1);
		m3d.expand(ce, e.Left, exp2);
		return;
	end
	
	-- [[course adjustment]]
	-- make their centers meet
	local csP = m3d.edgePoint(cs, 1,0,0);
	local ceP = m3d.edgePoint(ce, -1,0,0);
	local bClo1,bClo2 = m3d.closestPoints(cs.Position, csr, ce.Position, cer);
	local len1 = (bClo1-csP):Dot(csr); -- signed dist
 	local len2 = (bClo2-ceP):Dot(-cer);
	
	local tan =  math.sqrt((1-cosangle)/(1+cosangle));
	local fine1 = (width1/2) * tan;
	local fine2 = (width2/2) * tan;
	
	m3d.expand(cs, e.Right, len1 + fine1);
	m3d.expand(ce, e.Left, len2 + fine2);
end

m3d.antiRidgeOld = function(cs, ce)	-- (unused)
----	if true then return; end
--	local cloPoint = m3d.closestPoints;
--	local faceCoords = m3d.faceCoords;
--	local closestPlanePoint = m3d.closestPlanePoint;
	
--	local csr,cer = cs.CFrame.RightVector, ce.CFrame.RightVector;
--	local sS,eS = cs.Size, ce.Size;
	
--	if csr:FuzzyEq(cer, 0.01) then
--		local point1 = m3d.edgePoint(cs, -1,0,0);
--		local point2 = m3d.edgePoint(ce, 1,0,0);
		
--		local distBetween = (point1 - point2).magnitude;
--		local expTo = distBetween/2;
--		local exp1,exp2 = expTo-sS.x, expTo-eS.x;

--		m3d.expand(cs, e.Right, exp1);
--		m3d.expand(ce, e.Left, exp2);
--		return;
--	end
	
--		-- [[course adjustment]]
--		-- make their centers meet
--	local csP = m3d.edgePoint(cs, 1,0,0);
--	local ceP = m3d.edgePoint(ce, -1,0,0);
--	local bClo1,bClo2 = cloPoint(cs.Position, csr, ce.Position, cer);
--	local len1 = (bClo1-csP):Dot(csr); -- signed dist
-- 	local len2 = (bClo2-ceP):Dot(-cer);
--	m3d.expand(cs, e.Right, len1);
--	m3d.expand(ce, e.Left, len2);
--	local sS,eS = cs.Size, ce.Size;
	
--	local width1 = math.min(sS.y, sS.z);
--	local width2 = math.min(eS.y, eS.z);
	
--				---------------------------------------
--				--          [define points]          --
--				--  https://i.imgur.com/4osZcWd.png  --
--				---------------------------------------
				
--		-- [[fine adjustment]]
--	local v = {}; local norm;
--	v[11] = cs.CFrame * (cs.Size * Vector3.new(-1,0,0) * .5); -- start of part
--	v[12] = ce.CFrame * (ce.Size * Vector3.new(1,0,0) * .5);
--	v[01],v[02] = cloPoint(v[11], csr, v[12], cer); -- "origins"
--	if v[01]:isClose(v[02]) then
--		norm = (v[11]-v[01]):Cross(v[12]-v[02]);
--	else
--		local diff = v[02] - v[01];
--		local new12 = v[12] - diff;
--		norm = (v[11]-v[01]):Cross(new12-v[01]);
--	end
	
--	v[21] = norm:Cross(csr).Unit * width1/2 + v[01];
--	v[22] = norm:Cross(cer).Unit * width2/2 + v[02];
	
--	v[31],v[32] = cloPoint(v[21], csr, v[22], cer);
--	local w2,w1 = width1,width2;
--	v[33] = (w1*v[31] + w2*v[32])/(w1+w2); -- weighted average
	
--	-- the part that uses the PointToFaceCoords script
--	local csX, csY = faceCoords(cs, e.Right, v[33]);
--	local ceX, ceY = faceCoords(ce, e.Left, v[33]);
--	ceX = width2-ceX; ceY = width2-ceY;	-- invert it, to match cs
----	print(csX, csY); print(ceX, ceY);
	
--	local function rtCircle(x, r) -- https://www.desmos.com/calculator/htqjsgxwxa
--		local function f(x)
--			if -r <= x and x <= r then
--				return math.sqrt(r^2 - x^2);
--			else
--				return 0;
--			end
--		end
--		return r - f(x-r);
--	end
--	local function rtSquare(x, r, ang) -- https://www.desmos.com/calculator/ht0aeirgve (so proud of this AAAAAAAHHHH)
		
--		-- recreate the stuff in the "square" folder. Maybe a bit extra but, eh
--		local l = 2*r;
--		local s0X = {0,0,l,l};
--		local s0Y = {0,l,l,0};
		
--		local s1X,s1Y = {},{};
--		for i = 1,4 do
--			s1X[i] = (s0X[i]-r)*math.cos(ang)-(s0Y[i]-r)*math.sin(ang)+r;
--			s1Y[i] = (s0X[i]-r)*math.sin(ang)+(s0Y[i]-r)*math.cos(ang)+r;
--		end
		
--		local lnum = (function()
--			if -math.pi <= ang and ang < -math.pi/2 then
--				return 3
--			elseif -math.pi/2 <= ang and ang < 0 then
--				return 4
--			elseif 0 <= ang and ang < math.pi/2 then
--				return 1
--			else
--				return  2
--			end
--		end)();
--	local lo = {x=s1X[lnum], y=s1Y[lnum]};
--		local hiNum = math.fmod(lnum+1,4)+1;
--		local hi = {x=s1X[hiNum], y=s1Y[hiNum]};
		
--		local function f(x)
--			if math.fmod(ang,math.pi/2) == 0 then
--				return r;
--			else	-- g(x)
--				if x < lo.y-r then
--					return -lo.x+r;
--				elseif lo.y-r <= x  and x <= hi.y-r then	-- h(x)
--					local i0 = {x = hi.x-r, y = hi.y-r};
--					local i1 = {x = lo.y-r, y = -lo.x+r};
--					if x <= hi.x-r then
--						return (i0.y - i1.y)/(i0.x - i1.x) * (x-i0.x)+i0.y;
--					else
--						return (i1.x - i0.x)/(i0.y - i1.y) * (x-i0.x)+i0.y;
--					end
--				else
--					return -hi.x+r
--				end
--			end
--		end
--		return r - f(x-r);
--	end
	
--	local distFunc = {};
--	local fTab = {cs, ce};
--	local rtV = {[1]={}, [2]={}};
	
--	for i,v in pairs(fTab) do	-- asign the dist functions to the right parts
--		local x = ({csX, ceX})[i];
--		local y = ({csY, ceY})[i];
--		local width = ({width1, width2})[i];
		
--		local v1 = norm;
--		local v2 = -v.CFrame.UpVector;	-- it doesn't matter which non-Right vector this is, we're testing for mod-90° angles
--		local dir = v.CFrame.RightVector;
--		local ang = math.acos(v1:Dot(v2)/(v1.magnitude*v2.magnitude));
--		if dir:Dot(v1:Cross(v2)) < 0 then
--			ang = -ang;
--		end
		
--		if i == 1 then ang = -ang; end
--		local newY = (x-width/2)*math.sin(ang) + (y-width/2)*math.cos(ang) + width/2; -- calc Y as if it were 0° rotated
--		rtV[i][1] = newY;		-- 1 | x
--		rtV[i][2] = width/2;	-- 2 | r
		
--		if v.Shape == Enum.PartType.Cylinder then
--			distFunc[i] = rtCircle;
			
--		else
--			distFunc[i] = rtSquare;
			
			
--			rtV[i][3] = ang;	-- 3 | ang
--		end
--	end
	
--	local orgPoint1 = closestPlanePoint(v[33], csr, v[21]);
--	local orgPoint2 = closestPlanePoint(v[33], -cer, v[22]);
--	local move1 = distFunc[1]( unpack(rtV[1]) );
--	local move2 = distFunc[2]( unpack(rtV[2]) );
--	local moveDir1 = (v[01] - v[21]).unit;
--	local moveDir2 = (v[02] - v[22]).unit;
	
--	v[41] = orgPoint1 + moveDir1 * move1;
--	v[42] = orgPoint2 + moveDir2 * move2;
	
--	v[43] = cloPoint(v[41], csr, v[42], cer)	-- with those two points now defined, find where they intersect
--	local fine1 = (v[43] - v[41]):Dot(csr); -- signed dist
--	local fine2 = (v[43] - v[42]):Dot(-cer);
	
--				---------------------------------------
--				--         [/define points]          --
--				---------------------------------------
	
	
--	-- check for beginning side first. If the mid point (01 or 02) is behind (11 or 12) respectively, then assume straight line
--	local checkDist1 = (v[01] - v[11]):Dot(csr);
--	local checkDist2 = (v[02] - v[12]):Dot(-cer);
--	if checkDist1 <= 0.05 or checkDist2 <= 0.05 then -- if they are then make them both half of the length
		
--		if checkDist1 < 0 then
--			local move = (v[11]-v[01]);
--			v[11] = v[11] + move;
--			cs.CFrame = cs.CFrame + move;
--		elseif checkDist2 < 0 then
--			local move = (v[12]-v[02]);
--			v[12] = v[12] + move;
--			ce.CFrame = ce.CFrame + move;
--		end
		
--		local distBetween = (v[11] - v[12]).magnitude;
--		local expTo = distBetween/2;
--		local exp1,exp2 = expTo-sS.x, expTo-eS.x;

--		m3d.expand(cs, e.Right, exp1);
--		m3d.expand(ce, e.Left, exp2);
--	else
--		--	print(move1, move2);
--		m3d.expand(cs, e.Right, fine1);
--		m3d.expand(ce, e.Left, fine2);
--	end
	
end

m3d.closestPoints = function(pos1, dir1, pos2, dir2)	-- http://geomalgorithms.com/a07-_distance.html
	local u,v = dir1, dir2;
	local w0 = pos1 - pos2;
	local sc, tc;
	
	local a = u:Dot(u);
	local b = u:Dot(v);
	local c = v:Dot(v);
	local d = u:Dot(w0);
	local e = v:Dot(w0);
	
	sc = (b*e-c*d)/(a*c-b^2);
	tc = (a*e-b*d)/(a*c-b^2);
	
	local clo1 = pos1  + (dir1)*sc;
	local clo2 = pos2  + (dir2)*tc;
	
	return clo1, clo2;
end

m3d.closestPlanePoint = function(point, planeNorm, planePoint)
	local dist = planeNorm:Dot(point - planePoint);
	local uNorm = planeNorm.Unit	-- normalize
	local moveVec = uNorm * -dist;
	
	return point + moveVec;
end

m3d.normToImage = {};
	-- http://i.imgur.com/MOYearC.png ("Year" :P)
	m3d.normToImage[e.Back]		=	{ 1,-2, 0};
	m3d.normToImage[e.Bottom]	=	{1, 0, -2};	-- turns out decal bottoms are different (https://i.imgur.com/DCAtD2d.png)
	m3d.normToImage[e.Front]	=	{-1,-2, 0};
	m3d.normToImage[e.Left]		=	{ 0,-2, 1};
	m3d.normToImage[e.Right]	=	{ 0,-2,-1};
	m3d.normToImage[e.Top]		=	{-1, 0,-2};

local function faceSizeAndScale(part, normId)
	local faceDimentions = m3d.normToImage[normId];
	local sizeX, sizeY;
	local scaleX, scaleY;
	for i, v in pairs(faceDimentions) do -- run through the table that was returned, and assign respective 1's and 2's.
		local sizeT = {part.Size.x, part.Size.y, part.Size.z};
		if math.abs(v) == 1 then
			sizeX = sizeT[i];
			scaleX = (math.abs(v)==v) and 1 or -1;	-- if v is negative, then store as -1
		elseif math.abs(v) == 2 then
			sizeY = sizeT[i];
			scaleY = (math.abs(v)==v) and 1 or -1;
		elseif v ~= 0 then
			error("the normToImage table is messed up :(");
		end
	end
	local faceSize = Vector2.new(sizeX, sizeY); -- for the size, the orientation doesn't matter, so just the order
	local faceScale = Vector2.new(scaleX, scaleY); -- if it's negative the axis is inverted
	
	return faceSize, faceScale;
end

m3d.partFaceSize = function(part, normId)
	local val, _ = faceSizeAndScale(part, normId);
	return val;
end

m3d.partFaceScale = function (part, normId)
	local _, val = faceSizeAndScale(part, normId);
	return val;
end

m3d.imagePointToWorld = function(part, normId, point, imageSize)
--	local point = toWorld(px, py);

	local x, y;
	local s = m3d.partFaceScale(part, normId);
	local gF = normId.Name;
	local gS = {part.Size.x, part.Size.y, part.Size.z};
	local pos = {}; -- table of 3, one for each dimention
	local faceDimentions = m3d.normToImage[normId];
	
		-- determine what order the axies go, based on faceDimentions
	
	for i = 1, 3 do	-- one for each dimention
		if math.abs(faceDimentions[i]) == 1 then
			x = map(point.x, 0, imageSize.x, gS[i], 0);
			pos[i] = (gS[i]/2)*s.x - x*s.x;	-- to invert, multiply both the 2nd and 3rd numbers by -1
		elseif math.abs(faceDimentions[i]) == 2 then
			y = map(point.y, 0, imageSize.y, gS[i], 0);
			pos[i] = (gS[i]/2)*s.y - y*s.y;
		else	-- 0, this is the axis the decal is on, if its orthogonal
				-- (Top, Right, or Back) then add 50% of the Guide size
			pos[i] = (gS[i]/2) * ((gF=="Top" or gF=="Right" or gF=="Back") and 1 or -1);
		end
	end
	
	local offsetCFrame = CFrame.new(pos[1], pos[2], pos[3]);
	
	local newCFrame = part.CFrame:ToWorldSpace(offsetCFrame);
	
	return newCFrame.Position
end

m3d.faceCoords = function(obj, face, point)
	local objC = obj.CFrame;
	local zeroVect;
	
	local faceDimentions = m3d.normToImage[face];
	local a = math.abs;
	local faceX, faceY;
	local dirX, dirY;
	local pointX, pointY;
	
	for i, v in pairs(faceDimentions) do
		if a(v) == 1 then
			dirX = math.sign(v);
		elseif a(v) == 2 then
			dirY = math.sign(v);
		elseif v == 0 then
			local zVTable = {0,0,0};
			zVTable[i] = 1;
			zeroVect = Vector3.new(unpack(zVTable));
			if face==e.Front or face==e.Left or face==e.Bottom then
				zeroVect = -zeroVect;
			end
		end
	end
	
	-- find oldZero and newZer (https://i.imgur.com/AgkT2xj.png)
	local moveVecTab = {-1,-1,-1};
	local zvTable = {zeroVect.x, zeroVect.y, zeroVect.z};
	for i,v in pairs(zvTable) do
		if v ~= 0 then
			moveVecTab[i] = v;
		end
	end	-- oldZero
	for i, v in pairs(faceDimentions) do	-- calculate newZero (not a point on the image)
		if a(v) == 1 then
			moveVecTab[i] = moveVecTab[i] * dirX;
		elseif a(v) == 2 then
			moveVecTab[i] = moveVecTab[i] * dirY;
		end
	end
	local moveVec = Vector3.new(unpack(moveVecTab));
	local newZero = objC * (obj.Size * moveVec * .5);


		-- now find the coordinates! https://i.imgur.com/Qgj12Sg.png
		
	for i, v in pairs(faceDimentions) do
		local function direction(index, val)	-- shorthand function for which CFrame direction component to use, and sign it
			local tab = {[1]=objC.RightVector, [2]=objC.UpVector, [3]=-objC.LookVector}
			return math.sign(val) * tab[a(index)];
		end
		
		if a(v) == 1 then
			faceX = direction(i,v);
		elseif a(v) == 2 then
			faceY = direction(i,v);
		end
	end
	
	local imgPoint = point - newZero;	
	pointX = faceX:Dot(imgPoint);	
	pointY = faceY:Dot(imgPoint);
	
	return pointX, pointY;
end


m3d.expand = function(part, normId, ammount)
		local pC = part.CFrame;
	local vec;
	local dir;
	if normId==e.Front or normId==e.Back then
		vec = pC.LookVector; dir = Vector3.new(0,0,1);
	elseif normId==e.Right or normId==e.Left then
		vec = pC.RightVector; dir = Vector3.new(1,0,0);
	else
		vec = pC.UpVector; dir = Vector3.new(0,1,0);
	end
	if normId==e.Back or normId==e.Left or normId==e.Bottom then
		vec = -vec;
	end
	vec = vec.Unit * ammount;
	
	part.Position = part.Position + (vec/2);
	part.Size = part.Size + dir*ammount;
end

m3d.shrink = function(part, normId, ammount)
	m3d.expand(part, normId, -ammount);
end

--m3d.closestPoints = function(pos1, dir1, pos2, dir2)		-- old ver.
--	local p, q;
--	local closest1;
--	local closest2;
--	
--	local function cP()
--		
--		p = {
--			{dir1.x, pos1.x} ,
--			{dir1.y, pos1.y} ,
--			{dir1.z, pos1.z}
--		};
--		q = {
--			{dir2.x, pos2.x} ,
--			{dir2.y, pos2.y} ,
--			{dir2.z, pos2.z}
--		};
--		
--		local pq = {
--			{q[1][1],	-p[1][1],	q[1][2] - p[1][2]} ,
--			{q[2][1],	-p[2][1],	q[2][2] - p[2][2]} ,
--			{q[3][1],	-p[3][1],	q[3][2] - p[3][2]}
--		};
--		
--		local mt = {
--			__div = function(t, n)
--				for i,v in pairs(t) do
--					t[i] = v/n;
--				end
--				return t;
--			end ,
--			
--			__mul = function(t, n)
--				for i,v in pairs(t) do
--					t[i] = v*n;
--				end
--				return t;
--			end ,
--			
--			__sub = function(t1, t2)
--				for i,v in pairs(t1) do
--					t1[i] = t1[i] - t2[i];
--				end
--				return t1;
--			end
--		}
--		 -- third number of each equation is flipped, because that's what the equations equal to
--		local eq1 = {
--			pq[1][1]*dir1.x + pq[2][1]*dir1.y + pq[3][1]*dir1.z ,
--			pq[1][2]*dir1.x + pq[2][2]*dir1.y + pq[3][2]*dir1.z ,
--			-(pq[1][3]*dir1.x + pq[2][3]*dir1.y + pq[3][3]*dir1.z)
--		};
--		local eq2 = {
--			pq[1][1]*dir2.x + pq[2][1]*dir2.y + pq[3][1]*dir2.z ,
--			pq[1][2]*dir2.x + pq[2][2]*dir2.y + pq[3][2]*dir2.z ,
--			-(pq[1][3]*dir2.x + pq[2][3]*dir2.y + pq[3][3]*dir2.z)
--		};
--		eq1 = setmetatable(eq1, mt);
--		eq2 = setmetatable(eq2, mt);
--		
--							-- https://wordsandbuttons.online/programmers_introduction_to_linear_equations.html#system_3 --				
--			-- step 1
--		eq2 = eq2/eq2[2];
--			-- step 2
--		eq2 = eq2*eq1[2];
--			-- step 3
--		eq1 = eq1 - eq2;
--			-- step 4
--		eq1 = eq1/eq1[1];
--			-- step 5
--		eq1 = eq1*eq2[1];
--			-- step 6
--		eq2 = eq2 - eq1;
--			-- step 7
--		eq1 = eq1/eq1[1];
--		eq2 = eq2/eq2[2];
--		
--		return eq1[3], eq2[3];
--	end
--	
--	local s, t = cP();
--	
--	if not (-math.huge < s and s < math.huge) or not (-math.huge < t and t < math.huge) then	-- check for NaN
--		local orig1 = dir1;
--		local orig2 = dir2;
--		dir1 = orig1 + Vector3.new(0,.1,0);
--		dir2 = orig2 + Vector3.new(0,.1,0);
--		local a1, b1 = cP();
--		
--		dir1 = orig1 + Vector3.new(0,-.1,0);
--		dir2 = orig2 + Vector3.new(0,-.1,0);
--		local a2, b2 = cP();
--		
--		s = (a1+a2)/2;
--		t = (b1+b2)/2;
--		
--		dir1 = orig1;
--		dir2 = orig2;
--		cP();
--	end
--	
--	closest1 = Vector3.new(
--		p[1][1]*t + p[1][2] ,
--		p[2][1]*t + p[2][2] ,
--		p[3][1]*t + p[3][2]
--	);
--	closest2 = Vector3.new(
--		q[1][1]*s + q[1][2] ,
--		q[2][1]*s + q[2][2] ,
--		q[3][1]*s + q[3][2]
--	);
--	
--	return closest1, closest2;
--end

return m3d;