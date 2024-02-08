										-----------------------------------------------
										-- http://somascape.org/midi/tech/mfile.html --
										-----------------------------------------------
local midiLib = require(script.midiLib);
local midiImporter = require(script["B64 Decoder"]);

local nameToMidi = midiLib.nameToMidi;
local midiToName = midiLib.midiToName;
local binary = midiLib.binary;
local variableLength = midiLib.variableLength;

local events;


Class = require(workspace.Class);

	MidiChunk = Class:Extend({
		className = "MidiChunk" ,
		
		type = "" ,
		length = nil ,
		data = nil
	})
		HeaderChunk = MidiChunk:Extend({
			className = "HeaderChunk" ,
			
			type = "MThd" ,
			length = 6 ,
		})
		TrackChunk = MidiChunk:Extend({
			className = "TrackChunk" ,
			
			type = "MTrk" ,
			events = {} ,	-- event table
			
			New = function(self)
				local obj = {};
				setmetatable(obj, self);
				self.__index = self;
				
				obj.events = {};
				return obj;
			end
		})
		
	HeaderData = Class:Extend({
		className = "HeaderData" ,
		
		format = nil ,
		tracks = nil ,
		midiDivision = {
			divisionType = nil ,
			fps = nil ,
			delta = nil ,
		}
	})
	Event = Class:Extend({
		className = "Event" ,
		
		deltaTime = nil ,
		data = {}
	})

	events = {
		
		-- look for the status byte, if that's not there, look for
		-- the SCbyte, if that's not there look for SCbtye*256 plus
		-- the next byte, if that's not there, look for the status
		-- byte *4096 plus the next byte
		
		[0x8] = {name = "note off",		len = 3} ,	-- length including the status byte
		[0x9] = {name = "note on",		len = 3} ,
		[0xA] = {name = "key pressure", len = 3} ,
		[0xC] = {name = "prog change",	len = 2} ,
		[0xD] = {name = "chnl press",	len = 2} ,
		[0xE] = {name = "pitch bend",	len = 3} ,
		
		[0xF0] = {name = "sysEx",		len = "l"} ,	-- i f it's "l" then manualy look for varLen data
		[0xF7] = {name = "escape",		len = "l"} ,
		
		[0xB000] = {name = "bank select",		len = 3} ,	-- https://www.midi.org/specifications-old/item/table-3-control-change-messages-data-bytes-2
		[0xB001] = {name = "modulation wheel",	len = 3} ,
		[0xB007] = {name = "channel volume",	len = 3} ,
		[0xB00A] = {name = "pan",				len = 3} ,
		[0xB040] = {name = "damper pedal",		len = 3} ,
		[0xB05B] = {name = "reverb",			len = 3} ,
		[0xB05D] = {name = "chorus",			len = 3} ,
		[0xB078] = {name = "all sound off",		len = 3} ,
		[0xB079] = {name = "reset all conts",	len = 3} ,
		[0xB07A] = {name = "local control",		len = 3} ,
		[0xB07B] = {name = "all notes off",		len = 3} ,
		[0xB07C] = {name = "omni mode on",		len = 3} ,
		[0xB07D] = {name = "omni mode off",		len = 3} ,
		[0xB07E] = {name = "mono mode on",		len = 3} ,
		[0xB07F] = {name = "poly mode on",		len = 3} ,
		
		[0xFF00] = {name = "sequence number",	len = "l"} ,	-- http://somascape.org/midi/tech/mfile.html
		[0xFF01] = {name = "text",				len = "l"} ,
		[0xFF02] = {name = "copyright",			len = "l"} ,
		[0xFF03] = {name = "track name",		len = "l"} ,
		[0xFF04] = {name = "instrument name",	len = "l"} ,
		[0xFF05] = {name = "lyric",				len = "l"} ,
		[0xFF06] = {name = "marker",			len = "l"} ,
		[0xFF07] = {name = "cue point",			len = "l"} ,
		[0xFF08] = {name = "program name",		len = "l"} ,
		[0xFF09] = {name = "device name",		len = "l"} ,
		[0xFF20] = {name = "channel prefix",	len = "l"} ,
		[0xFF21] = {name = "port number",		len = "l"} ,
		[0xFF2F] = {name = "end of track",		len = "l"} ,
		[0xFF51] = {name = "tempo",				len = "l"} ,
		[0xFF54] = {name = "SMPTE offset",		len = "l"} ,
		[0xFF58] = {name = "time signature",	len = "l"} ,
		[0xFF59] = {name = "key signature",		len = "l"} ,
		[0xFF7F] = {name = "sequencer event",	len = "l"}
		
	}
	
	
	
	MidiSong = Class:Extend({					-- MIDISONG OBJECT --
		className = "MidiSong";
		
		binary = {} ,
		header = nil ,
		tracks = {} ,
		
		New = function(self, bin)
			local obj = Class:New("MidiSong");
			setmetatable(obj, self);
			self.__index = self;
			
			self.tracks = {};
			
														-- THE CODE THAT READS MIDI DATA --
			local p = 1;	-- the pointer
			if bin:sub(1,4) ~= "MThd" then			-- HEADER --
				error("file provided is not MIDI");
			end
			p = 5;
			
			obj.header = HeaderChunk:New();
			p = 9;
			
			local hData = HeaderData:New();
			local hFormN = binary(bin:sub(9,10));
			hData.format = hFormN;
			p = 11;
			
			local tracksN = binary(bin:sub(11,12));
			hData.tracks = tracksN;
			p = 13;
			
			local mDiv = {};
			local divN = binary(bin:sub(13));
			local divType = (divN >= 128) and 1 or 0;
			mDiv.divisionType = divType;
			
			if divType == 0 then	-- ticks per quarter note
				mDiv.delta = binary(bin:sub(13,14));
			else	-- SMPTE
				local fpsByte = binary(bin:sub(13,13));
				mDiv.fps = fpsByte - 256;
				mDiv.delta = binary(bin:sub(14,14));
			end
			
			hData.midiDivision = mDiv;
			obj.header.data = hData;
			p = 15;
			
			
			local function autoVarLen(pos)
				local deltaBytes = "";
				
				while bin:byte(pos,pos) > 128 do
					deltaBytes = deltaBytes .. bin:sub(pos,pos);
					pos = pos+1;
				end
				deltaBytes = deltaBytes .. bin:sub(pos,pos);
				pos = pos+1;
				
				return pos, variableLength(deltaBytes);
			end
			
			while bin:sub(p,p+3) == "MTrk" do						-- TRACK --
				
				p = p+4;
				
				local trk = TrackChunk:New();
				
				local tLen = binary(bin:sub(p,p+3));
				p = p+4;
				
				local endP = p+tLen;
				
				local lastSC;	-- http://midi.teragonaudio.com/tech/midispec/run.htm
				trk.length = 0;
				
				while p < endP do
					local e = Event:New();
					local deltaT;
					
					p, deltaT = autoVarLen(p);
					
					e.deltaTime = deltaT;
					
					local SCbyte = bin:byte(p,p);
					local status = math.floor(SCbyte/16);
					
					local channel = SCbyte - 16*status;
					local nextByte = bin:byte(p+1,p+1);
					
					if SCbyte >=128 then
						lastSC = SCbyte;
					else
						status = math.floor(lastSC/16);
						channel = lastSC - 16*status;
						p = p-1;	-- pretend we're currently on a SCbyte
					end
					
					local ev = events[status] or
						events[SCbyte] or
						events[SCbyte*256 + nextByte] or
						events[status*4096 + nextByte] or
						{name = string.format("0x%4.4X",SCbyte*256 + nextByte)}
					;
					
					if ev.len == nil then
						if status == 0xB then
							ev.len = 3;
						else
							ev.len = "l";
						end
					end
					
					local dataLen;
					
					if ev.len ~= "l" then	-- skip the pointer to the data
						p = p+1;
						dataLen = ev.len-1;
					elseif events[SCbyte] then	-- one byte unt il len
						p, dataLen = autoVarLen(p+1);
					else	-- two bytes unt il len
						p, dataLen = autoVarLen(p+2);
					end
					
					local dataTable = {};	-- just an array of numbers from 0-255 for now
					local eventData = {ev.name};
					
					for i = 0, dataLen-1 do
						table.insert(eventData, bin:byte(p+i,p+i));
					end
					table.insert(dataTable, eventData);
					e.channel = channel;
					e.SCbyteN = SCbyte*256 + nextByte;
					
					e.data = dataTable;
					
					trk.length = trk.length+1;
					table.insert(trk.events, e);
					
					p = p+dataLen;
				end
				
				table.insert(obj.tracks, trk);
				
			end
			
			return obj;
		end
	})
			
	
	
	
	mainTable = {
		
		deltaTime = nil ,
--		timeSig = {} ,	-- 4/4 stored as {4,4}
--		tempo = nil ,	-- bpm
		tracks = {} ,
		channels = {} ,
		
		tempoList = {} ,-- each element is {x=<tick it happens on>, y=<bpm>}
		tickToSec  = nil ,
		
		
		setup = function(self, msong)
			
			self.tempoList = {};
			do	-- MIDI tick --> sec (https://www.desmos.com/calculator/omfraxqbc7)
				
				self.tickToSec = function(x)
					local t = self.deltaTime;
					local f = {};
					f[1] = function(x, list)
						return (60/(list[1].y*t))*x;
					end
					local list = self.tempoList;
					
					for i = 2, #list do
						f[i] = function(x, list)
							return (60/(list[i].y*t)) * (x-list[i].x) + f[i-1](list[i].x, list);
						end
					end
					
					for i = 1, #list-1 do
						if list[i].x<=x and x<list[i+1].x then
							return f[i](x, list);
						end
					end
					if x >= list[#list].x then
						return f[#list](x, list);
					end
					
					error("Invaid time of "..x.." ticks.");
				end
				
			end
			
			local header = msong.header.data;
			self.deltaTime = header.midiDivision.delta;
			
			for i = 0, 15 do
				self.channels[i] = MidiChannel:New(i);
			end
			
			for trkNum, trk in pairs(msong.tracks) do
				
				local track = {}
				local index = trkNum;
				
				local counter = 0;
				for i = 1, #trk.events do
					
					local mEvent = trk.events[i];
					local name = mEvent.data[1][1];
					counter = counter + mEvent.deltaTime;
					
					local data = {}; 
					local textData = "";
					local binData = 0;
					for j = 2, #mEvent.data[1] do
						local len = #mEvent.data[1]-1;
						data[j-1] = mEvent.data[1][j];
						textData = textData .. string.char(mEvent.data[1][j]);
						if len <= 4 then
							local exp = -8*((j-1)-len);
							binData = binData + data[j-1]*2^exp;
						end
					end
					
					local event = {};
					event.name = name;
					event.pos = counter;
					
						-- convert midiSong to the mainTable
					
					if name == "track name" then
						track.title = textData:gsub(string.char(0), ""); -- Musescore exports with the null char :(
						--track.title = textData;
					elseif name == "time signature" then
--						self.timeSig[1] = data[1];
--						self.timeSig[2] = 2^data[2];
					elseif name == "tempo" then
--						self.tempo = 60000000/binData;
						local bpm = 60000000/binData;
						local tempoElem = {x=counter, y=bpm};
						table.insert(self.tempoList, tempoElem);
					elseif math.floor(mEvent.SCbyteN/4096) == 0xB then
						Channels[mEvent.channel].action(data[1],data[2]);
						
						
					elseif name == "text" then
						event.data = textData;
						table.insert(track, event);
					elseif name == "note on" or name == "note off" then
						
						data.channel = mEvent.channel;
						data.note = data[1];
						data.velocity = data[2];
						
						if data.velocity == 0 then
							event.name = "note off";
						end
					
						event.data = data;
						table.insert(track, event);
					else
						event.data = data;
						table.insert(track, event);
					end
					
				end
				
				track.pointer = 1;	-- which event to be ran next
				track.done = false;
				self.tracks[index] = track;
				
			end
			
		end
		
	}
	
	MidiChannel = Class:Extend({
		className = "MidiChannel" ,
		
		channelNumber = nil ,
		program = 0 ,
		vol = 64 ,
		pan = 64 ,
		usedNotes = {} ,
		
		New = function(self, num)
			local obj = {};
			setmetatable(obj, self);
			self.__index = self;
			self:_initTables(obj);
			
			obj.channelNumber = num;
			return obj;
		end ,
		
		action = function(self, num, val)	-- https://www.midi.org/specifications-old/item/table-3-control-change-messages-data-bytes-2
			if num == 0x07 then
				self.vol = val;
			elseif num == 0x0A then
				self.pan = val;
			end
		end ,
		
		noteOn = function(self, name, note, vel)
			
		end ,
		
		noteOff = function(self, name, note, vel)
			
		end
	})
	
	Channels = {};
	for i = 0, 15 do
		Channels[i] = MidiChannel:New(i);
	end

setmetatable(mainTable, {
	__call = function(self, arg)
		self.tracks = {};
		self.channels = {};
		
		midiImporter:decode(arg);
		local binary = midiImporter.binary;
		local msong = MidiSong:New(binary);	
		self:setup(msong);
	end
});



return mainTable;