local m3d = require(workspace.m3d);
local autoArc = require(workspace.autoArc);

return function(check)
	check = check or workspace;
	
	local selfAndDesc = check:GetDescendants();
	table.insert(selfAndDesc, check);
	
	for _,e in pairs(selfAndDesc) do
		local copies, axis, size = e.Name:match("^.*%%aa(%d+)([XYZxyz]?) ?(%d-%.?%d*%%?)$");
		
		if e.ClassName == "Model" and copies then
			autoArc(e, tonumber(copies), size, axis);
		end
	end
end