local Q = workspace.switches.BuildQuality.Value;
local scripts = {	-- in this order
	script.Parent.removeRips ,
 	if Q < 30 then nil else script.Parent.Lighting ,
	
	script.Parent.stringoLerp ,
	script.Parent.vibArms1 ,
	script.Parent.vibArms2 ,
	script.Parent.vibArms3 ,
--	script.Parent.vibeArmsUp ,
	
	script.Parent.cloneBells ,
	
	script.Parent.makeSpins ,
	script.Parent.copyFunnels ,
	script.Parent.makeArcs ,
	script.Parent.resize ,
	
	script.Parent.setCastShadow ,
	script.Parent.Textures ,
	if Q < 20 then nil else script.Parent.Decals ,
	
	script.Parent.correctUnionColor ,
	script.Parent.uniqueNames ,
	script.Parent.copyOriginals ,
	script.Parent.lockEverything
};

if Q == 0 then  return;  end
for _,v in pairs(scripts) do
	require(v)();
end
script.Parent.done.Value = true;