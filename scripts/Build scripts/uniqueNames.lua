local lib = require(workspace.lib);

local function makeUniqueNames()
	
	local models = {};
	
	table.insert(models, workspace.Stringos);
	table.insert(models, workspace.Vibraphone);
	table.insert(models, workspace.Drums);
	table.insert(models, workspace.Bells);
	
	for _,model in pairs(models) do
		for _,v in pairs(model:GetDescendants()) do
			--if v.Name:match(" %%m$") then
			if lib.ancestorHasFlag(v, "m") or lib.hasFlag(v,"m") then
				local usedNames = {};
				for _,part in pairs(v:GetChildren()) do
					local name = part.Name;
					if name:match(" %%") then continue; end -- assume all flagged objects are alreadry unique
					
					if usedNames[name] == nil then
						usedNames[name] = 1;
					else
						--print("name changed! " .. part:GetFullName());
						part.Name = name .. usedNames[name];
						usedNames[name] += 1;
					end
				end
			end
		end
	end
	
end

return makeUniqueNames;