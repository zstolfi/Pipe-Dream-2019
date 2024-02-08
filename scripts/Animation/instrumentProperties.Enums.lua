local enums = {
	outOfBounds = {
		ERROR			= 0 ,	--		[X]
		WARN			= 100 ,	--		[X]
		FLOOR			= 2 ,	--		[X]
		ROUND			= 3 ,	--		[X]
		NEAREST			= 3 ,	--		[X]
		CEIL			= 4 ,	--		[X]
		RANDOM			= 5 ,	--		[X]
		RANDOM_CLOSE	= 6 ,	--		[X]
		RANDOM_SIDES	= 7 ,	--		[X]
		
		CLAMP			= 20 ,	--		[X]
		LOOP			= 30 ,	--		[X]
	};
	
	overfit = {
		ERROR			= 0 ,	--		[X]
		WARN			= 100 ,	--		[X]
		
		-- which ones to define in noteTable
		BOTTOM			= 1 ,	--		[X]
		MIDDLE			= 2 ,	--		[X]
		TOP				= 3 ,	--		[X]
		CONDENSE		= 4 ,	--		[X]
	};
	
	underfit = {
		ERROR			= 0 ,	--		[X]
		WARN			= 100 ,	--		[X]
		SPREAD			= 10 ,	--		[X]
		CHROMATIC		= 20 ,	--		[X]
		PACK			= 30 ,	--		[X]
		
		-- position, if packing
		BOTTOM			= 1 ,	--		[X]
		MIDDLE			= 2 ,	--		[X]
		TOP				= 3 ,	--		[X]
	};
};

return enums;
