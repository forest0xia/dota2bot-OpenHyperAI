dofile('bots/Buff/Helper')

if XP == nil
then
    XP = {}
end

local XPNeeded = {
    [1]  = 240,
    [2]  = 400,
    [3]  = 520,
    [4]  = 600,
    [5]  = 680,
    [6]  = 760,
    [7]  = 800,
    [8]  = 900,
    [9]  = 1000,
    [10] = 1100,
    [11] = 1200,
    [12] = 1300,
    [13] = 1400,
    [14] = 1500,
    [15] = 1600,
    [16] = 1700,
    [17] = 1800,
    [18] = 1900,
    [19] = 2000,
    [20] = 2200,
    [21] = 2400,
    [22] = 2600,
    [23] = 2800,
    [24] = 3000,
    [25] = 4000,
    [26] = 5000,
    [27] = 6000,
    [28] = 7000,
    [29] = 7500,
    [30] = 0,
}

-- Useful for early/mid game.
function XP.UpdateXP(bot, team)
    local gameTime = Helper.DotaTime() / 60
    -- local xp = 2
    -- local mul = 1

    -- if not Helper.IsCore(bot, team)
    -- then
    --     xp = 1.25
    -- end

    local botLevel = bot:GetLevel()
    local needXP = XPNeeded[botLevel]
    local mul2XP = needXP / 2

    local xp = (mul2XP / 60) / 2

    if not Helper.IsCore(bot, team)
    then
        xp = xp * 0.5
    end

    local timeMul = 1 - (gameTime / 60)
    if timeMul < 0 then timeMul = 1 end

    xp = xp * timeMul

    -- if   gameTime <=  5 * 60 then mul = 1
    -- elseif gameTime <= 10 * 60 then mul = 1.1
    -- elseif gameTime <= 15 * 60 then mul = 1.2
    -- elseif gameTime <= 20 * 60 then mul = 1.3
    -- elseif gameTime <= 25 * 60 then mul = 1.4
    -- elseif gameTime <= 30 * 60 then mul = 1.5
    -- elseif gameTime <= 35 * 60 then mul = 1.6
    -- elseif gameTime <= 40 * 60 then mul = 1.7
    -- elseif gameTime <= 45 * 60 then mul = 1.8
    -- elseif gameTime <= 50 * 60 then mul = 1.9
    -- elseif gameTime <= 55 * 60 then mul = 2.0
    -- end

    if bot:IsAlive()
    and gameTime > 0
    then
        -- bot:AddExperience(xp * mul, 0, false, true)
        bot:AddExperience(math.floor(xp), 0, false, true)
    end
end

return XP