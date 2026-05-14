local a={}local b=GetAncient(GetTeam())local c=nil;if b~=nil then c=b:GetLocation()end;function a.HealingWardThink(d)local e=d:GetNearbyHeroes(1200,true,BOT_MODE_DESIRE_NONE)local f=nil;local g=nil;local h=0.99;for i=1,#GetTeamPlayers(GetTeam())do local j=GetTeamMember(i)if j~=nil and j:IsAlive()and GetUnitToUnitDistance(j,d)<=1200 then local k=j:GetHealth()/j:GetMaxHealth()if k<h then h=k;g=j end end end;if#e==0 then local l=d:FindAoELocation(false,true,d:GetLocation(),1000,400,0,0)if l.count>=2 then f=l.targetloc end;if f==nil then if g~=nil then f=g:GetLocation()end end;if f==nil then local m=d:FindAoELocation(false,false,d:GetLocation(),800,400,0,0)if m.count>=1 then f=m.targetloc end end else if g~=nil then f=g:GetLocation()end end;if f~=nil then if f==GetBot():GetLocation()then return else d:Action_MoveToLocation(f)end else d:Action_MoveToLocation(c)end end;return alocal aCount = 0
local aTarget = nil
if a ~= nil then
    aCount = a.count
    aTarget = a.targetloc
end
