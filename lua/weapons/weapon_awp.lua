AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

local function FloatEquals(x,y)
	return math.abs(x-y) < 1.19209290E-07
end

--Jvs: I wish this weapon defining shit was this easy
CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed"			"210"
	"WeaponType" 			"SniperRifle"
	"FullAuto"				0
	"WeaponPrice"			"4750"
	"WeaponArmorRatio"		"1.95"
	"CrosshairMinDistance"		"8"
	"CrosshairDeltaDistance"	"3"
	"Team"				"ANY"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension" 	"awp"
	"MuzzleFlashScale"		"1.35"

	"CanEquipWithShield"		"0"


	// Weapon characteristics:
	"Penetration"			"3"
	"Damage"			"115"
	"Range"				"8192"
	"RangeModifier"			"0.99"
	"Bullets"			"1"
	"CycleTime"			"1.5"	// 1.455
	"AccuracyDivisor"		"-1"
	"AccuracyOffset"		"0"
	"MaxInaccuracy"			"0"
	"TimeToIdle"			"2"
	"IdleInterval"			"60"

	// New accuracy model parameters
	"Spread"					0.00020
	"InaccuracyCrouch"			0.06060
	"InaccuracyStand"			0.08080
	"InaccuracyJump"			0.54600
	"InaccuracyLand"			0.05460
	"InaccuracyLadder"			0.13650
	"InaccuracyFire"			0.14000
	"InaccuracyMove"			0.27300

	"SpreadAlt"					0.00020
	"InaccuracyCrouchAlt"		0.00150
	"InaccuracyStandAlt"		0.00200
	"InaccuracyJumpAlt"			0.54600
	"InaccuracyLandAlt"			0.05460
	"InaccuracyLadderAlt"		0.13650
	"InaccuracyFireAlt"			0.14000
	"InaccuracyMoveAlt"			0.27300

	"RecoveryTimeCrouch"		0.24671
	"RecoveryTimeStand"			0.34539

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_AWP"
	"viewmodel"			"models/weapons/v_snip_awp.mdl"
	"playermodel"			"models/weapons/w_snip_awp.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"10"

	"primary_ammo"			"BULLET_PLAYER_338MAG"
	"secondary_ammo"		"None"

	"weight"			"30"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Weapon_AWP.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_AWP.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"R"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"R"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"W"
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
			Mins	"-11 -3 -12"
			Maxs	"32 10 0"
		}
		World
		{
			Mins	"-12 -6 -15"
			Maxs	"38 9 15"
		}
	}
}]] )

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
		return 0.5
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
