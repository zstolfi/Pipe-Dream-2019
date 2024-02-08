local lib = require(workspace.lib);

local function copyOriginals()
	local models = {};
	
	table.insert(models, workspace.Stringos);
	table.insert(models, workspace.Vibraphone);
	table.insert(models, workspace.Drums);
	table.insert(models, workspace.Bells);
	
	for _,model in pairs(models) do
		for _,v in pairs(model:GetDescendants()) do
			if v.Name:match(" %%m$") then
				v.Name = v.Name:match("^(.*) %%m");
				local vCF = (v:IsA("BasePart")) and v.CFrame or v:GetPrimaryPartCFrame();
				
				local partId = lib.relativeName(model, v);
				
				local origVal = Instance.new("ObjectValue");
				origVal.Value = v;
				origVal.Name = partId;
				origVal.Parent = workspace.Animation.modelLocations;
				
				local c = v:Clone();
				if c:IsA("BasePart") then
					c.CFrame = model:GetPrimaryPartCFrame():inverse() * vCF;
				else
					c:SetPrimaryPartCFrame(model:GetPrimaryPartCFrame():inverse() * vCF)
				end
				c.Parent = game.ReplicatedStorage.defaults;
				local cloneVal = Instance.new("ObjectValue");
				cloneVal.Value = c;
				cloneVal.Name = partId;
				cloneVal.Parent = workspace.Animation.defaults;
			end
		end
	end
end

return copyOriginals;