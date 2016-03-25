AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed"		"250"
	"WeaponType"			"C4"
	"WeaponPrice"			"0"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"6"
	"CrosshairDeltaDistance"	"3"
	"Team"				"TERRORIST"
	"BuiltRightHanded" 		"0"
	"PlayerAnimationExtension"	"c4"
	"MuzzleFlashScale"		"1"
	
	"CanEquipWithShield"		"1"
	"AllowFlipping" 		"0"
	
	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"50"
	"Range"				"4096"
	"RangeModifier"			"0.99"
	"Bullets"			"1"
		
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_C4"
	"viewmodel"			"models/weapons/v_c4.mdl"
	"playermodel"			"models/weapons/w_c4.mdl"
	"shieldviewmodel"		"models/weapons/v_c4.mdl"
	"anim_prefix"			"anim"
	"bucket"			"4"
	"bucket_position"		"0"

	"clip_size"			"30"
	
	"primary_ammo"			"None"
	"secondary_ammo"		"None"

	"weight"			"0"
	"item_flags"			"0"

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
				"character"	"\"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"\"
		}
		"ammo"
		{
				"file"		"sprites/640hud1"
				"x"		"182"
				"y"		"24"
				"width"		"26"
				"height"		"24"
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
			Mins	"-4 -8 -17"
			Maxs	"20 13 1"
		}
		World
		{
			Mins	"-3 0 -4"
			Maxs	"7 12 4"
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
