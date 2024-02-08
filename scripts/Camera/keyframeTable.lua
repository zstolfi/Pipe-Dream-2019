local keyframes = {};

local folder = script.Parent.keyframes;

keyframes.update = function()
	for i = 1, #keyframes do
		keyframes[i] = nil;
	end
	for _,objVal in pairs(folder:GetChildren()) do
		local index = tonumber(objVal.Name:match("%d+$"));

		keyframes[index] = {
			--		transition defaults to linear
			--	{time = <millis>,	CFrame = <CFrame>,	fov = <num>, spline = T/F,	transition = "linear"} etc.
			
			time       = objVal:GetAttribute("time") ,
			CFrame     = objVal.Value ,
			fov        = objVal:GetAttribute("fov") ,
			spline     = objVal:GetAttribute("spline") ,
			splineAxis = objVal:GetAttribute("splineAxis") ,
			transition = objVal:GetAttribute("transition") ,

			roll     = objVal:GetAttribute("roll") , -- in degrees
			rollLock = objVal:GetAttribute("rollLock")
		};
	end
end

keyframes.lastIndex = function(millis)
	for i = 1, #keyframes do -- they're in order
		if keyframes[i].time - millis > 0 then
			return math.max(1, i-1);
			
		elseif i == #keyframes then
			return i;
		end
	end
	return 1
end

keyframes.update();
return keyframes;