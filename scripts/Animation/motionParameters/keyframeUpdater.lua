lib = require(workspace.lib);
map = lib.map;

local folder = script.Parent;
local keyframes = require(folder.keyframes)

local transitionFunctions = lib.transitionFunctions;
	--["linear"]
	
	--["ease-start-end"]
	
	--["ease-start"]
	
	--["ease-end"]
	
	--["hold"]

local keyframeUpdater = function(T)	-- time in milliseconds
	
	for name,v in pairs(keyframes) do
		local setValue;
		
		if #v > 0 then
			if T <= v[1].time then
				setValue = v[1].value;
			elseif T >= v[#v].time then
				setValue = v[#v].value;
			else
				
				local from, to;
				for i = 1, #v-1 do
					if v[i+1].time > T then
						from,to = v[i], v[i+1];
						break;
					end
				end
				
				local tf = transitionFunctions[from.transition] or transitionFunctions["ease-start-end"];
				
				setValue = map(
					tf(map(T, from.time, to.time, 0,1)),
					0,1, from.value, to.value
				);
			end
			
			folder[name].Value = setValue;
		end
	end
end

return keyframeUpdater;
