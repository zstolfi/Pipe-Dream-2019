-- data of the instruments

Class = require(workspace.Class);
lib = require(workspace.lib);

local enums = require(script.Enums);
--local randseed = 0;
outOfBounds,overfit,underfit = enums.outOfBounds, enums.overfit, enums.underfit;
local instProps;

function defineProps()
	instProps = {
		-- order: { overfit  ,  underfit  ,  outOfBounds }
		
		["Banjo 1"] = Instrument:New(4, {underfit.SPREAD, overfit.CONDENSE, outOfBounds.NEAREST}) ,
		
		["Guitar 1"] = Instrument:New(12, {underfit.CHROMATIC + underfit.MIDDLE, overfit.CONDENSE, outOfBounds.RANDOM_CLOSE}) ,
		
		["Tubular Bells"] = Instrument:New(10, {--[[underfit.CHROMATIC + underfit.MIDDLE, overfit.CONDENSE, outOfBounds.RANDOM_SIDE]]}) ,
		
		["Vibraphone"] = Instrument:New(40, {underfit.CHROMATIC + underfit.BOTTOM, overfit.CONDENSE, outOfBounds.NEAREST}) ,
	};
end

-- make a class called Instrument
Instrument = Class:Extend({
	ClassName = "Instrument" ,
	
	noteSlots = 0 ,
	
	definedNotes = {} , -- noteTable, but only the notes defined by the Midi (max = noteSlots)
	noteTable = {} ,
	
	behaviour = {  -- defaults
		underfit    = underfit.SPREAD + underfit.BOTTOM,
		overfit     = overfit.CONDENSE ,
		outOfBounds = outOfBounds.ROUND + outOfBounds.CLAMP,
	} ,
	
	initialized = false ,
	init = function(self, usedNotes, importInfo)
		if self.initialized then return; end
		
		local len = lib.tableLen(usedNotes);
		
		--[[ OVERFITTING CASE ]]--
		if len > self.noteSlots then
			local behaviour = self.behaviour.overfit;
			
			local behave1 = behaviour % 10;
			local behave2 = 10*math.floor(behaviour/10);
			local behave3 = 100*math.floor(behaviour/100);
				
			if behave1 == outOfBounds.ERROR then
				error("Note overfitting in instrument: ".. self.name);
			elseif behave3 == outOfBounds.WARN then
				error("Warning: Note overfitting in instrument: ".. self.name);
			end
			
			local noteValues = lib.tableFromIndexes(usedNotes); table.sort(noteValues);
			for i = 1, self.noteSlots do
				if behave1 == overfit.BOTTOM then
					self.definedNotes[noteValues[i]] = i;
					
				elseif behave1 == overfit.MIDDLE then
					local offset = math.round(#noteValues/2 - self.noteSlots/2);
					self.definedNotes[noteValues[i + offset]] = i;
					
				elseif behave1 == overfit.TOP then
					local offset = #noteValues - self.noteSlots; 
					self.definedNotes[noteValues[i + offset]] = i;
					
				elseif behave1 == overfit.CONDENSE then -- https://www.desmos.com/calculator/x5mbbcrrv4
					local m = (#noteValues-1) / (self.noteSlots-1);
					local newIndex = math.round(m*(i-1) + 1);
					self.definedNotes[noteValues[newIndex]] = i;
					
				end
			end
			
		-- just right :)
		elseif len == self.noteSlots then
			
			local noteValues = lib.tableFromIndexes(usedNotes);
			table.sort(noteValues);
			for i,v in pairs(noteValues) do
				self.definedNotes[v] = i;
			end
			
		--[[ UNDERFITTING CASE ]]--	
		else
			local behaviour = self.behaviour.underfit;
			
			local behave1 = behaviour % 10;
			local behave2 = 10*math.floor(behaviour/10);
			local behave3 = 100*math.floor(behaviour/100);
				
			if behave1 == outOfBounds.ERROR then
				error("Note overfitting in instrument: ".. self.name);
			elseif behave3 == outOfBounds.WARN then
				error("Warning: Note underfitting in instrument: ".. self.name);
			end
			
			local noteValues = lib.tableFromIndexes(usedNotes); table.sort(noteValues);
			local width = noteValues[#noteValues] - noteValues[1] + 1;
			
			for i,pitch in pairs(noteValues) do
				if behave2 == underfit.PACK then
					local offset = 0;
					if behave1 == underfit.BOTTOM then
						offset = 0;
					elseif behave1 == underfit.MIDDLE then
						offset = math.round(self.noteSlots/2 - #noteValues/2);
					elseif behave1 == underfit.TOP then
						offset = self.noteSlots - #noteValues;
					end
					
					self.definedNotes[pitch] = i + offset;
					
				elseif behave2 == underfit.SPREAD then
					local m = (self.noteSlots-1) / (#noteValues-1);
					self.definedNotes[pitch] = math.round(m*(i-1) + 1);
					
				elseif behave2 == underfit.CHROMATIC then
					--local width = noteValues[#noteValues] - noteValues[1] + 1;
					if width <= self.noteSlots then
						local offset = -noteValues[1] + 1;
						if behave1 == underfit.BOTTOM or width == self.noteSlots then
							offset += 0;
						elseif behave1 == underfit.MIDDLE then
							offset += math.round(#noteValues/2 - width/2);
						elseif behave1 == underfit.TOP then
							offset += #noteValues - width;
						end
						
						self.definedNotes[pitch] = pitch + offset;
						
					else -- width > self.noteSlots
						-- (excecuted below)
					end
				end
			end
			
			if behave2 == underfit.CHROMATIC and width > self.noteSlots then -- https://i.imgur.com/PRB5O5h.png
				local gaps = {};
				for i = 2, width do
					local j = i + noteValues[1] - 1;
					if not usedNotes[j] and usedNotes[j-1] then
						gaps[#gaps+1] = {i,1};
					elseif not usedNotes[j] then
						gaps[#gaps][2] += 1;
					end
				end
				
				table.sort(gaps, function(a,b) return a[2] > b[2] end);
				local numGapsToRemove = width - self.noteSlots;
				do local i, offset = 0, 0; while i <= numGapsToRemove -1 do
					local iMod = (i + offset) % #gaps + 1;
					if gaps[iMod][2] >= 1 then
						gaps[iMod][2] -= 1;  -- decrease this gaps size...
						for j in pairs(gaps) do
							if gaps[j][1] > gaps[iMod][1] then
								gaps[j][1] -= 1; -- and shift every gap start after by -1
						end end
						
					else -- if that gap is 0, skip it and don't increase `i`
						offset += 1;
						continue;
					end
					
					i += 1;
				end end
				
				local pointer = 1;
				for _,pitch in pairs(noteValues) do -- assume this is going in index order
					local currentGap = nil;
					for _,gap in pairs(gaps) do
						if gap[1] == pointer then  currentGap = gap; break;  end
					end
					
					if currentGap and currentGap[2] > 0 then
						pointer += currentGap[2];
					end
					
					self.definedNotes[pitch] = pointer;
					pointer += 1;
				end
			end
		end
		
		for i,v in pairs(self.definedNotes) do
			self.noteTable[i] = v;
		end
		self.initialized = true;
	end ,
	
	New = function(self, slots, initOptions, notes)
		local obj = {};
		setmetatable(obj, self);
		self.__index = self;
		Instrument:_initTables(obj);

		obj.noteSlots = slots;
		
		obj.behaviour.underfit    = initOptions[1] or obj.behaviour.underfit;
		obj.behaviour.overfit     = initOptions[2] or obj.behaviour.overfit;
		obj.behaviour.outOfBounds = initOptions[3] or obj.behaviour.outOfBounds;
		
		if notes then
			for i,v in pairs(notes) do
				obj.noteTable[i] = v;
			end
		end
		
		--[[ OUT OF BOUNDS CASE ]]--
		setmetatable(obj.noteTable, {
			__index = function(noteTable, pitch)
				-- metatable called when the note is not found in `definedNotes`
				
				local newPitch = nil; -- really wish I could use a switch case :(
				local behaviour = obj.behaviour.outOfBounds;
				local pitchList = lib.tableFromIndexes(obj.definedNotes); table.sort(pitchList);
				local p_min,p_max = pitchList[1], pitchList[#pitchList];
				
				local behave1 = behaviour % 10;
				local behave2 = 10*math.floor(behaviour/10);
				local behave3 = 100*math.floor(behaviour/100);
				if behave2 <= outOfBounds.CLAMP then
					pitch = math.clamp(pitch, p_min, p_max);
				elseif behave2 == outOfBounds.LOOP then
					-- https://www.desmos.com/calculator/zelpjc8std
					pitch = (pitch - p_min) % (p_max - p_min + 1) + p_min;
				end
				
				if behave1 == outOfBounds.ERROR then
					error("Note value ".. pitch .." out of bounds! In instrument: ".. obj.name);
				elseif behave3 == outOfBounds.WARN then
					warn("Warning: Note value ".. pitch .." out of bounds! In instrument: ".. obj.name);
				end
					
				if behave1 == outOfBounds.FLOOR then
					newPitch = lib.tableFloorValue(pitchList, pitch);
					
				elseif behave1 == outOfBounds.ROUND then
					newPitch = lib.tableRoundValue(pitchList, pitch);
					
				elseif behave1 == outOfBounds.CEIL then
					newPitch = lib.tableCeilValue(pitchList, pitch);
					
				elseif behave1 == outOfBounds.RANDOM then
					local random = math.random(obj.noteSlots);
					newPitch = pitchList[random];
					
				elseif behave1 == outOfBounds.RANDOM_SIDES then
					local _, baseIndex = lib.tableRoundValue(pitchList, pitch);
					
					local newIndex;
					if baseIndex <= 1 then
						newIndex = baseIndex + 1;
						
					elseif baseIndex >= obj.noteSlots then
						newIndex = baseIndex - 1;
						
					else -- normal case
						newIndex = baseIndex + ({-1, 1})[math.random(2)];
					end
					
					newPitch = pitchList[newIndex];
					
				elseif behave1 == outOfBounds.RANDOM_CLOSE then
					local _ , baseIndex = lib.tableRoundValue(pitchList, pitch);
					
					local newIndex;
					if baseIndex <= 1 then
						newIndex = baseIndex + math.random( 0,1);
						
					elseif baseIndex >= obj.noteSlots then
						newIndex = baseIndex + math.random(-1,0);
						
					else -- normal case
						newIndex = baseIndex + math.random(-1,1);
					end
					
					newPitch = pitchList[newIndex];
				end
				
				local index = obj.definedNotes[newPitch];
				obj.noteTable[pitch] = index;
				return index;
			end
		});
		
		return obj;
	end
});

defineProps(); -- I made this a function just so the properties would be
               -- at the start of the script, you'd have to scroll all the
               -- way down otherwise, lmao

for name,inst in pairs(instProps) do  inst.name = name;  end

return instProps;