AddCSLuaFile()
local function FloatEquals(x,y)
	return math.abs(x-y) < 1.19209290E-07
end

DEFINE_BASECLASS "weapon_csbasegun"

CSParseWeaponInfo(SWEP, [[WeaponData
{
	"MaxPlayerSpeed"		"235"
	"WeaponType"			"Rifle"
	"FullAuto"				1
	"WeaponPrice"			"3500"
	"WeaponArmorRatio"		"1.4"
	"CrosshairMinDistance"		"5"
	"CrosshairDeltaDistance"	"3"
	"Team"				"TERRORIST"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension"	"sg552"
	"MuzzleFlashScale"		"1.3"
	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
	"CanEquipWithShield"		"0"


	// Weapon characteristics:
	"Penetration"			"2"
	"Damage"			"33"
	"Range"				"8192"
	"RangeModifier"			"0.955"
	"Bullets"			"1"
	"CycleTime"			"0.09"
	"AccuracyDivisor"		"220"
	"AccuracyOffset"		"0.3"
	"MaxInaccuracy"			"1.0"
	"TimeToIdle"			"2"
	"IdleInterval"			"20"

	// New accuracy model parameters
	"Spread"					0.00060
	"InaccuracyCrouch"			0.00405
	"InaccuracyStand"			0.00540
	"InaccuracyJump"			0.33464
	"InaccuracyLand"			0.06693
	"InaccuracyLadder"			0.08366
	"InaccuracyFire"			0.01227
	"InaccuracyMove"			0.06132

	"SpreadAlt"					0.00060
	"InaccuracyCrouchAlt"		0.00284
	"InaccuracyStandAlt"		0.00378
	"InaccuracyJumpAlt"			0.33464
	"InaccuracyLandAlt"			0.06693
	"InaccuracyLadderAlt"		0.08366
	"InaccuracyFireAlt"			0.00859
	"InaccuracyMoveAlt"			0.06132

	"RecoveryTimeCrouch"		0.27631
	"RecoveryTimeStand"			0.38683

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_SG552"
	"viewmodel"			"models/weapons/v_rif_sg552.mdl"
	"playermodel"			"models/weapons/w_rif_sg552.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"30"

	"primary_ammo"			"BULLET_PLAYER_556MM"
	"secondary_ammo"		"None"

	"weight"			"25"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Weapon_AWP.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_SG552.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"["
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"["
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"N"
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
			Mins	"-7 -2 -15"
			Maxs	"30 11 -1"
		}
		World
		{
			Mins	"-10 -8 -4"
			Maxs	"25 8 9"
		}
	}
}]])

SWEP.Spawnable = true
SWEP.Slot = 0

function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "ar2" )
	self:SetWeaponID( CS_WEAPON_AK47 )
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryAttack() > CurTime() then return end

	self:GunFire(self:BuildSpread())
end

function SWEP:SecondaryAttack()
	local pPlayer = self:GetOwner();

	if not IsValid(pPlayer) then
		return;
	end
	if (self:GetZoomFullyActiveTime() > CurTime() or self:GetNextPrimaryAttack() > CurTime()) then
		self:SetNextSecondaryFire(self:GetZoomFullyActiveTime() + 0.15)
		return
	end

	if ( not self:IsScoped() ) then
		self:SetFOVRatio( 55/90, 0.2 );
	elseif (FloatEquals(self:GetFOVRatio(), 55/90)) then
		self:SetFOVRatio( 1, 0.08 );
	else
		--FIXME: This seems wrong
		self:SetFOVRatio( 1, 0);
	end

	self:SetNextSecondaryFire(CurTime() + 0.3);
	self:SetZoomFullyActiveTime(CurTime() + 0.2); -- The worst zoom time from above.

end

function SWEP:IsScoped()
	return self:GetFOVRatio() ~= 1
end

function SWEP:HandleReload()
	self:SetFOVRatio(1, 0.05)
end

function SWEP:GunFire( spread )

	local flCycleTime = self:GetWeaponInfo().CycleTime

	if self:IsScoped() then
		flCycleTime = 0.135
	end

	if not self:BaseGunFire( spread, flCycleTime, true ) then
		return
	end

	--Jvs: this is so goddamn lame

	if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
		self:KickBack(1, 0.45, 0.28, 0.04, 4.25, 2.5, 7);
	elseif not self:GetOwner():OnGround() then
		self:KickBack(1.25, 0.45, 0.22, 0.18, 6, 4, 5);
	elseif self:GetOwner():Crouching() then
		self:KickBack(0.6, 0.35, 0.2, 0.0125, 3.7, 2, 10);
	else
		self:KickBack(0.625, 0.375, 0.25, 0.0125, 4, 2.25, 9);
	end
end
