import { HeroName } from "bots/ts_libs/dota/heroes";

interface HeroRoles {
    carry: number; // will become more useful later in the game if they gain a significant gold advantage.
    disabler: number; // has a guaranteed disable for one or more of their spells.
    durable: number; // has the ability to last longer in teamfights.
    escape: number; // has the ability to quickly avoid death.
    initiator: number; // good at starting a teamfight. Better tanky so it can initiate and then servive.
    jungler: number; // can farm effectively from neutral creeps inside the jungle early in the game.
    nuker: number; // can quickly kill enemy heroes using high damage spells with low cooldowns.
    support: number; // can focus less on amassing gold and items, and more on using their abilities to gain an advantage for the team.
    pusher: number; // can quickly siege and destroy towers and barracks at all points of the game.
    ranged: number; // is ranged or melee hero.
    healer: number; // can heal allies.
}

interface RolesMap {
    [hero: string]: HeroRoles;
}

export const HeroRolesMap: RolesMap = {
    [HeroName.Abaddon]: { carry: 1, disabler: 0, durable: 2, escape: 0, initiator: 0, jungler: 0, nuker: 0, support: 2, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.Underlord]: { carry: 0, disabler: 1, durable: 1, escape: 2, initiator: 0, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Alchemist]: { carry: 2, disabler: 1, durable: 2, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.AncientApparition]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Antimage]: { carry: 3, disabler: 0, durable: 0, escape: 3, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.ArcWarden]: { carry: 3, disabler: 0, durable: 0, escape: 3, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Axe]: { carry: 1, disabler: 2, durable: 3, escape: 0, initiator: 3, jungler: 2, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Bane]: { carry: 1, disabler: 3, durable: 1, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Batrider]: { carry: 1, disabler: 2, durable: 0, escape: 1, initiator: 3, jungler: 2, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Beastmaster]: { carry: 1, disabler: 2, durable: 2, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Bloodseeker]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 1, jungler: 1, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.BountyHunter]: { carry: 1, disabler: 0, durable: 0, escape: 2, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Brewmaster]: { carry: 1, disabler: 2, durable: 2, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Bristleback]: { carry: 2, disabler: 0, durable: 3, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Broodmother]: { carry: 1, disabler: 1, durable: 0, escape: 3, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 3, ranged: 0, healer: 0 },
    [HeroName.Centaur]: { carry: 0, disabler: 1, durable: 3, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.ChaosKnight]: { carry: 3, disabler: 2, durable: 2, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 2, ranged: 0, healer: 0 },
    [HeroName.Chen]: { carry: 0, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 3, nuker: 0, support: 2, pusher: 2, ranged: 1, healer: 1 },
    [HeroName.Clinkz]: { carry: 2, disabler: 0, durable: 0, escape: 3, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 1, ranged: 1, healer: 0 },
    [HeroName.CrystalMaiden]: { carry: 0, disabler: 2, durable: 0, escape: 0, initiator: 0, jungler: 1, nuker: 2, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.DarkSeer]: { carry: 0, disabler: 1, durable: 0, escape: 1, initiator: 1, jungler: 1, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.DarkWillow]: { carry: 1, disabler: 3, durable: 0, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Dawnbreaker]: { carry: 1, disabler: 2, durable: 1, escape: 1, initiator: 1, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.Dazzle]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.DeathProphet]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 3, ranged: 1, healer: 0 },
    [HeroName.Disruptor]: { carry: 0, disabler: 2, durable: 0, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Doom]: { carry: 1, disabler: 2, durable: 2, escape: 0, initiator: 2, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.DragonKnight]: { carry: 2, disabler: 2, durable: 2, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 3, ranged: 0, healer: 0 },
    [HeroName.DrowRanger]: { carry: 2, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.EarthSpirit]: { carry: 1, disabler: 1, durable: 1, escape: 2, initiator: 1, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Earthshaker]: { carry: 0, disabler: 2, durable: 0, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.ElderTitan]: { carry: 0, disabler: 1, durable: 1, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.EmberSpirit]: { carry: 2, disabler: 1, durable: 0, escape: 3, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Enchantress]: { carry: 0, disabler: 0, durable: 1, escape: 0, initiator: 0, jungler: 3, nuker: 1, support: 0, pusher: 2, ranged: 1, healer: 1 },
    [HeroName.Enigma]: { carry: 0, disabler: 2, durable: 0, escape: 0, initiator: 2, jungler: 3, nuker: 0, support: 0, pusher: 2, ranged: 1, healer: 0 },
    [HeroName.FacelessVoid]: { carry: 2, disabler: 2, durable: 1, escape: 1, initiator: 3, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.NaturesProphet]: { carry: 1, disabler: 0, durable: 0, escape: 1, initiator: 0, jungler: 3, nuker: 1, support: 0, pusher: 3, ranged: 1, healer: 0 },
    [HeroName.Grimstroke]: { carry: 0, disabler: 2, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 3, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Gyrocopter]: { carry: 3, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Hoodwink]: { carry: 1, disabler: 2, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Huskar]: { carry: 2, disabler: 0, durable: 2, escape: 0, initiator: 1, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Invoker]: { carry: 1, disabler: 2, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 3, support: 0, pusher: 1, ranged: 1, healer: 0 },
    [HeroName.Jakiro]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 1, pusher: 2, ranged: 1, healer: 0 },
    [HeroName.Juggernaut]: { carry: 2, disabler: 0, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 1, ranged: 0, healer: 1 },
    [HeroName.KeeperOfTheLight]: { carry: 0, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 1, nuker: 2, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.Kunkka]: { carry: 1, disabler: 1, durable: 1, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.LegionCommander]: { carry: 1, disabler: 2, durable: 1, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.Leshrac]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 3, support: 1, pusher: 3, ranged: 1, healer: 0 },
    [HeroName.Lich]: { carry: 1, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Lifestealer]: { carry: 2, disabler: 1, durable: 2, escape: 1, initiator: 0, jungler: 1, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Lina]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 3, support: 1, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Lion]: { carry: 1, disabler: 3, durable: 0, escape: 0, initiator: 2, jungler: 0, nuker: 3, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.LoneDruid]: { carry: 2, disabler: 0, durable: 1, escape: 0, initiator: 0, jungler: 1, nuker: 0, support: 0, pusher: 3, ranged: 1, healer: 0 },
    [HeroName.Luna]: { carry: 2, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Lycan]: { carry: 2, disabler: 0, durable: 1, escape: 1, initiator: 0, jungler: 1, nuker: 1, support: 0, pusher: 3, ranged: 0, healer: 0 },
    [HeroName.Magnus]: { carry: 1, disabler: 2, durable: 0, escape: 1, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Marci]: { carry: 1, disabler: 1, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Mars]: { carry: 1, disabler: 2, durable: 2, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 1, ranged: 0, healer: 0 },
    [HeroName.Medusa]: { carry: 3, disabler: 1, durable: 1, escape: 0, initiator: 0, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Meepo]: { carry: 2, disabler: 1, durable: 0, escape: 2, initiator: 1, jungler: 0, nuker: 2, support: 0, pusher: 1, ranged: 0, healer: 0 },
    [HeroName.Mirana]: { carry: 1, disabler: 1, durable: 0, escape: 2, initiator: 0, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.MonkeyKing]: { carry: 2, disabler: 1, durable: 0, escape: 2, initiator: 1, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Morphling]: { carry: 3, disabler: 1, durable: 2, escape: 3, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Muerta]: { carry: 3, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.NagaSiren]: { carry: 3, disabler: 2, durable: 0, escape: 1, initiator: 1, jungler: 0, nuker: 0, support: 1, pusher: 2, ranged: 0, healer: 0 },
    [HeroName.Necrophos]: { carry: 1, disabler: 1, durable: 1, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 2, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.ShadowFiend]: { carry: 2, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 3, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.NightStalker]: { carry: 1, disabler: 2, durable: 2, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.NyxAssassin]: { carry: 1, disabler: 2, durable: 0, escape: 1, initiator: 2, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.OutworldDestroyer]: { carry: 2, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.OgreMagi]: { carry: 1, disabler: 2, durable: 1, escape: 0, initiator: 1, jungler: 0, nuker: 2, support: 2, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Omniknight]: { carry: 1, disabler: 0, durable: 2, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.Oracle]: { carry: 1, disabler: 2, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 3, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.Pangolier]: { carry: 2, disabler: 2, durable: 1, escape: 1, initiator: 3, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.PhantomAssassin]: { carry: 3, disabler: 0, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.PhantomLancer]: { carry: 2, disabler: 0, durable: 0, escape: 2, initiator: 0, jungler: 0, nuker: 2, support: 0, pusher: 1, ranged: 0, healer: 0 },
    [HeroName.Phoenix]: { carry: 1, disabler: 1, durable: 0, escape: 2, initiator: 2, jungler: 0, nuker: 3, support: 1, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.PrimalBeast]: { carry: 0, disabler: 1, durable: 3, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Puck]: { carry: 1, disabler: 3, durable: 0, escape: 3, initiator: 3, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Pudge]: { carry: 1, disabler: 2, durable: 2, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Pugna]: { carry: 1, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 0, pusher: 2, ranged: 1, healer: 1 },
    [HeroName.QueenOfPain]: { carry: 1, disabler: 0, durable: 0, escape: 3, initiator: 0, jungler: 0, nuker: 3, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Razor]: { carry: 2, disabler: 0, durable: 2, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Clockwerk]: { carry: 1, disabler: 2, durable: 1, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Riki]: { carry: 2, disabler: 1, durable: 0, escape: 2, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Ringmaster]: { carry: 0, disabler: 2, durable: 1, escape: 1, initiator: 0, jungler: 0, nuker: 0, support: 2, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Rubick]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.SandKing]: { carry: 1, disabler: 2, durable: 0, escape: 2, initiator: 3, jungler: 1, nuker: 2, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.ShadowDeamon]: { carry: 0, disabler: 2, durable: 0, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.ShadowShaman]: { carry: 0, disabler: 3, durable: 0, escape: 0, initiator: 1, jungler: 0, nuker: 2, support: 2, pusher: 3, ranged: 1, healer: 0 },
    [HeroName.Timbersaw]: { carry: 1, disabler: 0, durable: 2, escape: 2, initiator: 0, jungler: 0, nuker: 3, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Silencer]: { carry: 1, disabler: 2, durable: 0, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.WraithKing]: { carry: 2, disabler: 2, durable: 3, escape: 0, initiator: 1, jungler: 0, nuker: 0, support: 1, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.SkywrathMage]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 3, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Slardar]: { carry: 2, disabler: 1, durable: 2, escape: 1, initiator: 2, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Slark]: { carry: 2, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Snapfire]: { carry: 1, disabler: 1, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 2, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.Sniper]: { carry: 2, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Spectre]: { carry: 3, disabler: 0, durable: 1, escape: 1, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.SpiritBreaker]: { carry: 1, disabler: 2, durable: 2, escape: 1, initiator: 2, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.StormSpirit]: { carry: 2, disabler: 1, durable: 0, escape: 3, initiator: 1, jungler: 0, nuker: 2, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Sven]: { carry: 2, disabler: 2, durable: 2, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Techies]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.TemplarAssassin]: { carry: 2, disabler: 0, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 0, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Terrorblade]: { carry: 3, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 2, ranged: 0, healer: 0 },
    [HeroName.Tidehunter]: { carry: 1, disabler: 2, durable: 3, escape: 0, initiator: 3, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Tinker]: { carry: 1, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 2, pusher: 2, ranged: 1, healer: 0 },
    [HeroName.Tiny]: { carry: 3, disabler: 1, durable: 2, escape: 0, initiator: 2, jungler: 0, nuker: 2, support: 0, pusher: 2, ranged: 0, healer: 0 },
    [HeroName.TreantProtector]: { carry: 0, disabler: 1, durable: 1, escape: 1, initiator: 2, jungler: 0, nuker: 0, support: 3, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.TrollWarlord]: { carry: 3, disabler: 1, durable: 1, escape: 0, initiator: 0, jungler: 0, nuker: 0, support: 0, pusher: 1, ranged: 1, healer: 0 },
    [HeroName.Tusk]: { carry: 0, disabler: 2, durable: 0, escape: 0, initiator: 2, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Undying]: { carry: 0, disabler: 1, durable: 2, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.Ursa]: { carry: 2, disabler: 1, durable: 1, escape: 0, initiator: 0, jungler: 1, nuker: 0, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.VengefulSpirit]: { carry: 0, disabler: 2, durable: 0, escape: 1, initiator: 2, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Venomancer]: { carry: 1, disabler: 1, durable: 0, escape: 0, initiator: 1, jungler: 0, nuker: 1, support: 2, pusher: 1, ranged: 1, healer: 0 },
    [HeroName.Viper]: { carry: 3, disabler: 1, durable: 2, escape: 0, initiator: 1, jungler: 0, nuker: 0, support: 0, pusher: 1, ranged: 1, healer: 0 },
    [HeroName.Visage]: { carry: 1, disabler: 1, durable: 1, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 1, pusher: 1, ranged: 1, healer: 0 },
    [HeroName.VoidSpirit]: { carry: 2, disabler: 1, durable: 0, escape: 3, initiator: 1, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 0, healer: 0 },
    [HeroName.Warlock]: { carry: 1, disabler: 1, durable: 1, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.Weaver]: { carry: 2, disabler: 0, durable: 0, escape: 3, initiator: 0, jungler: 0, nuker: 1, support: 0, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Windrunner]: { carry: 3, disabler: 1, durable: 0, escape: 1, initiator: 0, jungler: 0, nuker: 1, support: 2, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.WinterWyvern]: { carry: 1, disabler: 2, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.IO]: { carry: 0, disabler: 0, durable: 0, escape: 2, initiator: 0, jungler: 0, nuker: 0, support: 1, pusher: 0, ranged: 0, healer: 1 },
    [HeroName.WitchDoctor]: { carry: 0, disabler: 1, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 2, support: 3, pusher: 0, ranged: 1, healer: 1 },
    [HeroName.Zeus]: { carry: 1, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 3, support: 1, pusher: 0, ranged: 1, healer: 0 },
    [HeroName.Kez]: { carry: 1, disabler: 0, durable: 0, escape: 0, initiator: 0, jungler: 0, nuker: 1, support: 1, pusher: 0, ranged: 0, healer: 0 },
};

export const InvisHeroes: { [key: string]: number } = {
    [HeroName.PhantomAssassin]: 1,
    [HeroName.Clinkz]: 1,
    [HeroName.Mirana]: 1,
    [HeroName.Riki]: 1,
    [HeroName.NyxAssassin]: 1,
    [HeroName.BountyHunter]: 1,
    [HeroName.Invoker]: 1,
    [HeroName.SandKing]: 1,
    [HeroName.TreantProtector]: 1,
    [HeroName.Weaver]: 1,
    // [HeroName.Broodmother]: 1,
};

export function HasRole(hero: HeroName, role: keyof HeroRoles): boolean {
    const roles = HeroRolesMap[hero];
    if (roles == null) return false;
    return roles[role] > 0;
}

export function IsCarry(hero: HeroName) {
    return HasRole(hero, "carry");
}
export function IsDisabler(hero: HeroName) {
    return HasRole(hero, "disabler");
}
export function IsDurable(hero: HeroName) {
    return HasRole(hero, "durable");
}
export function HasEscape(hero: HeroName) {
    return HasRole(hero, "escape");
}
export function IsInitiator(hero: HeroName) {
    return HasRole(hero, "initiator");
}
export function IsJungler(hero: HeroName) {
    return HasRole(hero, "jungler");
}
export function IsNuker(hero: HeroName) {
    return HasRole(hero, "nuker");
}
export function IsSupport(hero: HeroName) {
    return HasRole(hero, "support");
}
export function IsPusher(hero: HeroName) {
    return HasRole(hero, "pusher");
}
export function IsRanged(hero: HeroName) {
    return HasRole(hero, "ranged");
}
export function IsHealer(hero: HeroName) {
    return HasRole(hero, "healer");
}
