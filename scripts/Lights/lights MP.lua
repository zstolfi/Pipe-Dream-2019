-------------------------
--[[ MP LIGHTS TRACK ]]--
-------------------------

local keyframes = {

	-- Lights are manual input --
	["light: banjo"] = {
		{time = 19000,	value = 0} ,
		{time = 21000,	value = 1} ,

		{time = 60200,	value = 1, transition = "ease-start"} ,
		{time = 62200,	value = 0.25} ,

		{time = 70700,	value = 0.25, transition = "ease-end-50"} ,
		{time = 73200,	value = 1,} ,

		{time = 92000,	value = 1} ,
		{time = 94000,	value = 0.1} ,

		{time = 116000,	value = 0.1} ,
		{time = 118400,	value = 1} ,

		--{time = 106500,	value = 1, transition = "ease-start-end"} ,
		--{time = 108500,	value = 0.1} ,

		--{time = 116500,	value = 0.1, transition = "ease-end-50"} ,
		--{time = 118000,	value = 1,} ,

		{time = 166500,	value = 1} ,
		{time = 168000,	value = 0} ,
	} ,

	["light: bass"] = {
		{time = 0,		value = 1} ,
		{time = 1200,	value = 1} ,

		{time = 60500,	value = 1, transition = "ease-start"} ,
		{time = 62500,	value = 0.25} ,

		{time = 70500,	value = 0.25, transition = "ease-end-50"} ,
		{time = 73000,	value = 1,} ,

		{time = 100500,	value = 1, transition = "ease-start-end"} ,
		{time = 103500,	value = 0.1} ,

		{time = 116500,	value = 0.1, transition = "ease-end-50"} ,
		{time = 118500,	value = 1,} ,

		{time = 168000,	value = 1} ,
		{time = 172500,	value = 0} ,
	} ,

	["light: bells"] = {
		{time = 101000,	value = 0, transition = "ease-end"} ,
		{time = 105000,	value = 1} ,

		{time = 151000,	value = 1} ,
		{time = 153000,	value = 0} ,
	} ,

	["light: marimba"] = {
		{time = 44000,	value = 0} ,
		{time = 47000,	value = 1} ,

		{time = 92000,	value = 1} ,
		{time = 94000,	value = 0.1} ,

		{time = 102000,	value = 0.1} ,
		{time = 104000,	value = 1} ,

		{time = 166000,	value = 1} ,
		{time = 169000,	value = 0} ,
	} ,

	["light: vibe"] = {
		{time = 30000,	value = 0} ,
		{time = 33000,	value = 1} ,


		{time = 91000,	value = 1} ,
		{time = 95000,	value = 0.1} ,

		{time = 116500,	value = 0.1} ,
		{time = 120000,	value = 1} ,

		{time = 167000,	value = 1} ,
		{time = 170000,	value = 0} ,
	} ,

	["light: drums"] = {
		--{time = 2000,	value = 0, transition = "ease-end-50"} ,
		-- idea: What if the drums stay on the entire song
		{time = 3500,	value = 1} ,

		{time = 60500,	value = 1} ,
		{time = 62500,	value = 0.5} ,

		{time = 70500,	value = 0.5} ,
		{time = 73000,	value = 1,} ,
	} ,

};

return keyframes;