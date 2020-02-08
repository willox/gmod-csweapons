AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed" 		"220"
	"WeaponType"			"Shotgun"
	"FullAuto"				1
	"WeaponPrice"			"1700"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"8"
	"CrosshairDeltaDistance"	"6"
	"Team"				"ANY"
	"BuiltRightHanded"		"0"
	"PlayerAnimationExtension" 	"m3s90"
	"MuzzleFlashScale"		"1.3"

	"CanEquipWithShield"		"0"


	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"26"
	"Range"				"3000"
	"RangeModifier"			"0.70"
	"Bullets"			"9"
	"CycleTime"			"0.88"

	// New accuracy model parameters
	"Spread"					0.04000
	"InaccuracyCrouch"			0.00750
	"InaccuracyStand"			0.01000
	"InaccuracyJump"			0.42000
	"InaccuracyLand"			0.08400
	"InaccuracyLadder"			0.07875
	"InaccuracyFire"			0.04164
	"InaccuracyMove"			0.04320

	"RecoveryTimeCrouch"		0.29605
	"RecoveryTimeStand"			0.41447

	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_m3"
	"viewmodel"			"models/weapons/v_shot_m3super90.mdl"
	"playermodel"			"models/weapons/w_shot_m3super90.mdl"

	"anim_prefix"			"anim"
	"bucket"			"0"
	"bucket_position"		"0"

	"clip_size"			"8"

	"primary_ammo"			"BULLET_PLAYER_BUCKSHOT"
	"secondary_ammo"		"None"

	"weight"			"20"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Default.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_M3.Single"
		special3			Default.Zoom
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"K"
		}
		"weapon_s"
		{
				"font"		"CSweapons"
				"character"	"K"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"J"
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
			Mins	"-13 -3 -13"
			Maxs	"26 10 -3"
		}
		World
		{
			Mins	"-9 -8 -5"
			Maxs	"28 9 9"
		}
	}
}]] )


SWEP.Spawnable = true
SWEP.Slot = 0
SWEP.SlotPos = 0

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:NetworkVar( "Int", 0, "SpecialReload" )
end

function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "shotgun" )
	self:SetWeaponID( CS_WEAPON_M3 )
	self:SetSpecialReload( 0 )
end

function SWEP:PrimaryAttack()
	local pPlayer = self.Owner
	if not IsValid( pPlayer ) then return end

	if self:GetNextPrimaryAttack() > CurTime() then return end

	if pPlayer:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryAttack( CurTime() + 0.2 )
		return false
	end

	local spread = self:BuildSpread()
	if not self:BaseGunFire( spread, self:GetWeaponInfo().CycleTime, true ) then
		return
	end

	self:SetSpecialReload( 0 )

	local angle = pPlayer:GetViewPunchAngles()
	-- Update punch angles.
	if not pPlayer:OnGround() then
		angle.x = angle.x - util.SharedRandom( "M3PunchAngleGround" , 4, 6 )
	else
		angle.x = angle.x - util.SharedRandom( "M3PunchAngle" , 8, 11 )
	end
	pPlayer:SetViewPunchAngles( angle )

	return true
end

function SWEP:Reload()
	local pPlayer = self.Owner
	if not IsValid( pPlayer ) then return end
	
	if pPlayer:GetAmmoCount( self.Primary.Ammo ) <= 0 or self:Clip1() >= self.Primary.ClipSize then return end
	if self:GetNextPrimaryAttack() > CurTime() then return end

	if self:GetSpecialReload() == 0 then
		pPlayer:SetAnimation( PLAYER_RELOAD )
		self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
		self:SetSpecialReload( 1 )

		self:SetNextPrimaryAttack( CurTime() + 0.5 )
		self:SetNextIdle( CurTime() + 0.5 )

		-- DoAnimationEvent( PLAYERANIMEVENT_RELOAD_START ) - Missing event
		return true
	elseif self:GetSpecialReload() == 1 then
		if self:GetNextIdle() > CurTime() then
			return true
		end

		self:SetSpecialReload( 2 )
		self:SendWeaponAnim( ACT_VM_RELOAD )
		self:SetNextIdle( CurTime() + 0.5 )

		if self:Clip1() >= 7 then
			pPlayer:DoAnimationEvent( PLAYERANIMEVENT_RELOAD_END )
		else
			pPlayer:DoAnimationEvent( PLAYERANIMEVENT_RELOAD_LOOP )
		end
	else
		self:SetClip1( self:Clip1() + 1 )
		pPlayer:DoAnimationEvent( PLAYERANIMEVENT_RELOAD )
		pPlayer:RemoveAmmo( 1, self.Primary.Ammo )
		self:SetSpecialReload( 1 )
	end

	return true
end

function SWEP:Think()
	local pPlayer = self.Owner
	if not IsValid( pPlayer ) then return end

	if self:GetNextIdle() < CurTime() then
		if self:Clip1() == 0 and self:GetSpecialReload() == 0 and pPlayer:GetAmmoCount( self.Primary.Ammo ) ~= 0 then
			self:Reload()
		elseif self:GetSpecialReload() ~= 0 then
			if self:Clip1() ~= self:GetMaxClip1() and pPlayer:GetAmmoCount( self.Primary.Ammo ) ~= 0 then
				self:Reload()
			else
				self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
				self:SetSpecialReload( 0 )
				self:SetNextIdle( CurTime() + 1.5 )
			end
		else
			self:SendWeaponAnim( ACT_VM_IDLE )
		end
	end
end
SWEP.AdminOnly = false