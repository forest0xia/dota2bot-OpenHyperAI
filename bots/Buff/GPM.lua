dofile('bots/Buff/Helper')

if GPM == nil
then
    GPM = {}
end

-- Reasonable GPM (XPM later)
function GPM.TargetGPM(time)
    if time <= 10 * 60 then
        return 450
    elseif time <= 20 * 60 then
        return 600
    elseif time <= 30 * 60 then
        return 750
    else
        return RandomInt(900, 1000)
    end
end

function GPM.UpdateBotGold(bot)
    local gameTime = Helper.DotaTime() / 60
    local targetGPM = GPM.TargetGPM(gameTime)

    local currentGPM = PlayerResource:GetGoldPerMin(bot:GetPlayerID())
    local goldPerTick = targetGPM / currentGPM

    if goldPerTick < 1 then goldPerTick = 1 end

    if  bot:IsAlive()
    and gameTime > 0
    then
        bot:ModifyGold(1 + math.ceil(goldPerTick), true, 0)
    end
end

return GPM