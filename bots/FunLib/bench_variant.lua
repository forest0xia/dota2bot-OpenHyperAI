-- dota-bot benchmark: the A/B variant this match plays, so one series can alternate versions of the bot under the same
-- conditions. tools/bench/orquestador.mjs writes Customize/bench_variant.lua (git-ignored) for each match, e.g.
-- "return { empuje = false, thinkless = 1 }", and deletes it when the match ends. Without that file it returns an
-- empty table and the bot plays its normal, current code. Fields:
--   empuje    true: PR #11, relaxed push caps with a 10k net worth lead (off by default), FunLib/aba_push.lua
--   grupo     true: with a 5k lead the whole team pushes one lane together, FunLib/aba_push.lua
--   grupo_umbral number: the lead that starts that group push (default 5000)
--   retirada_temprana true: retreat when the enemies near can kill the hero in 5 s, FunLib/retreat_early.lua
--   farm      true: keep farming with a 6k+ lead, mode_farm_generic.lua
--   cerebro   true: the team brain plans for the five, team_desires.lua and FunLib/team_brain.lua
--   builds    true: cores buy what high-level players buy (FunLib/data_builds.lua), item_purchase_generic.lua
--   farm_sin_reloj true: farming has no minute-18 late-game cut, mode_farm_generic.lua (brain v3)
--   api_sonda true: brain v3 game 0, FunLib/api_probe.lua via team_desires.lua and mode_attack_generic.lua
--   thinkless number: overrides Customize.ThinkLess, Customize/general.lua
-- dofile (not require) so a stale answer is never cached between matches.
-- With "teams" (orquestador.mjs --rival dotabot: dota-bot against dota-bot), each team plays its own entry.
local ok, variant = pcall(dofile, GetScriptDirectory()..'/Customize/bench_variant')
if ok and type(variant) == 'table' then
	if type(variant.teams) == 'table' then return variant.teams[GetTeam()] or {} end
	return variant
end
return {}
