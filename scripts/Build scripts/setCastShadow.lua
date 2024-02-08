setProps = function(f)
	f( workspace.Bells:GetDescendants() );
	f( {workspace.Walls.ceiling ,
		workspace.Walls.wallBack ,
		workspace.Walls.wallFade1 ,
		workspace.Walls.wallFade2} );
end

function disableShadows(list)
	for _,part in pairs(list) do
		if part:IsA("BasePart") then
			part.CastShadow = false;
		end
	end
end

return function() setProps(disableShadows) end;