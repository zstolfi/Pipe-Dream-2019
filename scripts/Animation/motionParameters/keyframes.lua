local keyframes = {	-- importMidi puts in keyframes here
	
	-- EXAMPLE --
--	["vibePosition"] = {
--		{time = <millis>,	value = 0,	transition = "ease-start-end"} , ...
--	} ,
	
-- Update: as of 6/17/2022 the light's keyframes are
-- auto-assigned from switches.LightsTrack
};

local lightsTrack = if workspace.switches.LightsTrack.Value then require(workspace.switches.LightsTrack.Value) else {};
--setmetatable(keyframes, {
--	__index = lightsTrack
--});
for i,v in pairs(lightsTrack) do
	keyframes[i] = v;
end
--keyframes = lightsTrack;

return keyframes;