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

function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "shotgun" )
	self:SetWeaponID( CS_WEAPON_M3 )
end

function SWEP:PrimaryAttack()
	
	if self:GetNextPrimaryAttack() > CurTime() then return end
	
	local owner = self:GetOwner()
	if owner:WaterLevel()==3 then
		self:PlayEmptySound()
		self:SetNextPrimaryAttack( CurTime() + 0.2 )
		return false
	end
	
		-- Out of ammo?
	if self:Clip1() <= 0 then
		self:PlayEmptySound()
		self:SetNextPrimaryAttack( CurTime() + 0.2 )
		return false
	end


	local ply = self:GetOwner()
	local pCSInfo = self:GetWeaponInfo()
	local iDamage = pCSInfo.Damage
	local flRangeModifier = pCSInfo.RangeModifier
	local soundType = "single_shot"


	self:SendWeaponAnim( self:TranslateViewModelActivity( ACT_VM_PRIMARYATTACK ) )

	self:SetClip1( self:Clip1() -1 )

	-- player "shoot" animation
	ply:DoAttackEvent()

	ply:FireBullets {
		Attacker = ply,
		AmmoType = self.Primary.Ammo,
		Distance = pCSInfo.Range,
		Tracer = 1,
		Damage = iDamage,
		Src = ply:GetShootPos(),
		Dir = dir,
		Spread = vector_origin,
		Callback = function( hitent , trace , dmginfo )
			--TODO: penetration
			--unfortunately this can't be done with a static function or we'd need to set global variables for range and shit
			
			if flRangeModifier then
				--Jvs: the damage modifier valve actually uses
				local flCurrentDistance = trace.Fraction * pCSInfo.Range
				dmginfo:SetDamage( dmginfo:GetDamage() * math.pow( flRangeModifier, ( flCurrentDistance / 500 ) ) )
			end
		end
	}


	self:DoFireEffects()
	local cycletime = .875
	
	self:SetNextPrimaryAttack( CurTime() + cycletime )
	self:SetNextSecondaryAttack( CurTime() + cycletime )

	if self:Clip1() ~= 0 then
		self:SetNextIdle( CurTime() + 2.5 )
	else
		self:SetNextIdle( CurTime() + cycletime )
	end
	
	self:SetLastFire( CurTime() )


	local angle = self:GetOwner():GetViewPunchAngles()

	
	-- Update punch angles.
	if not self:GetOwner():OnGround() then
		
		
		angle.x = angle.x - util.SharedRandom( "M3PunchAngleGround" , 4, 6 ) 
	
	else
	
		
		angle.x = angle.x - util.SharedRandom( "M3PunchAngle" , 8, 11 ) 
	
	end

	self:GetOwner():SetViewPunchAngles( angle )

	return true

end


SWEP.AdminOnly = true
