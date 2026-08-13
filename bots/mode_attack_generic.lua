--------------------------------------------------------------------
-- mode_attack_generic.lua (generic attack logic for ALL heroes)
-- OHA MOD: 通用攻击逻辑补全（原版仅 BuggyHeroes 有专属 override，普通英雄为空壳）
-- 行为：①被敌人英雄攻击时还手 ②对线期安全骚扰 ③危险（塔/人少）时撤退
-- 保守设计：不主动追杀、不冲塔、不脱离兵线安全区
-- 结构：保持原版"顶层函数转发"机制；BuggyHeroes 走作者 override，普通英雄走本文件通用逻辑
--------------------------------------------------------------------
local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils')
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local local_mode_attack_generic
if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

-- BuggyHeroes 依然走作者专属 override（9 个特殊英雄）
if Utils.BuggyHeroesDueToValveTooLazy[botName] then
	local_mode_attack_generic = dofile( GetScriptDirectory().."/FunLib/override_generic/mode_attack_generic" )
end

-- 普通英雄：使用本文件内置的通用攻击逻辑
BotsInit = require("game/botsinit")
local Generic = BotsInit.CreateGeneric()

local fLastAttackDesire = 0
local botAttackRange, botHP, botLocation

local function IsValidUnit(hUnit)
	return hUnit ~= nil and not hUnit:IsNull() and hUnit:IsAlive()
end

function Generic.OnStart() end
function Generic.OnEnd()
	fLastAttackDesire = 0
end

-- Desire smoothing（与作者 override 同款）
local function GetActualDesire(nDesire)
	local alpha = 0.3
	nDesire = fLastAttackDesire * (1 - alpha) + nDesire * alpha
	fLastAttackDesire = nDesire
	return nDesire
end

function Generic.GetDesire()
	if not bot:IsAlive()
	or bot:IsIllusion()
	or bot:HasModifier('modifier_fountain_fury_swipes_damage_increase')
	then
		return BOT_MODE_DESIRE_NONE
	end
	-- 注意：这里不检查 J.CanNotUseAction（它含 HasQueuedAction，对线期 bot 总有排队动作会误杀还手欲望）
	-- 执行时检查在 Think 里做（与作者 override 一致）

	botAttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
	botHP = J.GetHP(bot)
	botLocation = bot:GetLocation()

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	-- 完全没有可见敌人 → 无攻击欲望
	if #nEnemyHeroes == 0 then
		return GetActualDesire(BOT_MODE_DESIRE_NONE)
	end

	-- 兵线压力保护（作者 override 66-74 行同款）：对线期兵在打我们且伤害 ≥25% 血量 → 不攻击
	-- 防顶着兵线骚扰/还手送头（作者版核心保护件之一）
	if J.IsInLaningPhase() then
		local creepDmg = 0
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		for _, creep in pairs(nEnemyLaneCreeps) do
			if J.IsValid(creep) and creep:GetAttackTarget() == bot then
				creepDmg = creepDmg + (bot:GetActualIncomingDamage(creep:GetAttackDamage() * creep:GetAttackSpeed() * 5.0, DAMAGE_TYPE_PHYSICAL) - bot:GetHealthRegen() * 5.0)
			end
		end
		if creepDmg / (bot:GetHealth() + 1) >= 0.25 then
			return GetActualDesire(BOT_MODE_DESIRE_NONE)
		end
	end

	-- 条件 1：被敌人英雄攻击 → 还手（核心：治"被白嫖不还手"）
	-- 距离放宽到 1200（跳刀距离）：远程英雄（600-800 射程）在攻击范围外白嫖近战 bot 时
	-- 也必须响应——够得着就还手，够不着 Think 里走位靠近（原 botAttackRange+300 挡掉了远程白嫖场景）
	-- OHA MOD 2026/08/13 双保险：攻击目标检测 + 2.5 秒内被伤害检测（攻击间隔走位导致
	-- GetAttackTarget 归零/句柄比较不可靠时，还手检测会失效 → 被白嫖人头）
	for _, enemy in ipairs(nEnemyHeroes) do
		if J.IsValidHero(enemy)
		and not J.IsSuspiciousIllusion(enemy)
		and (enemy:GetAttackTarget() == bot or bot:WasRecentlyDamagedByHero(enemy, 2.5))
		and J.IsInRange(bot, enemy, 1200)
		then
			-- 还手但别送：敌人明显更多时不硬拼
			local nAllyNear = J.GetAlliesNearLoc(botLocation, 1200)
			local nEnemyNear = J.GetEnemiesNearLoc(botLocation, 1200)
			if #nEnemyNear <= #nAllyNear + 1 and botHP > 0.25 then
				-- OHA MOD 2026/08/13: 0.9(VERYHIGH)→0.95
				-- 修复平局 bug：laning 补刀渴望度也是 0.9，平局时引擎不切换模式 → 被打不还手
				-- 0.95 > laning 0.9（压过补刀）且 < retreat 1.0（残血仍先保命）
				return GetActualDesire(0.95)
			end
		end
	end

	-- 条件 2：对线期安全骚扰（友方占优且未被塔打）
	-- OHA MOD 2026/08/13: 骚扰距离 攻击范围 → max(攻击范围, 500)
	-- 修复双近战对线发呆：近战威胁范围仅 175 码，双方站位 500+ 永远够不着 → 互看发呆
	-- 500 = 对线换血距离，近战也有走位压人的空间（远程不受影响，600+ 本来就更远）
	if J.IsInLaningPhase() then
		local nAllyNear = J.GetAlliesNearLoc(botLocation, 1200)
		local nEnemyNear = J.GetEnemiesNearLoc(botLocation, 1200)
		local nEnemyTowers = bot:GetNearbyTowers(1200, true)
		-- 伤害权衡（作者 b2 简化版）：算 900 码内敌人 3 秒总输出，扛不住不主动压
		local fEnemyDamage = 0
		for _, possibleEnemy in ipairs(nEnemyHeroes) do
			if J.IsValidHero(possibleEnemy)
			and J.GetHP(possibleEnemy) >= 0.25
			and J.IsInRange(bot, possibleEnemy, 900)
			then
				fEnemyDamage = fEnemyDamage + possibleEnemy:GetEstimatedDamageToTarget(false, bot, 3.0, DAMAGE_TYPE_ALL)
			end
		end
		if #nAllyNear >= #nEnemyNear
		and not bot:WasRecentlyDamagedByTower(2.0)
		and not (J.IsValidBuilding(nEnemyTowers[1]) and nEnemyTowers[1]:GetAttackTarget() == bot)
		and bot:GetHealth() > fEnemyDamage * 1.15
		then
			for _, enemy in ipairs(nEnemyHeroes) do
				if J.IsValidHero(enemy)
				and not J.IsSuspiciousIllusion(enemy)
				and J.IsInRange(bot, enemy, math.max(botAttackRange, 500))
				and botHP > 0.5
				then
					-- OHA MOD 2026/08/13: MODERATE(0.5)→0.42——低于 laning 对线期值(0.446/0.369)
					-- 让 laning 主导补刀（修复"attack 活跃后正反补变弱"），
					-- 只在 laning 低价值段(0.268/0.2)才骚扰压人
					return GetActualDesire(0.42)
				end
			end
		end
	end

	return GetActualDesire(BOT_MODE_DESIRE_NONE)
end

function Generic.Think()
	-- OHA MOD 2026/08/13: 守卫从 J.CanNotUseAction 换成"不含 HasQueuedAction"版
	-- 根因：laning Think 每帧发 MoveTo → bot 移动排队 → CanNotUseAction 恒 true
	-- → attack Think 空转几秒（= 3/4 号位对线挂机）→ 移动队列应能被攻击/骚扰打断
	if (not bot:IsAlive())
	or (bot:IsInvulnerable() and not bot:HasModifier('modifier_fountain_invulnerability') and not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff'))
	or bot:IsCastingAbility()
	or bot:IsUsingAbility()
	or bot:IsChanneling()
	or (bot:IsStunned() and not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff'))
	or bot:IsNightmared()
	or bot:HasModifier( 'modifier_ringmaster_the_box_buff' )
	or bot:HasModifier( 'modifier_item_forcestaff_active' )
	or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )
	or bot:HasModifier( 'modifier_tinker_rearm' )
	then
		return
	end

	botAttackRange = bot:GetAttackRange() + bot:GetBoundingRadius()
	botLocation = bot:GetLocation()

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nEnemyTowers = bot:GetNearbyTowers(1600, true)

	-- 塔在打我们且没队友帮 → 撤出塔范围（对线期避免白送）
	if J.IsValidBuilding(nEnemyTowers[1]) and nEnemyTowers[1]:GetAttackTarget() == bot then
		bot:Action_MoveToLocation(J.VectorAway(botLocation, nEnemyTowers[1]:GetLocation(), 900))
		return
	end

	-- 选择还手目标：正在打我们的敌人优先
	-- 范围放宽到 1200 与 GetDesire 条件 1 对齐：远程白嫖时目标选得中，
	-- dist > botAttackRange 时下方走 MoveToLocation 靠近（而不是站着看）
	local __target = nil
	for _, enemy in ipairs(nEnemyHeroes) do
		if J.IsValidHero(enemy)
		and not J.IsSuspiciousIllusion(enemy)
		and J.CanBeAttacked(enemy)
		and J.IsInRange(bot, enemy, 1200)
		then
			if enemy:GetAttackTarget() == bot or bot:WasRecentlyDamagedByHero(enemy, 2.5) then
				__target = enemy
				break
			end
		end
	end

	if __target == nil then
		-- 没人在打我们 → 骚扰敌人：打分选目标（作者 override 300-350 行简化版）
		-- 优先脆皮（血量低）/核心（1.5 倍），跳过有保命状态的敌人
		local targetScore = 0
		for _, enemy in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemy)
			and not J.IsSuspiciousIllusion(enemy)
			and J.CanBeAttacked(enemy)
			and J.IsInRange(bot, enemy, math.max(botAttackRange + 200, 500))
			and not enemy:HasModifier('modifier_abaddon_borrowed_time')
			and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemy:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
			and not enemy:HasModifier('modifier_ursa_enrage')
			and not enemy:HasModifier('modifier_item_aeon_disk_buff')
			then
				local mul = 1
				if J.IsCore(enemy) then mul = mul * 1.5 else mul = mul * 0.5 end
				local score = (1 - J.GetHP(enemy)) * mul
				if score > targetScore then
					targetScore = score
					__target = enemy
				end
			end
		end
	end

	if __target ~= nil then
		bot:SetTarget(__target)
		local dist = GetUnitToUnitDistance(bot, __target)
		if dist <= botAttackRange then
			bot:Action_AttackUnit(__target, true)
		else
			bot:Action_MoveToLocation(__target:GetLocation())
		end
		return
	end

	-- 没有可攻击目标 → 结束本帧攻击模式
	fLastAttackDesire = 0
end

-- 顶层函数转发（引擎入口）：BuggyHeroes → 作者 override；普通英雄 → 本文件 Generic
if local_mode_attack_generic ~= nil then
	function GetDesire() return local_mode_attack_generic.GetDesire() end
	function Think() return local_mode_attack_generic.Think() end
	function OnStart() return local_mode_attack_generic.OnStart() end
	function OnEnd() return local_mode_attack_generic.OnEnd() end
else
	function GetDesire() return Generic.GetDesire() end
	function Think() return Generic.Think() end
	function OnStart() return Generic.OnStart() end
	function OnEnd() return Generic.OnEnd() end
end
