local lib = {}	-- just a collection of usefull functions!

lib.lerp = function(a,b,c)
	return a + (b - a) * c;
end

lib.map = function(value, start1, stop1, start2, stop2)
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
end

lib.tableLen = function(t)
	local count = 0;
	for _ in pairs(t) do
		count += 1;
	end
	return count;
end

lib.tableFind = function(t, value) -- retruns the firnt found index
	if not t then return; end
	for i,v in pairs(t) do
		--print(#v, v, "\t", #value, value);
		if v == value then
			return i;
		end
	end
end

lib.tableFindAll = function(t, value)
	if not t then return; end
	local final = {};
	for i,v in pairs(t) do
		if v == value then
			final[#final+1] = i;
		end
	end
	return final;
end

lib.removeNils = function(t)
	local final = {};
	for _,v in pairs(t) do
		final[#final+1] = v;
	end
	return final;
end

lib.tableSortedCopy = function(t)
	local copy = {unpack(t)};
	table.sort(copy);
	return copy;
end

lib.tableFromIndexes = function(t) -- return a table of just the indexes
	local result = {};
	for i in pairs(t) do
		table.insert(result, i);
	end
	return result;
end

lib.tableFloorValue = function(t, value) -- acts like the floor function for a table of numbers
	local copy = lib.tableSortedCopy(t);
	
	for i = #copy, 1, -1 do -- itterate backwards
		if copy[i] <= value then
			return copy[i], i;
		end
	end
	return copy[1];
end

lib.tableCeilValue = function(t, value) -- acts like ceil
	local copy = lib.tableSortedCopy(t);
	
	for i = 1, #copy do -- forwards this time
		if copy[i] >= value then
			return copy[i], i;
		end
	end
	return copy[#copy];
end

lib.tableRoundValue = function(t, value)
	local copy = lib.tableSortedCopy(t);
	
	for i = 1, #copy-1 do
		if copy[i] <= value  and  value <= copy[i+1] then
			return value - copy[i] < copy[i+1] - value and copy[i] or copy[i+1], i;
		end
	end
	return value <= copy[1] and copy[1] or copy[#copy];
end

lib.closestIndexSortedTable = function(t, index)	-- TODO: really improve these two
	local closest = 1e100;
	for i in pairs(t) do
		if closest == nil or math.abs(i - index) < math.abs(closest - index) then
			closest = i;
		end
	end
	return closest;
end

lib.closestValSortedTable = function(t, value)		-- TODO
	local final_v;
	for _,v in pairs(t) do
		if v - value > 0 then
			return v;
		end
		final_v = v;
	end
	
	return final_v;
end

lib.formatRegex = function(str)	-- even though it's not actually regex...
	local magicChars = {"%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$"};
	for i,v in pairs(magicChars) do
		str = str:gsub("%"..v, "%%%"..v);
	end
	return str;
end


lib.find = function(node, str)	-- ex: find(model, "string 1.end")
	local pattern = "^(.-) ?%%.*$";
	local path = str:split(".");
	
	for _,v in pairs(node:GetChildren()) do
		if v.Name:match(pattern) == path[1]  or  v.Name == path[1] then
			if #path == 1 then
				return v;
			else
				
				return lib.find(v, str:match("^[^%.]*%.(.*)$"))
			end
		end
	end
	
end

lib.findChild = function(node, str)	-- you can have .'s in the name for this one
	local pattern = "^(.-) ?%%.*$";
	
	for _,v in pairs(node:GetChildren()) do
		if v.Name:match(pattern) == str  or  v.Name == str then
			return v;
		end
	end
	
end

lib.name = function(object)
	local pattern = "^(.-) ?%%.*$";
	return object.Name:match(pattern) or object.Name;
end

lib.flag = function(object)
	local pattern = "^.- ?%%(.*)$";
	return object.Name:match(pattern);
end

lib.relativeName = function(model, descendant)
	local pathStr = lib.name(descendant);
	
	local obj = descendant.Parent;
	while obj ~= model.Parent do
		local name = lib.name(obj);
		pathStr = name .. "." .. pathStr; 
		
		obj = obj.Parent;
	end
	
	return pathStr;
end

lib.relativeNameDesc = function(model, descendant) -- same thing, but without the model name
	local pathStr = lib.name(descendant);
	
	local obj = descendant.Parent;
	while obj ~= model do
		local name = lib.name(obj);
		pathStr = name .. "." .. pathStr; 
		
		obj = obj.Parent;
	end
	
	return pathStr;
end

lib.hasFlag = function(object, flag)
	return object.Name:match("^.- ?%%".. flag);
end

lib.ancestorHasFlag = function(object, flag)
	local p = object.parent;
	local hasFlag = false;
	while (p ~= nil) do
		if p.Name:match("^.- ?%%".. flag) then
			hasFlag = true;
			break;
		end
		p = p.Parent;
	end
	return hasFlag;
end



lib.tfInvert = function(tf)
	return function(x) return 1-tf(1-x); end;
end

lib.tfFromSmoothness = function(R) -- https://www.desmos.com/calculator/govaknkfch
	-- R is a ratio. 0% is a linear tf, 100% is a quadratic tf
	-- Going past 100% is also allowed, R = 200% is the first case with infinite initial velocity
	if R == 0 then
		return function(x)  return x;  end;
	elseif R == 2 then
		return function(x)  return x * (1-math.log(x));  end;
	end
	local N = 2/R - 1;
	return function(x)
		return x/N * (N+1 - x^N);
	end;
end

lib.tfStartEnd = function(tf) -- given end (https://www.desmos.com/calculator/86icvjhinl)
	return function (x)
		local s = math.sign(x - 0.5);
		return 0.5 + 0.5*s*tf(s*(2*x-1));
	end;
end

lib.tfFromSlopes = function(m0, m1, k_)	-- define a transition function from a slope at 0 and a slope at 1
	
	--return function(x) return (-2+m0+m1)*x^3 + (3-2*m0-m1)*x^2 + m0*x; end	 first attempt: lxlt6vyytq
	
	local k = k_ or 0.1;
	local m = (1-k*(m0+m1)) / (1-2*k)
	return function(x)	-- https://www.desmos.com/calculator/o5yejr5ts6
		if x <= 2*k then
			return (m-m0)/(4*k)*x^2 + m0*x;
		elseif x >= 1-2*k then
			return (m1-m)/(4*k)*(x-1)^2 + m1*(x-1) + 1;
		end;
		return m*(x-k) + k*m0;
	end;
end

lib.transitionFunctions = {
	["linear"] = function(x)
		return x;
	end ,

	["hold"] = function(x)
		return 0;
	end ,

	-- previously sine was used for ease-start and ease-end,
	-- which has a smoothness of ~75% https://www.desmos.com/calculator/luyiahbbgf
	["ease-end"] = lib.tfFromSmoothness(0.75) ,
	["ease-start"] = lib.tfInvert(lib.tfFromSmoothness(0.75)) ,

	["ease-start-end"] = lib.tfStartEnd(lib.tfFromSmoothness(0.75)) ,
};

setmetatable(lib.transitionFunctions, {
	__index = function(self, name)
		if name == nil then return; end;
		local numEnd      = name:match("^ease%-end%-(%d+)$");
		local numStart    = name:match("^ease%-start%-(%d+)$");
		local numStartEnd = name:match("^ease%-start%-end%-(%d+)$");

		if numEnd then
			self[name] = lib.tfFromSmoothness(numEnd/100);
		elseif numStart then
			self[name] = lib.tfInvert(lib.tfFromSmoothness(numStart/100));
		elseif numStartEnd then
			self[name] = lib.tfStartEnd(lib.tfFromSmoothness(numStartEnd/100));
		end

		if numEnd or numStart or numStartEnd then
			return self[name];
		end
	end
});



local fps = workspace.switches.AnimatedFPS.Value
lib.frameToMillis = function(frame)
	return (frame-1)*1000 / fps;
end

lib.millisToFrame = function(T)
	return math.floor(fps*T / 1000) + 1;
end

lib.frameToTimecode = function(frame)
	local hours,minutes,seconds,frames =
		(frame-1)/(3600*fps) % 24 ,
		(frame-1)/(60*fps)	 % 60 ,
		(frame-1)/fps		 % 60 ,
		(frame-1)			 % fps;
	return string.format("%.2i:%.2i:%.2i:%.2i", hours,minutes,seconds,frames);
end

return lib;