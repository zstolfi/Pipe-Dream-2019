local midi = {
	
	midiFolder = workspace.MIDIs ,
	strVal = nil ,	-- StringValue where the base64 encoded midi is stored
	
	base64Data = "" ,
	
	binary = "" ,
	
	decode = function(self, midiObj)
		self.strVal = if typeof(midiObj) == "Instance" then midiObj else self.midiFolder[midiObj];
		self.base64Data = self.strVal.Value;
		local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		
		local bin = "";
		for i = 1, #self.base64Data, 4 do
			local fourChars = self.base64Data:sub(i,i+3);
			
			local v = {};
			for j = 1, 4 do
				local char = fourChars:sub(j,j);
				if char ~= "=" then
					v[j] = b64:find(char)-1;
				else
					v[j] = 0;
				end
			end
			
			local threeBytes = v[1]*(64^3) + v[2]*(64^2) + v[3]*(64^1) + v[4]*(64^0);
			
			local fl = math.floor;
			
			local b = {};
			for j = 1, 3 do
				
				local shift = -8*(j-3);	-- 1: 16 bits right, 2:  8 bits right, 3: 0 bits right
				local s = fl(threeBytes/(2^shift));
				
				local by = s - fl(s/256)*256;	-- delete everything past 256
				b[j] = (string.char(by));
			end
			
			bin = bin..b[1]..b[2]..b[3];
			
		end
		self.binary = bin;
	end
};

return midi;