lib = require(workspace.lib); find = lib.find;
local tex = {
	stringos = {
		size = 1.2 , -- size in studs, all textures are centered
		pos = Vector2.new(0,0) ,
		
		face = Enum.NormalId.Right ,
		fill = false , -- set true => strech the texture to fit

		selector = function(f)
			for _,model in pairs(workspace.Stringos:GetChildren()) do
				f( find(model,"b2") );
			end
		end
	} ,
	
	drums = { -- the bass head is separate
		size = 1.3 ,
		pos = Vector2.new(0,0) ,
		
		face = Enum.NormalId.Right ,
		fill = false ,

		selector = function(f)
			for _,model in pairs(workspace.Drums:GetChildren()) do
				if model.Name:match("Tom$") or model.Name == "Snare" then
					f( find(model,"Head.Head") );
				end
			end
		end
	} ,
	
	drumsBass = {
		size = 2.7 ,
		pos = Vector2.new(0,0) ,

		face = Enum.NormalId.Right ,
		fill = false ,

		selector = function(f)
			f( find(workspace.Drums.Bass,"Head.Head") );
		end
	} ,
	
	vibeBar = {
		size = 0 ,
		pos = Vector2.new(0,0) ,

		face = Enum.NormalId.Back ,
		fill = true ,

		selector = function(f)
			for _,model in pairs(workspace.Vibraphone.arms:GetChildren()) do
				f( find(model,"block.bar") );
			end
		end
	} ,
	
	marimba = {
		size = 0.225 ,
		stretch = Vector2.new(10, 1) ,
		pos = Vector2.new(0,0) ,

		face = Enum.NormalId.Back ,
		fill = false ,

		selector = function(f)
			f( find(game.ReplicatedStorage["Marimba Block"],"bar") );
		end
	} ,
	
	walls = {
		size = 15 ,
		pos = Vector2.new(0,0) ,

		face = Enum.NormalId.Front ,
		fill = false ,

		selector = function(f)
			for _,wall in pairs(workspace.Walls:GetChildren()) do
				if wall.Name == "wall" or wall.Name == "wallBack" then -- not counting the ceiling
					f( wall );
				end
			end
		end
	} ,
	
	floor = {
		size = 7 ,
		stretch = Vector2.new(1.5, 1) ,
		pos = Vector2.new(0,0) ,

		face = Enum.NormalId.Top ,
		fill = false ,

		selector = function(f)
			f( workspace.Walls.floor );
		end
	} ,
};

local dirAxis = {
	[Enum.NormalId.Left  ] = "x" ,
	[Enum.NormalId.Right ] = "x" ,
	[Enum.NormalId.Top   ] = "y" ,
	[Enum.NormalId.Bottom] = "y" ,
	[Enum.NormalId.Front ] = "z" ,
	[Enum.NormalId.Back  ] = "z"
};

local axisUV = {
	x = {"z", "y"} ,
	y = {"x", "z"} ,
	z = {"x", "y"}
};

function placeDecals()
	for name,texture in pairs(tex) do
		local master = script[name];
		texture.selector(function(part) -- for every part
			local axis = dirAxis[texture.face];
			local U,V = unpack(axisUV[axis]);
			
			local t = master:Clone();   -- copy the texture
			if not texture.fill then    -- and adjust the size
				t.StudsPerTileU = texture.size;
				t.StudsPerTileV = texture.size;
				t.OffsetStudsU = 0.5 * (texture.size - part.Size[U]);
				t.OffsetStudsV = 0.5 * (texture.size - part.Size[V]);
			else
				t.StudsPerTileU = part.Size[U];
				t.StudsPerTileV = part.Size[V];
				t.OffsetStudsU = 0;
				t.OffsetStudsV = 0;
			end
			
			if texture.stretch then
				t.StudsPerTileU *= texture.stretch.x;
				t.StudsPerTileV *= texture.stretch.y;
			end
			t.Face = texture.face or t.Face;
			t.Parent = part;
		end);
	end
end

return placeDecals;