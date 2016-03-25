AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed"		245
	"WeaponType"			"Grenade"
	"WeaponPrice"			"300"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"4"
	"CrosshairDeltaDistance"	"3"
	"Team"				"ANY"
	"BuiltRightHanded" 		"0"
	"PlayerAnimationExtension"	"gren"
	"MuzzleFlashScale"		"1"
	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_NONE"
	"CanEquipWithShield" 		"1"
	"AddonModel"			"models/weapons/w_eq_smokegrenade_thrown.mdl"
		
	// Weapon characteristics:
	"Penetration"			"0"
	"Damage"			"50"
	"Range"				"4096"
	"RangeModifier"			"0.99"
	"Bullets"			"1"
	
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_Smoke_Grenade"
	"viewmodel"			"models/weapons/v_eq_smokegrenade.mdl"
	"playermodel"			"models/weapons/w_eq_smokegrenade.mdl"
	
	"anim_prefix"			"anim"
	"bucket"			"3"
	"bucket_position"		"3"

	"clip_size"			"-1"
	"default_clip"			"1"
	"primary_ammo"			"AMMO_TYPE_SMOKEGRENADE"
	"secondary_ammo"		"None"

	"weight"			"2"
	"ITEM_FLAG_EXHAUSTIBLE"		"1"
// 	"ITEM_FLAG_NOAMMOPICKUPS"	"1"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"P"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"P"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"Q"
		}
		"crosshair"
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
			Mins	"-6 -9 -15"
			Maxs	"15 11 0"
		}
		World
		{
			Mins	"-4 -1 -3"
			Maxs	"3 6 1"
		}
		Addon
		{
			Mins	"-3 -2 -3"
			Maxs	"2 2 4"
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
