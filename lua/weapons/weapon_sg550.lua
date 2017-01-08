AddCSLuaFile()
local function FloatEquals(x,y) return math.abs(x-y) < 1.19209290E-07 end


DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed"		"210"
	"WeaponType"			"SniperRifle"
	"FullAuto"				1
	"WeaponPrice"			"4200"
	"WeaponArmorRatio"		"1.45"
	"CrosshairMinDistance"		"5"
	"CrosshairDeltaDistance"	"3"
	"Team"				"CT"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension"	"sg550"
	"MuzzleFlashScale"		"1.6"
	"MuzzleFlashStyle"		"CS_MUZZLEFLASH_X"
	"CanEquipWithShield"		"0"


	// Weapon characteristics:
	"Penetration"			"2"
	"Damage"			"70"
	"Range"				"8192"
	"RangeModifier"			"0.98"
	"Bullets"			"1"
	"CycleTime"			"0.25"
	"AccuracyDivisor"		"-1"
	"AccuracyOffset"		"0"
	"MaxInaccuracy"			"0"
	"TimeToIdle"			"1.8"
	"IdleInterval"			"60"

	// New accuracy model parameters
	"Spread"					0.00030
	"InaccuracyCrouch"			0.01928
	"InaccuracyStand"			0.02570
	"InaccuracyJump"			0.43727
	"InaccuracyLand"			0.04373
	"InaccuracyLadder"			0.10932
	"InaccuracyFire"			0.03829
	"InaccuracyMove"			0.21864

	"SpreadAlt"					0.00030
	"InaccuracyCrouchAlt"		0.00150
	"InaccuracyStandAlt"		0.00200
	"InaccuracyJumpAlt"			0.43727
	"InaccuracyLandAlt"			0.04373
	"InaccuracyLadderAlt"		0.10932
	"InaccuracyFireAlt"			0.03829
	"InaccuracyMoveAlt"			0.21864

	"RecoveryTimeCrouch"		0.20970
	"RecoveryTimeStand"			0.29358

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_SG550"
	"viewmodel"			"models/weapons/v_snip_sg550.mdl"
	"playermodel"			"models/weapons/w_snip_sg550.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"30"

	"primary_ammo"			"BULLET_PLAYER_556MM"
	"secondary_ammo"		"None"

	"weight"			"20"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Weapon_AWP.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_SG550.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"O"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"O"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"N"
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
			Mins	"-3 -3 -12"
			Maxs	"40 14 -1"
		}
		World
		{
			Mins	"-7 -8 -3"
			Maxs	"32 9 9"
		}
	}
}]] )


SWEP.Spawnable = true
SWEP.Slot = 0
SWEP.SlotPos = 0

function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "ar2" )
	self:SetWeaponID( CS_WEAPON_SG550 )
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
		self:SetFOVRatio( 40/90, 0.15 );
	elseif (FloatEquals(self:GetFOVRatio(), 40/90)) then
		self:SetFOVRatio( 10/90, 0.08 );
	else
		self:SetFOVRatio( 1, 0.1 );
	end

	-- If this isn't guarded, the sound will be emitted twice, once by the server and once by the client.
	-- Let the server play it since if only the client plays it, it's liable to get played twice cause of
	-- a prediction error. joy.
	self:EmitSound("Default.Zoom", nil, nil, nil, CHAN_AUTO);

	self:SetNextSecondaryFire(CurTime() + 0.3);
	self:SetZoomFullyActiveTime(CurTime() + 0.15); -- The worst zoom time from above.

end


function SWEP:AdjustMouseSensitivity()

	if (self:IsScoped()) then

		-- is a hack, maybe change?
		return self:GetCurrentFOVRatio() * GetConVar "zoom_sensitivity_ratio":GetFloat()

	end
end

function SWEP:IsScoped()
	return self:GetTargetFOVRatio() ~= 1
end

function SWEP:HandleReload()

	self:SetFOVRatio(1, 0.05)

end

function SWEP:GetSpeedRatio()

	if (self:IsScoped()) then
		return 220/260
	end

	return 1

end

function SWEP:GunFire( spread )

	local pPlayer = self:GetOwner()

	if (CurTime() < self:GetZoomFullyActiveTime()) then

		self:SetNextPrimaryAttack(self:GetZoomFullyActiveTime())
		return

	end

	if (not self:IsScoped()) then
		spread = spread + .08
	end

	if not self:BaseGunFire( spread, self:GetWeaponInfo().CycleTime, true ) then
		return
	end

	local a = self:GetOwner():GetViewPunchAngles( )
	a.p = a.p - 2
	self:GetOwner():SetViewPunchAngles( a )
end


SWEP.AdminOnly = true
