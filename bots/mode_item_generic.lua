-----------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
-----------------------------------------------------------------------------
if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

if string.find(GetScriptDirectory(), "srcds")
	or string.find(GetScriptDirectory(), "/var/")
then

function GetDesire()

	return BOT_MODE_DESIRE_NONE

end
	
end



-- dota2jmz@163.com QQ:2462331592..