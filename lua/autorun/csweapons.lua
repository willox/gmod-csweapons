CS_WEAPONTYPE_KNIFE = 			0
CS_WEAPONTYPE_PISTOL = 			1
CS_WEAPONTYPE_SUBMACHINEGUN = 	2
CS_WEAPONTYPE_RIFLE = 			3
CS_WEAPONTYPE_SHOTGUN = 		4
CS_WEAPONTYPE_SNIPER_RIFLE = 	5
CS_WEAPONTYPE_MACHINEGUN = 		6
CS_WEAPONTYPE_C4 = 				7
CS_WEAPONTYPE_GRENADE = 		8
CS_WEAPONTYPE_UNKNOWN = 		9

CS_50AE = 		"BULLET_PLAYER_50AE"
CS_762MM = 		"BULLET_PLAYER_762MM"
CS_556MM = 		"BULLET_PLAYER_556MM"
CS_556MM_BOX = 	"BULLET_PLAYER_556MM_BOX"
CS_338MAG = 	"BULLET_PLAYER_338MAG"
CS_9MM = 		"BULLET_PLAYER_9MM"
CS_BUCKSHOT = 	"BULLET_PLAYER_BUCKSHOT"
CS_45ACP = 		"BULLET_PLAYER_45ACP"
CS_357SIG = 	"BULLET_PLAYER_357SIG"
CS_57MM = 		"BULLET_PLAYER_57MM"

CS_MAX_50AE = 		35
CS_MAX_762MM = 		90
CS_MAX_556MM = 		90
CS_MAX_556M_BOX = 	200
CS_MAX_338MAG = 	30
CS_MAX_9MM = 		120
CS_MAX_BUCKSHOT = 	32
CS_MAX_45ACP = 		100
CS_MAX_356SIG = 	52
CS_MAX_57MM = 		100

-- CS_HEGRENADE = 		"AMMO_TYPE_HEGRENADE"
-- CS_FLASHBANG = 		"AMMO_TYPE_FLASHBANG"
-- CS_SMOKEGRENADE = 	"AMMO_TYPE_SMOKEGRENADE"

game.AddAmmoType {
	name = CS_50AE,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
}

game.AddAmmoType {
	name = CS_762MM,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
}

game.AddAmmoType {
	name = CS_556MM,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
}

game.AddAmmoType {
	name = CS_556MM_BOX,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
}

game.AddAmmoType {
	name = CS_338MAG,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2800,
	minsplash = 12,
	maxsplash = 16
}

game.AddAmmoType {
	name = CS_9MM,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 5,
	maxsplash = 10
}

game.AddAmmoType {
	name = CS_BUCKSHOT,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 600,
	minsplash = 3,
	maxsplash = 6
}

game.AddAmmoType {
	name = CS_45ACP,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2100,
	minsplash = 6,
	maxsplash = 10
}

game.AddAmmoType {
	name = CS_357SIG,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 4,
	maxsplash = 8
}

game.AddAmmoType {
	name = CS_57MM,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 4,
	maxsplash = 8
}

--[[
	load the keyvalues from a string and parses it
	
	NOTE:	this function should be called right after AddCSLuaFile() on the SWEP object
			see ak47
]]

function CSParseWeaponInfo( self,  str )
	
	local wepinfotab = util.KeyValuesToTable( str, nil , true )
	
	self._WeaponInfo = wepinfotab
	
	--[[
		Jvs: have fun Willox, I can't be arsed
		game/shared/cstrike/cs_weapon_parse.cpp
		void CCSWeaponInfo::Parse( KeyValues *pKeyValuesData, const char *szWeaponName )
	]]
	
	
	self.PrintName = self._WeaponInfo.printname
	
	self.CSMuzzleFlashes = true
	
	if self._WeaponInfo.MuzzleFlashStyle == "CS_MUZZLEFLASH_X" then
		self.CSMuzzleX = true
	end
	
	self.Primary.Automatic = self._WeaponInfo.FullAuto
	self.Primary.ClipSize = self._WeaponInfo.clip_size
	self.Primary.Ammo = self._WeaponInfo.primary_ammo
	self.Primary.DefaultClip = 0
	
	self.Secondary.Automatic = false
	self.Secondary.ClipSize = -1
	self.Secondary.DefaultClip = 0
	self.Secondary.Ammo = -1
	
	--self.ViewModelFlip = self._WeaponInfo.BuiltRightHanded == 0
	self.ViewModelFOV = 45
	
	--TODO: when setting the viewmodel string, automatically convert it to the c_ model , willox pls, I'm not good with regex
	self.ViewModel = self._WeaponInfo.viewmodel
	self.ViewModel = self.ViewModel:Replace( "/v_" , "/cstrike/c_" ) 
	
	self.WorldModel = self._WeaponInfo.playermodel
	
	self.Weight = self._WeaponInfo.weight
end