local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
                        ['t25'] = {10, 0},
                        ['t20'] = {10, 0},
                        ['t15'] = {0, 10},
                        ['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {

}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Deadshot      = bot:GetAbilityByName('muerta_dead_shot')
local TheCalling    = bot:GetAbilityByName('muerta_the_calling')
local Gunslinger    = bot:GetAbilityByName('muerta_gunslinger')
local PartingShot   = bot:GetAbilityByName('muerta_parting_shot')
local PierceTheVeil = bot:GetAbilityByName('muerta_pierce_the_veil')

local DeadshotDesire, DeadshotTarget
local TheCallingDesire, TheCallingLocation
local GunslingerDesire
local PartingShotDesire, PartingShotTarget
local PierceTheVeilDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    -- print(J.ConsolePrintActiveMode(bot))
end

return X