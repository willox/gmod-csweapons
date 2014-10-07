CS_WEAPON_P228 =			1
CS_WEAPON_GLOCK =			2
CS_WEAPON_SCOUT =			3
CS_WEAPON_HEGRENADE =		4
CS_WEAPON_XM1014 =			5
CS_WEAPON_C4 =				6
CS_WEAPON_MAC10 =			7
CS_WEAPON_AUG =				8
CS_WEAPON_SMOKEGRENADE =	9
CS_WEAPON_ELITE =			10
CS_WEAPON_FIVESEVEN =		11
CS_WEAPON_UMP45 =			12
CS_WEAPON_SG550 =			13
CS_WEAPON_GALIL =			14
CS_WEAPON_FAMAS =			15
CS_WEAPON_USP =				16
CS_WEAPON_AWP =				17
CS_WEAPON_MP5NAVY =			18
CS_WEAPON_M249 =			19
CS_WEAPON_M3 =				20
CS_WEAPON_M4A1 =			21
CS_WEAPON_TMP =				22
CS_WEAPON_G3SG1 =			23
CS_WEAPON_FLASHBANG =		24
CS_WEAPON_DEAGLE =			25
CS_WEAPON_SG552 =			26
CS_WEAPON_AK47 =			27
CS_WEAPON_KNIFE =			28
CS_WEAPON_P90 =				29

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

CS_HEGRENADE = 		"AMMO_TYPE_HEGRENADE"
CS_FLASHBANG = 		"AMMO_TYPE_FLASHBANG"
CS_SMOKEGRENADE = 	"AMMO_TYPE_SMOKEGRENADE"

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

game.AddAmmoType {
	name = CS_HEGRENADE,
	dmgtype = DMG_BLAST,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 0,
	minsplash = 0,
	maxsplash = 0
}

game.AddAmmoType {
	name = CS_FLASHBANG,
	dmgtype = DMG_BLAST,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 0,
	minsplash = 0,
	maxsplash = 0
}

game.AddAmmoType {
	name = CS_FLASHBANG,
	dmgtype = DMG_BLAST,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 0,
	minsplash = 0,
	maxsplash = 0
}

--[[
	load the keyvalues from a string and parses it
	
	NOTE:	this function should be called right after AddCSLuaFile() on the SWEP object
			see ak47
]]

local wepinfo_meta = {
	MaxPlayerSpeed = 1,
	WeaponPrice = -1,

	WeaponArmorRatio = 1,
	CrosshairMinDistance = 4,
	CrosshairDeltaDistance = 3,
	CanEquipWithShield = false,
	MuzzleFlashScale = 1,
	MuzzleFlashStyle = "CS_MUZZLEFLASH_NORM",

	Penetration = 1,
	Damage = 42,
	Range = 8192,
	RangeModifier = 0.98,
	Bullets = 1,
	CycleTime = 0.15,
	AccuracyQuadratic = 0,
	AccuracyDivisor = -1,
	AccuracyOffset = 0,
	MaxInaccuracy = 0,

	TimeToIdle = 2,
	IdleInterval = 20,

	TEAM = "ANY",

	shieldviewmodel = "",
	PlayerAnimationExtension = "m4",
	BotAudibleRange = 2000,
	WeaponType = 0
}

wepinfo_meta.__index = wepinfo_meta

if CLIENT then
	CS_KILLICON_FONT = "CSTypeDeath"
	
	surface.CreateFont( CS_KILLICON_FONT ,
	{
		font		= "csd",
		size		= ScreenScale( 20 ),
		antialias	= true,
		weight		= 300
	})
	
end

function CSParseWeaponInfo( self,  str )
	local class = self.Folder:Replace( ".lua" , "" )
	class = class:Replace( "weapons/" , "" )
	local wepinfotab = util.KeyValuesToTable( str, nil , true )
	
	--Jvs: should never happen, but you never know with garry's baseclass stuff
	
	if not wepinfotab then
		wepinfotab = {}
	end
	
	setmetatable( wepinfotab, wepinfo_meta )
	
	self._WeaponInfo = wepinfotab
	self.PrintName = self._WeaponInfo.printname
	
	self.CSMuzzleFlashes = true
	
	if self._WeaponInfo.MuzzleFlashStyle == "CS_MUZZLEFLASH_X" then
		self.CSMuzzleX = true
	end
	
	self.Primary.Automatic = tobool( tonumber( self._WeaponInfo.FullAuto ) )
	self.Primary.ClipSize = self._WeaponInfo.clip_size
	self.Primary.Ammo = self._WeaponInfo.primary_ammo
	self.Primary.DefaultClip = 0
	
	self.Secondary.Automatic = false
	self.Secondary.ClipSize = -1
	self.Secondary.DefaultClip = 0
	self.Secondary.Ammo = -1
	
		
	--Jvs: if this viewmodel can't be converted into the corresponding c_ model, apply viewmodel flip as usual
	local convertedvm = self._WeaponInfo.viewmodel:Replace( "/v_" , "/cstrike/c_" )
	
	if file.Exists( convertedvm , "GAME" ) then
		self.ViewModel = convertedvm
	else
		self.ViewModelFlip = self._WeaponInfo.BuiltRightHanded == 0
	end
	
	self.WorldModel = self._WeaponInfo.playermodel
	self.ViewModelFOV = 45
	self.Weight = self._WeaponInfo.weight
	self.m_WeaponDeploySpeed = 1
	if CLIENT then
		if self._WeaponInfo.TextureData then
			killicon.AddFont( class , CS_KILLICON_FONT , self._WeaponInfo.TextureData.weapon.character:lower() , Color( 255, 80, 0, 255 ) )
			if self.ProjectileClass then
				killicon.AddAlias( self.ProjectileClass, class )
			end
		end
	end
end

hook.Add( "SetupMove" , "CSS - Speed Modify" , function( ply , mv , cmd )
	local weapon = ply:GetActiveWeapon()
	
	if IsValid( weapon ) and weapon.CSSWeapon then
		mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * weapon:GetSpeedRatio() )
	end
end)