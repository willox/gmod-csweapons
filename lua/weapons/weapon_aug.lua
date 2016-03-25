AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed"		"221"
	"WeaponType"			"Rifle"
	"FullAuto"				1
	"WeaponPrice"			"3500"
	"WeaponArmorRatio"		"1.4"
	"CrosshairMinDistance"		"3"
	"CrosshairDeltaDistance"	"3"
	"Team"				"CT"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension"	"aug"
	"MuzzleFlashScale"		"1.3"
	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
	"CanEquipWithShield"		"0"
	
	
	// Weapon characteristics:
	"Penetration"			"2"
	"Damage"			"32"
	"Range"				"8192"
	"RangeModifier"			"0.96"
	"Bullets"			"1"
	"CycleTime"			"0.09"
	"AccuracyDivisor"		"215"
	"AccuracyOffset"		"0.3"
	"MaxInaccuracy"			"1.0"
	"TimeToIdle"			"1.9"
	"IdleInterval"			"20"
	
	// New accuracy model parameters
	"Spread"					0.00060
	"InaccuracyCrouch"			0.00412
	"InaccuracyStand"			0.00549
	"InaccuracyJump"			0.36936
	"InaccuracyLand"			0.07387
	"InaccuracyLadder"			0.09234
	"InaccuracyFire"			0.01090
	"InaccuracyMove"			0.07268
								 
	"SpreadAlt"					0.00060
	"InaccuracyCrouchAlt"		0.00288
	"InaccuracyStandAlt"		0.00385
	"InaccuracyJumpAlt"			0.36936
	"InaccuracyLandAlt"			0.07387
	"InaccuracyLadderAlt"		0.09234
	"InaccuracyFireAlt"			0.01090
	"InaccuracyMoveAlt"			0.07268
								 
	"RecoveryTimeCrouch"		0.30263
	"RecoveryTimeStand"			0.42368
	
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_Aug"
	"viewmodel"			"models/weapons/v_rif_aug.mdl"
	"playermodel"			"models/weapons/w_rif_aug.mdl"
	
	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"30"
	
	"primary_ammo"			"BULLET_PLAYER_762MM"
	"secondary_ammo"		"None"

	"weight"			"25"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Default.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_AUG.Single"
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"E"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"E"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"V"
		}
		"zoom"
		{
				"file"		"sprites/crosshairs"
				"x"			"0"
				"y"			"48"
				"width"		"24"
				"height"	"24"
		}
		"autoaim"
		{
				"file"		"sprites/crosshairs"
				"x"			"0"
				"y"			"48"
				"width"		"24"
				"height"	"24"
		}
	}
	ModelBounds
	{
		Viewmodel
		{
			Mins	"-9 -3 -15"
			Maxs	"25 12 -1"
		}
		World
		{
			Mins	"-11 -1 -5"
			Maxs	"23 4 10"
		}
	}
}]] )

SWEP.Spawnable = true
SWEP.Slot = 0

function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "ar2" )
	self:SetWeaponID( CS_WEAPON_P90 )
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryAttack() > CurTime() then return end

	self:GunFire( self:BuildSpread() )
end

function SWEP:GunFire( spread )

	if not self:BaseGunFire( spread, self:GetWeaponInfo().CycleTime, true ) then
		return
	end

	if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
		self:KickBack( 0.45, 0.3, 0.2, 0.0275, 4, 2.25, 7 )
	elseif not self:GetOwner():OnGround() then
		self:KickBack( 0.9, 0.45, 0.35, 0.04, 5.25, 3.5, 4 )
	elseif self:GetOwner():Crouching() then
		self:KickBack( 0.275, 0.2, 0.125, 0.02, 3, 1, 9 )
	else
		self:KickBack( 0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8 )
	end
end

SWEP.AdminOnly = true
