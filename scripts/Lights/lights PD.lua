---------------------------------
--[[ PIPE DREAM LIGHTS TRACK ]]--
---------------------------------

local keyframes = {

	-- Lights are manual input --
	["light: banjo"] = {
		{time = 0,		value = 0} ,
		{time = 26000,	value = 0, transition = "ease-start"} ,
		{time = 26700,	value = 1} ,

		{time = 118500,	value = 1, transition = "ease-start"} ,
		{time = 120000,	value = 0.9} ,

		{time = 132500,	value = 0.9, transition = "ease-start"} ,
		{time = 133200,	value = 1} ,

		{time = 198900,	value = 1, transition = "ease-start-end"} ,
		{time = 201000,	value = 0} ,
	} ,

	["light: bass"] = {
		{time = 0,		value = 1} ,

		{time = 118800,	value = 1, transition = "ease-start"} ,
		{time = 120700,	value = 0.1} ,

		{time = 129000,	value = 0.1, transition = "ease-end-50"} ,
		{time = 131900,	value = 1,} ,

		{time = 197500,	value = 1, transition = "ease-start-end"} ,
		{time = 200000,	value = 0} ,
	} ,

	["light: bells"] = {
		{time = 0,		value = 0} ,

		{time = 115000,	value = 0, transition = "ease-start-end"} ,
		{time = 118500,	value = 1} ,

		{time = 132000,	value = 1, transition = "ease-start"} ,
		{time = 134000,	value = 0} ,
	} ,

	["light: marimba"] = {
		{time = 0,		value = 0} ,
		{time = 130000,	value = 0, transition = "ease-start"} ,
		{time = 131200,	value = 1} ,

		{time = 197000,	value = 1, transition = "ease-start-end"} ,
		{time = 198700,	value = 0} ,
	} ,

	["light: vibe"] = {
		{time = 0,		value = 0} ,

		{time = 65000,	value = 0, transition = "ease-start-end"} ,
		{time = 67700,	value = 1,} ,
		
		{time = 119000,	value = 1, transition = "ease-start-end-30"} ,
		{time = 121800,	value = 0,} ,
		
		{time = 154000,	value = 0, transition = "ease-start"} ,
		{time = 156000,	value = 1} ,

		{time = 198900,	value = 1, transition = "ease-start-end"} ,
		{time = 202500,	value = 0} ,
	} ,

	["light: drums"] = {
		{time = 0,		value = 0} ,
		{time = 39500,	value = 0, transition = "ease-start-end"} ,
		{time = 40500,	value = 1} ,

		{time = 117800,	value = 1, transition = "ease-start"} ,
		{time = 120700,	value = 0.1} ,

		{time = 130400,	value = 0.1, transition = "ease-start"} ,
		{time = 131700,	value = 1} ,
		
		{time = 196800,	value = 1, transition = "ease-start-end"} ,
		{time = 198700,	value = 0} ,
	} ,

};

return keyframes;