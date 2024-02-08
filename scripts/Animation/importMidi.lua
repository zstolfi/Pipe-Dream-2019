-- this script uses the MIDI Table and puts it into the animationTable
local lib = require(workspace.lib);
local midiLib = require(workspace["MIDI Table"].midiLib);
local instData = require(script.Parent.instrumentProperties);
local animTable = require(script.Parent.animationTable);
local keyframes = require(script.Parent.motionParameters.keyframes);
local defaultInfo = require(script.defaultOptions);

function getModel(instName, pitch, usedNotes, importInfo)
	local percussive = type(midiLib.instModels[instName]) ~= "table";
	
	if not percussive then
		instData[instName]:init(usedNotes, importInfo);
		
		local index = instData[instName].noteTable[pitch]; -- where the magic happens (note assignment)
		return midiLib.instModels[instName][index];
	else
		return midiLib.instModels[instName];
	end
end

local function import(songName, importInfo)
	print("Loading "..tostring(songName).."...");
	local midiTable = require(workspace["MIDI Table"]);
	midiTable(songName);
	
	local tickToSec = midiTable.tickToSec;
	
	-- LOOK THROUGH IMPORTINFO --
	importInfo = importInfo or {};
	for i,v in pairs(importInfo) do
		if lib.tableLen(v) == 0 then  importInfo[i] = nil;  end
	end
	setmetatable(importInfo, {
		__index = function(self, val)
			return defaultInfo[val];
		end
	});
	local usedNotes = {}; -- usedNotes[inst][pitch]
	for _,trk in pairs(midiTable.tracks) do
		if not trk.title then continue; end
		local ID = lib.tableFind(importInfo.track_names, trk.title);
		if ID then
			trk.scriptName = defaultInfo.track_names[ID];
		else
			for i,v in pairs(trackSearchTable) do
				if trk.title:match(i) then trk.scriptName = v; end
			end
		end
		
		usedNotes[trk.title] = {};
		for i = 1, #trk do
			if trk[i].name == "note on" then
				local pitch = trk[i].data.note;
				usedNotes[trk.title][pitch] = true;
		end end
		if trk.scriptName == "Marimba" and importInfo then
			local condensed = lib.removeNils(lib.tableFromIndexes(usedNotes[trk.title]));
			table.sort(condensed);
			importInfo.marimba.note_low  = condensed[1];
			importInfo.marimba.note_high = condensed[#condensed];
		end
	end
	
	
	---- NOTE EVENTS ----
	for _,trk in pairs(midiTable.tracks) do
		if not trk.title then continue; end
		local trackName = trk.scriptName;
		
		for i = 1, #trk do
			local pitch;
			local evTime; 
			
			evTime = tickToSec(trk[i].pos);
			
			if trk[i].name == "note on" then
				local event = trk[i];
				pitch = event.data.note;
				local channel = event.data.channel;
				
				local instName, percussive;
				if trackName ~= "Drumset" and trackName ~= "4-Way Percussion" then
					instName = trackName;
					percussive = false;
				else
					
					instName = lib.tableFind(importInfo.four_way_notes, pitch)
						or lib.tableFind(importInfo.drumset_notes, pitch)
						or midiLib.instTable[9 *256 + pitch]; --9 is the percussion channel!
					--print(instName ~= nil);
					percussive = true;
				end
				
--				print(instName .."\t".. evTime .."\t".. pitch .."\t".. midiLib.midiToName(pitch));
				local model, animId;
				if midiLib.instModels[instName] then
					model = getModel(instName, pitch, usedNotes[trk.title], importInfo);
					if model == nil then  warn("Nil model returned! :\t", instName, pitch);  end
				else
					--warn("No model found! For " ..instName.. " ,\tpitch " .. pitch);
				end
				animId = midiLib.instAnimIds[instName];
				
				if animId then
					table.insert(animTable, {evTime*1000, animId, model, pitch});
				end
			end
		end
	end
	
	
	
	
	---- VIBE KEYFRAMERS ----
	local vibeTrack;
	for _,trk in pairs(midiTable.tracks) do
		if trk.scriptName == "Vibraphone" then
			vibeTrack = trk;
			break;
		end 
	end
	
	if vibeTrack ~= nil    and    not midiLib.skipInst("Vibraphone") then
		local vibeNoteTimes = {};	-- shorter table, to make searching easier
		for i = 1, #vibeTrack do
			local evTime = tickToSec(vibeTrack[i].pos)*1000;
			if vibeTrack[i].name == "note on" then
				table.insert(vibeNoteTimes, evTime);
			end
		end
		
		local vibeTransitions = {
			[1] = {{time = -2838, value = 0},	{time = 0, value = 1}} ,		-- 1: start of song to first note.
			[2] = {{time = 405, value = 1, transition = "ease-in-out-100"},		{time = 5043, value = 0}} ,		-- 2: last note to end of song
			[3] = {{time = 0, value = 1},		{time = 2838, value = 0.25}} ,	-- 3: start mid-song break
			[4] = {{time = -2635, value = 0.25},{time = 0, value = 1}}			-- 4: end of break
		};
		local vibeTransitionTimes = {} -- {time = <millis>, value = <1-4>}
		local vibeKeyframes = {};
		
		if #vibeNoteTimes == 0 then	-- if there are no notes, cover our bases
			vibeKeyframes = {time = 0,	value = 0};
		else
			local firstTime = vibeNoteTimes[1];
			local lastTime = vibeNoteTimes[#vibeNoteTimes];
			
			table.insert(vibeTransitionTimes, {time = firstTime, value = 1});
			table.insert(vibeTransitionTimes, {time = lastTime, value = 2});
			
			for i = 1, #vibeNoteTimes-1 do	-- check through pairs of them
				if vibeNoteTimes[i+1] - vibeNoteTimes[i] > 12972 then	-- 8 measures in milliseconds
					table.insert(vibeTransitionTimes, {time = vibeNoteTimes[i], value = 3});
					table.insert(vibeTransitionTimes, {time = vibeNoteTimes[i+1], value = 4});
				end
			end
			
			table.sort(vibeTransitionTimes,  function(a,b)
				return a.time < b.time;
			end)
			
			for _,v in pairs(vibeTransitionTimes) do
				local transition = vibeTransitions[v.value];
				for i = 1, #transition do
					table.insert(vibeKeyframes, {time = transition[i].time + v.time, value = transition[i].value});
				end
			end
		end
		
		keyframes["vibePosition"] = vibeKeyframes;
	end
	
	
	
	---- BELL KEYFRAMES ---- (this is duplicate code!!!)
	local bellTrack;
	for _,trk in pairs(midiTable.tracks) do
		if trk.scriptName == "Tubular Bells" then
			bellTrack = trk;
			break;
		end 
	end
	
	if bellTrack ~= nil    and    not midiLib.skipInst("Tubular Bells") then
		local bellNoteTimes = {};
		for i = 1, #bellTrack do
			local evTime = tickToSec(bellTrack[i].pos)*1000;
			if bellTrack[i].name == "note on" then
				table.insert(bellNoteTimes, evTime);
			end
		end
		
		local bellTransitions = {
			[1] = {{time = -9600, value = 0},	{time = -720, value = 1}} ,		-- 1: first note
			[2] = {{time = 240, value = 1},		{time = 9600, value = 0}} ,		-- 2: last note
		};
		local bellTransitionTimes = {} -- {time = <millis>, value = <1-2>}
		local bellKeyframes = {};
		
		if #bellNoteTimes == 0 then	-- if there are no notes, cover our bases
			bellKeyframes = {time = 0,	value = 0};
		else
			local firstTime = bellNoteTimes[1];
			local lastTime = bellNoteTimes[#bellNoteTimes];
			
			table.insert(bellTransitionTimes, {time = firstTime, value = 1});
			table.insert(bellTransitionTimes, {time = lastTime, value = 2});
			
			for i = 1, #bellNoteTimes-1 do	-- check through pairs of them
				if bellNoteTimes[i+1] - bellNoteTimes[i] > 25946 then	-- 16 measures in milliseconds
					table.insert(bellTransitionTimes, {time = bellNoteTimes[i], value = 2});
					table.insert(bellTransitionTimes, {time = bellNoteTimes[i+1], value = 1});
				end
			end
			
			table.sort(bellTransitionTimes,  function(a,b)
				return a.time < b.time;
			end)
			
			for _,v in pairs(bellTransitionTimes) do
				local transition = bellTransitions[v.value];
				local tfName = v.value == 1 and "ease-end" or "ease-start";
				for i = 1, #transition do
					table.insert(bellKeyframes, {time = transition[i].time + v.time, value = transition[i].value, transition = tfName});
				end
			end
		end
		
		keyframes["bellPosition"] = bellKeyframes;
	end
	
	
	
	local import4w = importInfo.four_way_notes;
	
	---- HIGH HAT KEYFRAMES ----	https://i.imgur.com/DhNy3KU.png
	local fourWayTrack;
	for _,trk in pairs(midiTable.tracks) do
		if trk.scriptName ~= "4-Way Percussion" --[[and trk.scriptName ~= "Drumset"]] then continue; end
		
		for i = 1, #trk do
			if trk[i].name == "note on" then
				local pitch = trk[i].data.note;
				if lib.tableFind(import4w, pitch) then -- TODO: fix this logic (misbehaves if 4-way notes are found in Drumset)
					fourWayTrack = trk; break;
		end end end
		if fourWayTrack then break; end
	end
	
	if fourWayTrack ~= nil    and    not midiLib.skipInst("4-Way Percussion") then
		local hiHatNoteTimes = {{time=-60000,type="start"}};	-- contains {time  =<time>, type = <note-type>}
									-- note types are: start, O, C, P, end
		for i = 1, #fourWayTrack do
			local event = fourWayTrack[i];
			local evTime = tickToSec(event.pos)*1000;
			if event.name == "note on" then
				local note = event.data.note;
				
				local noteType;
				    if note == import4w["HiHt Cls"] then	-- hat closed
					noteType = "C";
				elseif note == import4w["HiHt Pdl"] then	-- hat pedal
					noteType = "P";
				elseif note == import4w["HiHt Opn"] then	-- hat open
					noteType = "O";
				end
				
				if noteType ~= nil then
					table.insert(hiHatNoteTimes, {time=evTime, type=noteType});
				end
			end
		end
		table.insert(hiHatNoteTimes, {time=1400000, type="end"});	-- 4 hour song limit at 148bpm
		
		local hiHatAnims = {	-- https://i.imgur.com/DhNy3KU.png
			["none"]	= {} ,
			
			["hat-up"]	= {
				{time = -405.4, value = 0, tf = "ease-start-end"} ,
				{time = 0, value = 1}
			} ,
			
			["hat-down"] = {
				{time = -202.7, value = 1, tf = "ease-end"} ,
				{time = 0, value = 0}
			} ,
			
			["hat-pedal"] = {
				{time = -135.1, value = 1, tf = "linear"} ,
				{time = 0, value = 0}
			} ,
			
			["hat-pedal2"] = {
				{time = -304.1, value = 0} ,
				{time = -202.7, value = 0, tf = "ease-start-end"} ,
				{time = -101.4, value = 0.5, tf = "ease-start"} ,
				{time = 0, value = 0}
			} ,
			
			["hat-end"] = {
				{time = 405.4, value = 1, tf = "ease-start-end"} ,
				{time = 1216.2, value = 0}
			}
		};
		
		
		local transitionMatrix = {	-- transitionMatrix[from][to]		https://i.imgur.com/DhNy3KU.png
			["O"]		= {["O"] = "none",			["C"] = "hat-down",		["P"] = "hat-pedal",	["end"] = "hat-end"} ,
			["C"]		= {["O"] = "hat-up",		["C"] = "none",			["P"] = "hat-pedal2",	["end"] = "none"} ,
			["P"]		= {["O"] = "hat-up",		["C"] = "none",			["P"] = "hat-pedal2",	["end"] = "none"} ,
			["start"]	= {["O"] = "hat-up",		["C"] = "none",			["P"] = "hat-pedal2",	["end"] = "none"}
		}
		
		local hiHatKeyframes = {};
		for i = 1, #hiHatNoteTimes-1 do
			local from = hiHatNoteTimes[i];
			local to = hiHatNoteTimes[i+1];
			local animName = transitionMatrix[from.type][to.type];
			
			local anim = hiHatAnims[animName];
			local animDuration;
			local speedMult = 1;
			if animName ~= "none" and animName ~= "hat-end" then
				animDuration = anim[#anim].time - anim[1].time;
				
				if (to.time - from.time) < animDuration then	-- this shortens it!
					speedMult = (to.time - from.time) / (animDuration);
				end
			end
			
			for j = 1, #anim do
				local placement = (to.type ~= "end") and to.time or from.time;
				table.insert(hiHatKeyframes, {time = placement + anim[j].time * speedMult,
					value = anim[j].value,
					transition = anim[j].tf});
			end
			
			
		end
		
		keyframes["hiHatPosition"] = hiHatKeyframes;
	end
	
	
	
	---- 4-WAY PERCUSSION KEYFRAMES ----	similar to the hi-hat, but which inst at what time
	if fourWayTrack ~= nil    and    not midiLib.skipInst("4-Way Percussion") then
		local fourWayNoteTimes = {{time=-60000,type="start"}};	-- {time  =<time>, type = <note-type>}
									-- note types are: start, S,H,C,W, end
		local noteVals = {
			splash		= { import4w["Splash"] } ,
			hiHat		= { import4w["HiHt Cls"] , import4w["HiHt Opn"] } ,
			cowbell		= { import4w["Cowbell"]} ,
			woodBlock	= { import4w["WdBlk Lo"] , import4w["WdBlk Hi"] }
		};
		
		for i = 1, #fourWayTrack do
			local event = fourWayTrack[i];
			local evTime = tickToSec(event.pos)*1000;
			if event.name == "note on" then
				local note = event.data.note;
				
				local noteType;
				if table.find(noteVals.splash, note) then -- Splash
					noteType = "S";
				elseif table.find(noteVals.hiHat, note) then -- Hi-Hat
					noteType = "H";
				elseif table.find(noteVals.cowbell, note) then -- Cowbell
					noteType = "C";
				elseif table.find(noteVals.woodBlock, note) then -- Woodblock
					noteType = "W";
				end
				
				if noteType ~= nil then
					table.insert(fourWayNoteTimes, {time=evTime, type=noteType});
				end
			end
		end
		local lastTime = fourWayNoteTimes[#fourWayNoteTimes].time;
		table.insert(fourWayNoteTimes, {time=lastTime+1000, type="end"});
		
		local TurnAnims = {	-- https://i.imgur.com/DhNy3KU.png
			["none"]	= {} ,
			
			["pos-90"]	= {
				{time = -1000, value = 0, tf = "ease-start-end"} ,
				{time = 0, value = math.pi/2}
			} ,
			
			["neg-90"]	= {
				{time = -1000, value = 0, tf = "ease-start-end"} ,
				{time = 0, value = -math.pi/2}
			} ,
			
			["pos-180"] = {
				{time = -1000, value = 0, tf = "ease-start-end"} ,
				{time = 0, value = math.pi}
			} ,
			
			["neg-180"] = {
				{time = -1000, value = 0, tf = "ease-start-end"} ,
				{time = 0, value = -math.pi}
			}
		};
		
		
		local transitionMatrix = {	-- transitionMatrix[from][to]		https://i.imgur.com/33pUNEq.png
			["S"]		= {["S"] = "none",		["H"] = "neg-90",	["C"] = "pos-180",	["W"] = "pos-90",	["end"] = "none"} ,
			["H"]		= {["S"] = "pos-90",	["H"] = "none",		["C"] = "neg-90",	["W"] = "neg-180",	["end"] = "pos-90"} ,
			["C"]		= {["S"] = "neg-180",	["H"] = "pos-90",	["C"] = "none",		["W"] = "neg-90",	["end"] = "neg-180"} ,
			["W"]		= {["S"] = "neg-90",	["H"] = "pos-180",	["C"] = "pos-90",	["W"] = "none",		["end"] = "neg-90"} ,
			["start"]	= {["S"] = "none",		["H"] = "neg-90",	["C"] = "pos-180",	["W"] = "pos-90",	["end"] = "none"}
		}
		
		local fourWayKeyframes = {};
		for i = 1, #fourWayNoteTimes-1 do
			local from = fourWayNoteTimes[i];
			local to = fourWayNoteTimes[i+1];
			local animName = transitionMatrix[from.type][to.type];
			
			local anim = TurnAnims[animName];
			local animDuration;
			local speedMult = 1;
			if animName ~= "none" then
				animDuration = anim[#anim].time - anim[1].time;
				
				if (to.time - from.time) < animDuration then	-- this shortens it!
					speedMult = (to.time - from.time) / (animDuration);
				end
			end
			
			--print(i, #anim)
			local prevValue = (i > 1) and fourWayKeyframes[#fourWayKeyframes].value or 0;
			
			if #fourWayKeyframes ~= 0 or #anim ~= 0 then
				for j = 1, #anim do
					local placement = to.time
					fourWayKeyframes[#fourWayKeyframes + 1] = {
						time = placement + anim[j].time * speedMult,
						value = prevValue + anim[j].value,
						transition = anim[j].tf};
				end
			else
				local angle;
				if		from.type == "S" then	angle = 0;
				elseif	from.type == "H" then	angle = -math.pi/2;
				elseif	from.type == "C" then	angle = math.pi;
				elseif	from.type == "W" then	angle = math.pi/2;
				else
					angle = 0;
				end
				
				fourWayKeyframes[1] = {time = -60000, value = angle};
			end
			
		end
		
		keyframes["drumRotation"] = fourWayKeyframes;
	end
	
	print("Import successful!");
	if #animTable == 0 then
		warn("Warning: no Animation Events initialized in animTable");
	end
end

trackSearchTable = {
	banjo		=	 defaultInfo.track_names.banjo ,
	guitar		=	 defaultInfo.track_names.guitar ,
	bass		=	 defaultInfo.track_names.guitar ,
	
	bell		= 	defaultInfo.track_names.bells ,
	marimba		= 	defaultInfo.track_names.marimba ,
	mrm			= 	defaultInfo.track_names.marimba ,
	vibraphone	= 	defaultInfo.track_names.vibe ,
	vibe		= 	defaultInfo.track_names.vibe ,
	vib			= 	defaultInfo.track_names.vibe ,
	
	four_way	= 	defaultInfo.track_names.four_way ,
	four		= 	defaultInfo.track_names.four_way ,
	["4"]		= 	defaultInfo.track_names.four_way ,
	drums		= 	defaultInfo.track_names.drums ,
	drum		= 	defaultInfo.track_names.drums ,
};

return import;