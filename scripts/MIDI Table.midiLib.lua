lib = require(workspace.lib);
find = lib.find
local midiLib = {}

midiLib.nameToMidi = function(name)
	local pitches = {
		["Cb"]	=	-1 ,
		["C"]	=	0 ,
		["C#"]	=	1 ,
		["Db"]	=	1 ,
		["D"]	=	2 ,
		["D#"]	=	3 ,
		["Eb"]	=	3 ,
		["E"]	=	4 ,
		["E#"]	=	5 ,
		["Fb"]	=	4 ,
		["F"]	=	5 ,
		["F#"]	=	6 ,
		["Gb"]	=	6 ,
		["G"]	=	7 ,
		["G#"]	=	8 ,
		["Ab"]	=	8 ,
		["A"]	=	9 ,
		["A#"]	=	10 ,
		["Bb"]	=	10 ,
		["B"]	=	11 ,
		["B#"]	=	12
	};
	
	local letter, oct = string.match(name,"([A-G][b#]?)(-?%d+)");
	local letterPitch = pitches[letter];
	
	return (tonumber(oct)+1)*12 + letterPitch;
end

midiLib.midiToName = function(midi)
	local letters = {
		[0]		=	"C"  ,
		[1]		=	"Db" ,
		[2]		=	"D"  ,
		[3]		=	"Eb" ,
		[4]		=	"E"  ,
		[5]		=	"F"  ,
		[6]		=	"Gb" ,
		[7]		=	"G"  ,
		[8]		=	"Ab" ,
		[9]		=	"A"  ,
		[10]	=	"Bb" ,
		[11]	=	"B"
	};
	
	local letter = letters[math.fmod(midi,12)];
	local oct = math.floor(midi/12)-1;
	
	return letter .. oct;
end

midiLib.binary = function(...)
	local bytes = {...};
	if type(bytes[1]) == "string" then
		local newdata = {};
		for i = 1, #bytes[1] do
			newdata[i] = bytes[1]:byte(i,i);
		end
		bytes = newdata;
	end
	local len = #bytes;

	local value = 0;
	
	for i = 1, len do
		local bytei = bytes[i];
		local exp = -8*(i-len);
		value = value + bytei*2^exp;
	end
	
	return value;
end

midiLib.variableLength = function(...)	-- https://www.csie.ntu.edu.tw/~r92092/ref/midi/#vlq
	local bytes = {...};
	if type(bytes[1]) == "string" then
		local newdata = {};
		for i = 1, #bytes[1] do
			newdata[i] = bytes[1]:byte(i,i);
		end
		bytes = newdata;
	end
	local len = #bytes;
	local value = 0;
	
	local bytes2 = {};
	for i = 1, len do
		local bytei = bytes[i];
		local by = bytei -128;	-- remove the MSbits on all of them
		bytes2[i] = by;
	end
	bytes2[len] = bytes[len];	-- except for the last one
	
	for i = 1, len do
		local exp = -7*(i-len);
		value = value + bytes2[i]*2^exp;
	end
	
	return value;
end

local toggleInsts = {};	-- initialize toggleInsts table
for i,v in pairs(workspace.switches["Toggle Instruments"]:GetChildren()) do
	toggleInsts[v.Name] = v.Value;
	if not v.Value then
		print("Note: Instrument animation will be disabled:\t\t" .. v.Name);
	end
end
midiLib.skipInst = function(inst)
	return not toggleInsts[inst];
end

midiLib.skipFromId = function(id)
	local idTable = {
		["^4w"] = "4-Way Percussion" ,
		["^drm"] = "Drumset" ,
		["^marimba"] = "Marimba" ,
		["^stringo"] = "Stringos" ,
		["^bellNote"] = "Tubular Bells" ,
		["^vibeNote"] = "Vibraphone"
	}
	for idPatt,instName in pairs(idTable) do
		if id:match(idPatt)    and    not toggleInsts[instName] then
			return true;
		end
	end
	
	return false;
end

midiLib.instTable = {
	["Banjo 1"]			=	"Bj1." ,
	["Banjo 2"]			=	"Bj2." ,
	[0x093D]			=	"Bng." ,
	["Guitar 1"]		=	"Gt1." ,
	["Guitar 2"]		=	"Gt2." ,
	["Pitched Bongos"]	=	"PBg." ,
	
	["Tubular Bells"]	=	"Bls." ,
	["Marimba"]			=	"Mrm." ,
	["Vibraphone"]		=	"Vib." ,
	
	[0x0923]		=	"Bass Drm" ,
	[0x0924]		=	"Bass Drm" ,
	[0x0926]		=	"Snare" ,
	[0x0928]		=	"Snare" ,
	[0x0931]		=	"Hi Crash" ,
	[0x0939]		=	"Lo Crash" ,
	[0x0932]		=	"High Tom" ,
	[0x0930]		=	"Hi M Tom" ,
	[0x092F]		=	"Lo M Tom" ,
	[0x092D]		=	"Low Tom" ,
	[0x092B]		=	"Hi F Tom" ,
	[0x0929]		=	"Lo F Tom" ,
	
	[0x0938]		=	"Cowbell" ,
	[0x092A]		=	"HiHt Cls" ,
	[0x092C]		=	"HiHt Pdl" ,
	[0x092E]		=	"HiHt Opn" ,
	[0x0937]		=	"Splash" ,
	[0x094C]		=	"WdBlk Hi" ,
	[0x094D]		=	"WdBlk Lo" ,
}

midiLib.instModels = {
	["Banjo 1"]	= {
		workspace.Stringos["Banjo 1"] ,
		workspace.Stringos["Banjo 2"] ,
		workspace.Stringos["Banjo 3"] ,
		workspace.Stringos["Banjo 4"]
	} ,
	
	["Guitar 1"] = {
		workspace.Stringos["Bass 1"] ,
		workspace.Stringos["Bass 2"] ,
		workspace.Stringos["Bass 3"] ,
		
		workspace.Stringos["Bass 4"] ,
		workspace.Stringos["Bass 5"] ,
		workspace.Stringos["Bass 6"] ,
		workspace.Stringos["Bass 7"] ,
		workspace.Stringos["Bass 8"] ,
		
		workspace.Stringos["Bass 9"] ,
		workspace.Stringos["Bass 10"] ,
		workspace.Stringos["Bass 11"] ,
		workspace.Stringos["Bass 12"]
	} ,
	
	["Vibraphone"] = {
		workspace.Vibraphone.arms["arm 0"] ,
		workspace.Vibraphone.arms["arm 1"] ,
		workspace.Vibraphone.arms["arm 2"] ,
		workspace.Vibraphone.arms["arm 3"] ,
		workspace.Vibraphone.arms["arm 4"] ,
		workspace.Vibraphone.arms["arm 5"] ,
		workspace.Vibraphone.arms["arm 6"] ,
		workspace.Vibraphone.arms["arm 7"] ,
		workspace.Vibraphone.arms["arm 8"] ,
		workspace.Vibraphone.arms["arm 9"] ,
		
		workspace.Vibraphone.arms["arm 10"] ,
		workspace.Vibraphone.arms["arm 11"] ,
		workspace.Vibraphone.arms["arm 12"] ,
		workspace.Vibraphone.arms["arm 13"] ,
		workspace.Vibraphone.arms["arm 14"] ,
		workspace.Vibraphone.arms["arm 15"] ,
		workspace.Vibraphone.arms["arm 16"] ,
		workspace.Vibraphone.arms["arm 17"] ,
		workspace.Vibraphone.arms["arm 18"] ,
		workspace.Vibraphone.arms["arm 19"] ,
		workspace.Vibraphone.arms["arm 20"] ,
		workspace.Vibraphone.arms["arm 21"] ,
		
		workspace.Vibraphone.arms["arm 22"] ,
		workspace.Vibraphone.arms["arm 23"] ,
		workspace.Vibraphone.arms["arm 24"] ,
		workspace.Vibraphone.arms["arm 25"] ,
		workspace.Vibraphone.arms["arm 26"] ,
		workspace.Vibraphone.arms["arm 27"] ,
		workspace.Vibraphone.arms["arm 28"] ,
		workspace.Vibraphone.arms["arm 29"] ,
		workspace.Vibraphone.arms["arm 30"] ,
		workspace.Vibraphone.arms["arm 31"] ,
		workspace.Vibraphone.arms["arm 32"] ,
		
		workspace.Vibraphone.arms["arm 33"] ,
		workspace.Vibraphone.arms["arm 34"] ,
		workspace.Vibraphone.arms["arm 35"] ,
		workspace.Vibraphone.arms["arm 36"] ,
		workspace.Vibraphone.arms["arm 37"] ,
		workspace.Vibraphone.arms["arm 38"] ,
		workspace.Vibraphone.arms["arm 39"]
	} ,
	
	["Tubular Bells"] = {
		workspace.Bells.arms["arm 10"] ,
		workspace.Bells.arms["arm 9"] ,
		workspace.Bells.arms["arm 8"] ,
		workspace.Bells.arms["arm 7"] ,
		workspace.Bells.arms["arm 6"] ,
		workspace.Bells.arms["arm 5"] ,
		workspace.Bells.arms["arm 4"] ,
		workspace.Bells.arms["arm 3"] ,
		workspace.Bells.arms["arm 2"] ,
		workspace.Bells.arms["arm 1"]
	} ,
	
	["Splash"] = find(workspace.Drums["4-Way"],"rotating.Splash") ,
	["Cowbell"] = find(workspace.Drums["4-Way"],"rotating.Cowbell") ,
	["HiHt Cls"] = find(workspace.Drums["4-Way"],"rotating.Hi Hat") ,
	["HiHt Opn"] = find(workspace.Drums["4-Way"],"rotating.Hi Hat") ,
	["WdBlk Hi"] = find(workspace.Drums["4-Way"],"rotating.Wood Blocks") ,
	["WdBlk Lo"] = find(workspace.Drums["4-Way"],"rotating.Wood Blocks") ,
	

	["Bass Drm"]	= workspace.Drums.Bass ,
	["Snare"]		= workspace.Drums.Snare ,
	["Lo F Tom"]	= workspace.Drums["Low Floor Tom"] ,
	["Hi F Tom"]	= workspace.Drums["High Floor Tom"] ,
	["Low Tom"]		= workspace.Drums["Low Tom"] ,
	["Lo M Tom"]	= workspace.Drums["Low-Mid Tom"] ,
	["Hi M Tom"]	= workspace.Drums["Hi-Mid Tom"] ,
	["High Tom"]	= workspace.Drums["High Tom"] ,
	["Hi Crash"]	= workspace.Drums["Crash 1"] ,
	["Lo Crash"]	= workspace.Drums["Crash 2"]
	
}

midiLib.instAnimIds = {
	["Banjo 1"]			=	"stringo" ,
	["Guitar 1"]		=	"stringo" ,
	["Vibraphone"]		=	"vibeNote" ,
	["Marimba"]			=	"marimba" ,
	["Tubular Bells"]	=	"bellNote" ,
	
	["Splash"]			=	"4w.splash" ,
	["Cowbell"]			=	"4w.cowbell" ,
	["HiHt Cls"]		=	"4w.hiHat.closed" ,
	["HiHt Opn"]		=	"4w.hiHat.open" ,
	["WdBlk Hi"]		=	"4w.woodBlock.high" ,
	["WdBlk Lo"]		=	"4w.woodBlock.low" ,
	
	["Bass Drm"]		=	"drm.bass" ,
	["Snare"]			=	"drm.snare" ,
	["Lo F Tom"]		=	"drm.tom1" ,
	["Hi F Tom"]		=	"drm.tom2" ,
	["Low Tom"]			=	"drm.tom3" ,
	["Lo M Tom"]		=	"drm.tom4" ,
	["Hi M Tom"]		=	"drm.tom5" ,
	["High Tom"]		=	"drm.tom6" ,
	["Hi Crash"]		=	"drm.crash1" ,
	["Lo Crash"]		=	"drm.crash2"
	
}

return midiLib;