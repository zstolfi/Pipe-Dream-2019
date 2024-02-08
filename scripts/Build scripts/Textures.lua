lib = require(workspace.lib); find = lib.find;
local list = workspace.Textures;

local texName = "pipe dream v2";

local folder = list[texName];
local props = {"Color", "Material", "Reflectance", "Transparency"};
local selectorFunctions = {};	-- selector functions
local selectors = {};			-- list generated from the functions
-- i.e. selectors["Pipes"] returns a list of all pipe objects

function texture()
	for name,selector in pairs(selectors) do
		local sample = folder:FindFirstChild(name);
		if sample then
			for _,part in pairs(selector) do
				transferProps(part, sample);
			end
		end
	end
end


selectorFunctions = {
	
	{"All" , function(f)	-- f is a functor
		f( workspace.Bells:GetDescendants() );
		f( workspace.Drums:GetDescendants() );
		f( workspace.Marimba:GetDescendants() );
		f( workspace.Pipes:GetDescendants() );
		f( workspace.Stringos:GetDescendants() );
		f( workspace.Vibraphone:GetDescendants() );
		f( workspace.Walls:GetDescendants() );
	end} ,
	
	{"Walls" , function(f)
		f( workspace.Walls:GetChildren() );
	end} ,
	{"WallBack" , function(f) f( {workspace.Walls.wallBack, workspace.Walls.ceiling} ); end} ,
	{"WallFade" , function(f) f( {workspace.Walls.wallFade1, workspace.Walls.wallFade2} ); end} ,
	
	{"Floor" , function(f)
		f( {workspace.Walls.floor} );
	end} ,
	
	{"Marble" , function(f)
		f( {game.ReplicatedStorage.Marble} );
	end} ,
	{"Marble Overlay" , function(f)
		f( {game.ReplicatedStorage.Marble.Overlay} );
	end} ,
	
	
	-- PIPES --
	{"Pipes 1" , function(f)
		f( workspace.Pipes:GetDescendants() );
		f( workspace.Stringos:GetDescendants() );
		f( workspace.Drums:GetDescendants() );
		f( workspace.Marimba:GetDescendants() );
		f( workspace.Vibraphone:GetDescendants() );
		f( workspace.Bells:GetDescendants() );
	 end} ,
	
	{"Pipes 2" , function(f)
		for _,box in pairs(workspace.Pipes.boxes:GetChildren()) do
			--if box.Name:match("box 3") or box.Name:match("box 4") or box.Name:match("box 5") then
			--	f( box:GetDescendants() );
			--end
		end
		
		for _,model in pairs(workspace.Stringos:GetChildren()) do
			f( {model.Part6, model.Part10, find(model,"str 1 top.part2"), find(model,"str 1 bottom.part2") ,
				model.Part5, model.Part14, find(model,"str 2 top.part2"), find(model,"str 2 bottom.part2")} );
		end
		for _,arm in pairs(workspace.Vibraphone.arms:GetChildren()) do
			f( arm.Base:GetDescendants() );
		end
	 end} ,
	
	{"Pipes 3" , function(f)
		f( workspace.Pipes.supports:GetDescendants() );
		for _,box in pairs(workspace.Pipes.boxes:GetChildren()) do
			if box.Name:match("box 1") or box.Name:match("box 2") then
				f( box:GetDescendants() );
			else -- box 3, box 4, box 5... etc
				for _,part in pairs(box:GetDescendants()) do
					if part.Name ~= "white" then f( {part} ); end
				end
			end
		end
	
		for _,part in pairs(find(workspace.Vibraphone,"mid funnel.funnel"):GetDescendants()) do
			if part.Name == "corner" or part.Name == "edge"
				or part.Name:match("wire") or part.Name:match("brace") then
				f( {part} );
			end
		end
		for i,part in pairs(find(workspace.Drums,"drum grand funnel.funnel"):GetDescendants()) do
			if part.Name == "corner" or part.Name == "edge"
				or part.Name:match("wire") or part.Name:match("brace") then
				f( {part} );
			end
		end
	 end} ,
	
	
	-- INSTRUMENTS --
	{"Cymbal Stands" , function(f)
		local model = find(workspace.Drums,"4-Way.rotating");
		f( {find(model,"Cowbell.arm 2.Part1") ,
		    find(model,"Cowbell.arm 2.Part2") ,
		    find(model,"Hi Hat.arm 2.Cymbals.p1") ,
		    find(model,"Splash.arm 2.p1")} );
		
		for i = 1, 2 do
			local name = (i == 1) and "High Woodblock" or "Low Woodblock";
			local block = find(model,"Wood Blocks.arm 2.".. name);
			f( {block.Part1, find(block,"b1"), find(block,"b2")} );
			f( block.arm1:GetChildren() );
			f( block.arm2:GetChildren() );
		end

		local drums = workspace.Drums;
		f( {drums["Crash 1"].p1 ,
		    drums["Crash 2"].p1} );
	end} ,
	
	{"Cymbal Pads" , function(f)
		local model = find(workspace.Drums,"4-Way.rotating");
		f( {find(model,"Hi Hat.arm 2.Cymbals.Pivot") ,
			find(model,"Splash.arm 2.Pivot")} );

		local drums = workspace.Drums;
		f( {drums["Crash 1"].Pivot ,
		    drums["Crash 2"].Pivot} );
	end} ,
	
	{"Cowbell" , function(f)
		f( find(workspace.Drums,"4-Way.rotating.Cowbell.arm 2.Bell"):GetDescendants() );
	 end} ,
	
	{"Wood Blocks" , function(f)
		local blocks = find(workspace.Drums,"4-Way.rotating.Wood Blocks.arm 2");
		f( {find(blocks,"High Woodblock.Block"), find(blocks,"Low Woodblock.Block")} );
	 end} ,
	
	{"Cymbals" , function(f)
		f( find(workspace.Drums,"Crash 1.Cymbal"):GetChildren() );
		f( find(workspace.Drums,"Crash 2.Cymbal"):GetChildren() );
		f( find(workspace.Drums,"4-Way.rotating.Hi Hat.arm 2.Cymbals.hatTop"):GetChildren() );
		f( find(workspace.Drums,"4-Way.rotating.Hi Hat.arm 2.Cymbals.hatBottom"):GetChildren() );
		f( find(workspace.Drums,"4-Way.rotating.Splash.arm 2.Cymbal"):GetChildren() );
	 end} ,
	
	{"Stringos Strings" , function(f)
		for _,model in pairs(workspace.Stringos:GetDescendants()) do
			if model:IsA("Model") and model.Name:match("string") then
				f( model:GetChildren() );
			end
		end
	 end} ,
	
	{"Stringos Drums" , function(f)
		for _,part in pairs(workspace.Stringos:GetDescendants()) do
			if part:IsA("BasePart") and part.Name:match("^b2") then
				f( {part} );
			end
		end
	 end} ,
	
	{"Drums Rims" , function(f)
		for _,model in pairs(workspace.Drums:GetChildren()) do
			local head = find(model,"Head");
			if head then
				f( head:GetDescendants() );
			end
		end
	 end} ,
	
	{"Drums Heads" , function(f)
		for _,model in pairs(workspace.Drums:GetChildren()) do
			local head = find(model,"Head.Head")
			if head then
				f( {head} );
			end
		end
	end} ,

	{"Marimba Metal" , function(f)	-- also for the vibe
		f( workspace.Marimba.path:GetDescendants() );
		f( game.ReplicatedStorage["Marimba Block"]:GetDescendants() );
		for _,arm in pairs(workspace.Vibraphone.arms:GetChildren()) do
			f( {find(arm,"arm 2.hinge1") ,
				find(arm,"block.Hinge") ,
				find(arm,"block.top1"),    find(arm,"block.top2"),    find(arm,"block.top3") ,
				find(arm,"block.bottom1"), find(arm,"block.bottom2"), find(arm,"block.bottom3")} );
		end
	end} ,
	
	{"Black String" , function(f) -- the strings on the Vibe / marimba / wood blocks
		local marimba,woodBlocks = game.ReplicatedStorage["Marimba Block"], find(workspace.Drums["4-Way"],"rotating.Wood Blocks.arm 2");
		f( {find(marimba,"string bottom.string") ,
			find(marimba,"string top.string") ,
			find(woodBlocks,"Low Woodblock.string left.string") ,
			find(woodBlocks,"Low Woodblock.string right.string") ,
			find(woodBlocks,"High Woodblock.string left.string") ,
			find(woodBlocks,"High Woodblock.string right.string")} );
		for _,arm in pairs(workspace.Vibraphone.arms:GetChildren()) do
			f( {find(arm,"block.string bottom.string") ,
				find(arm,"block.string top.string")} );
		end
		for _,arm in pairs(workspace.Bells.arms:GetChildren()) do
			f( {arm.string, find(arm,"bell.string")} );
		end
	end} ,
	
	{"Marimba Blocks" , function(f)
		f( {find(game.ReplicatedStorage["Marimba Block"],"bar")} );
	end} ,

	{"Vibe Blocks", function(f)
		for _,arm in pairs(workspace.Vibraphone.arms:GetChildren()) do
			f( {find(arm,"block.bar")} );
		end
	end} ,

	{"Vibe Blocks Glow", function(f)
		for _,arm in pairs(workspace.Vibraphone.arms:GetChildren()) do
			f( {find(arm,"block.glow")} );
		end
	end} ,
	
	{"Bells" , function(f)
		for _,arm in pairs(workspace.Bells.arms:GetChildren()) do
			f( {find(arm,"bell.bellUnion")} );
		end
	end} ,
	
	-- MISC --
	{"FunnelFade" , function(f)
		sfFromName("Pipes 1")(function(t) -- itterate through "Pipes 1"
			for _,v in pairs(t) do
				if v.Name == "FunnelFade" then
					f( {v} );
				end
			end
		end);
	end} ,


	-- DEV STUFF --
	{"Bells dev" ,      function(f)  f( workspace.Bells:GetDescendants() );   end} ,
	{"Drums dev" ,      function(f)  f( workspace.Drums:GetDescendants() );   end} ,
	{"Marimba dev" ,    function(f)  f( workspace.Marimba:GetDescendants() );   end} ,
	{"Pipes dev" ,      function(f)  f( workspace.Pipes:GetDescendants() );   end} ,
	{"Stringos dev" ,   function(f)  f( workspace.Stringos:GetDescendants() );   end} ,
	{"Vibraphone dev" , function(f)  f( workspace.Vibraphone:GetDescendants() );   end} ,
	{"Cowbell dev" ,	function(f)  sfFromName("Cowbell")(f)  end} ,
	{"Cymbals dev" ,	function(f)  sfFromName("Cymbals")(f)  end} ,
	{"Wood Blocks dev", function(f)  sfFromName("Wood Blocks")(f)  end} ,
	
	{"Stringos Banjo dev" , function(f)
		for _,model in pairs(workspace.Stringos:GetChildren()) do
			if model.Name:match("Banjo") then
				f( model:GetDescendants() );
			end
		end
	 end} ,
	{"Stringos Bass dev" , function(f)
		for _,model in pairs(workspace.Stringos:GetChildren()) do
			if model.Name:match("Bass") then
				f( model:GetDescendants() );
			end
		end
	end}

};

order = {} -- ex: order["Wood Blocks"] = 13
for i,v in pairs(selectorFunctions) do  order[v[1]] = i;  end
function sfFromName(name)  return selectorFunctions[order[name]][2];  end

local taken = {}; -- ex: taken[part] = true (or nil)
for i = #selectorFunctions, 1, -1 do -- iterrate backwards
	name,func = unpack(selectorFunctions[i]);
	
	if not folder:FindFirstChild(name) then continue; end
	selectors[name] = {};
	func(function(t)
		for _,v in pairs(t) do
			if taken[v] then continue; end
			table.insert(selectors[name], v);
			taken[v] = true;
		end
	end);
end


function transferProps(to, from)
	if to:IsA("BasePart") and to.Transparency ~= 1 then
		for _,property in pairs(props) do
			to[property] = from[property];
		end
	end
end

-- parts update live as Samples change
for _,sample in pairs(folder:GetChildren()) do
	sample.Changed:Connect(function()
		for _,part in pairs(selectors[sample.Name]) do
			transferProps(part, sample);
		end
	end);
end


return texture;