AddCSLuaFile()
local function FloatEquals(x,y)
	return math.abs(x-y) < 1.19209290E-07
end

DEFINE_BASECLASS "weapon_csbasegun"

CSParseWeaponInfo(SWEP, [[WeaponData
{
	"MaxPlayerSpeed" 		"260"
	"WeaponType" 			"SniperRifle"
	"FullAuto"				0
	"WeaponPrice"			"2750"
	"WeaponArmorRatio"		"1.7"
	"CrosshairMinDistance"		"5"
	"CrosshairDeltaDistance"	"3"
	"Team"				"ANY"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension"	"scout"
	"MuzzleFlashScale"		"1.1"

	"CanEquipWithShield"		"0"


	// Weapon characteristics:
	"Penetration"			"3"
	"Damage"			"75"
	"Range"				"8192"
	"RangeModifier"			"0.98"
	"Bullets"			"1"
	"CycleTime"			"1.25"
	"AccuracyDivisor"		"-1"
	"AccuracyOffset"		"0"
	"MaxInaccuracy"			"0"
	"TimeToIdle"			"1.8"
	"IdleInterval"			"60"

	// New accuracy model parameters
	"Spread"					0.00030
	"InaccuracyCrouch"			0.02378
	"InaccuracyStand"			0.03170
	"InaccuracyJump"			0.38195
	"InaccuracyLand"			0.03819
	"InaccuracyLadder"			0.09549
	"InaccuracyFire"			0.06667
	"InaccuracyMove"			0.19097

	"SpreadAlt"					0.00030
	"InaccuracyCrouchAlt"		0.00300
	"InaccuracyStandAlt"		0.00400
	"InaccuracyJumpAlt"			0.38195
	"InaccuracyLandAlt"			0.03819
	"InaccuracyLadderAlt"		0.09549
	"InaccuracyFireAlt"			0.06667
	"InaccuracyMoveAlt"			0.19097

	"RecoveryTimeCrouch"		0.17681
	"RecoveryTimeStand"			0.24753

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_Scout"
	"viewmodel"			"models/weapons/v_snip_scout.mdl"
	"playermodel"			"models/weapons/w_snip_scout.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"10"

	"primary_ammo"			"BULLET_PLAYER_762MM"
	"secondary_ammo"		"None"

	"weight"			"30"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Weapon_AWP.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_Scout.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"N"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"N"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"V"
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
			Mins	"-12 -4 -11"
			Maxs	"27 12 -1"
		}
		World
		{
			Mins	"-10 -4 -13"
			Maxs	"32 8 12"
		}
	}
}]])


SWEP.Spawnable = true
SWEP.Slot = 0

function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "ar2" )
	self:SetWeaponID( CS_WEAPON_AWP )
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

	if (self:IsScoped()) then
		self:SetLastZoom(self:GetTargetFOVRatio());

		self:SetResumeZoom(true);
		self:SetFOVRatio( 1, 0.1 );
	end

	local a = self:GetOwner():GetViewPunchAngles( )
	a.p = a.p - 2
	self:GetOwner():SetViewPunchAngles( a )
end
