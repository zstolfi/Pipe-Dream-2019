local classList = {};

Class = {					-- CLASS STRUCTURE --
	name = nil ,
	fullClassName = "Class" ,
	className = "Class" ,

	_initTables = function(self, obj)
		for i,v in pairs(self) do
			if type(v) == "table" then
				obj[i] = {};	-- duplicate the table!
				for key,val in pairs(self[i]) do
					obj[i][key] = val;
				end
			end
		end
	end ,
	
	New = function(self, name)
		local obj = {};
		setmetatable(obj, self);
		
		obj.name = name or "";
		return obj;
	end ,
	
	Extend = function(self, obj)
		setmetatable(obj, self);
		self.__index = self;
		
		obj.fullClassName = self.fullClassName ..".".. obj.className;
		classList[obj.className] = obj;
		
		obj.super = self;
		
		return obj;
	end ,
	
	IsA = function(self, className)
		return ("."..self.fullClassName.."."):match("%."..className.."%.") ~= nil;
	end
	
	-- eventually I will have something here that allows you to iterate through
	-- the properties properly, pairs() doesn't work...
}

return Class;