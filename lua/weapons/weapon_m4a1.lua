AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed" 		"230" 
	"WeaponType" 			"Rifle"
	"FullAuto"				1
	"WeaponPrice" 			"3100"
	"WeaponArmorRatio" 		"1.4"
	"CrosshairMinDistance" 		"4"
	"CrosshairDeltaDistance" 	"3"
	"Team" 				"CT"
	"BuiltRightHanded" 		"0"
	"PlayerAnimationExtension" 	"m4"
	"MuzzleFlashScale"		"1.6"
	
	"CanEquipWithShield"		"0"
	
	
	// Weapon characteristics:
	"Penetration"			"2"
	"Damage"			"33"
	"Range"				"8192"
	"RangeModifier"			"0.97"
	"Bullets"			"1"
	"CycleTime"			"0.09"
	"AccuracyDivisor"		"220"
	"AccuracyOffset"		"0.3"
	"MaxInaccuracy"			"1.0"
	"TimeToIdle"			"1.5"
	"IdleInterval"			"60"
	
	// New accuracy model parameters
	"Spread"					0.00060
	"InaccuracyCrouch"			0.00525
	"InaccuracyStand"			0.00700
	"InaccuracyJump"			0.34151
	"InaccuracyLand"			0.06830
	"InaccuracyLadder"			0.08538
	"InaccuracyFire"			0.01266
	"InaccuracyMove"			0.06872
								 
	"SpreadAlt"					0.00054
	"InaccuracyCrouchAlt"		0.00525
	"InaccuracyStandAlt"		0.00700
	"InaccuracyJumpAlt"			0.34846
	"InaccuracyLandAlt"			0.06969
	"InaccuracyLadderAlt"		0.08712
	"InaccuracyFireAlt"			0.01165
	"InaccuracyMoveAlt"			0.07039
								 
	"RecoveryTimeCrouch"		0.26973
	"RecoveryTimeStand"			0.37762
	
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_M4A1"
	"viewmodel"			"models/weapons/v_rif_m4a1.mdl"
	"playermodel"			"models/weapons/w_rif_m4a1.mdl"
	"SilencerModel"			"models/weapons/w_rif_m4a1_silencer.mdl"
	
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
		"single_shot"		"Weapon_M4A1.Single"
		"special1"			"Weapon_M4A1.Silenced"
		"special2"			"Weapon_M4A1.Silencer_Off"
		"special3"			"Weapon_M4A1.Silencer_On"
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"W"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"W"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"N"
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
			Mins	"-10 -2 -13"
			Maxs	"30 10 0"
		}
		World
		{
			Mins	"-8 -9 -6"
			Maxs	"29 9 8"
		}
	}
}]] )

SWEP.Spawnable = true

SWEP.SilencedTranslation = {
	[ACT_VM_RELOAD] = ACT_VM_RELOAD_SILENCED,
	[ACT_VM_PRIMARYATTACK] = ACT_VM_PRIMARYATTACK_SILENCED,
	[ACT_VM_DRAW] = ACT_VM_DRAW_SILENCED,
	[ACT_VM_IDLE] = ACT_VM_IDLE_SILENCED,
}


function SWEP:Initialize()
	BaseClass.Initialize( self )
	self:SetHoldType( "ar2" )
	self:SetWeaponID( CS_WEAPON_M4A1 )
	self:SetDoneSwitchingSilencer( 0 )
	self:SetDelayFire( true )
end

function SWEP:Deploy()
	local ret = BaseClass.Deploy( self )
	self:SetDoneSwitchingSilencer( 0 )
	self:SetDelayFire( true )
	return ret
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryAttack() > CurTime() then return end
	
	--Jvs: valve sure is good at pulling values out of their ass
	
	if not self:GetOwner():OnGround() then
		self:GunFire( 0.35 + 0.4 * self:GetAccuracy() )
	elseif self:GetOwner():GetAbsVelocity():Length2D() > 140 then
		self:GunFire( 0.35 + 0.07 * self:GetAccuracy() )
	else
		if self:IsSilenced() then
			self:GunFire( 0.025 * self:GetAccuracy() )
		else
			self:GunFire( 0.02 * self:GetAccuracy() )
		end
	end
end

function SWEP:GunFire( spread )
	
	if not self:BaseGunFire( spread, self:GetWeaponInfo().CycleTime, not self:IsSilenced() ) then
		return
	end
	
	--Jvs: this is so goddamn lame
	
	if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
		self:KickBack( 1, 0.45, 0.28 , 0.045 , 3.75 , 3 , 7 )
	elseif not self:GetOwner():OnGround() then
		self:KickBack( 1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6 )
	elseif self:GetOwner():Crouching() then
		self:KickBack( 0.6, 0.3, 0.2, 0.0125, 3.25, 2, 7 )
	else
		self:KickBack( 0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7 )
	end
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryAttack() > CurTime() then return end
	
	if self:GetHasSilencer() then
		self:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
	else
		self:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
	end
	
	self:GetOwner():DoReloadEvent()
	
	self:SetHasSilencer( not self:GetHasSilencer() )
	self:SetDoneSwitchingSilencer( CurTime() + 2 )
	self:SetNextSecondaryAttack( CurTime() + 2 )
	self:SetNextPrimaryAttack( CurTime() + 2 )
	self:SetNextIdle( CurTime() + 2 )
end

function SWEP:TranslateViewModelActivity( act )
	if self:IsSilenced() and self.SilencedTranslation[act] then
		return self.SilencedTranslation[act]
	else
		return BaseClass.TranslateViewModelActivity( self , act )
	end
end

--this is called every tick inside of Think and every frame inside of DrawWorldModel, so it should update the worldmodel pretty often

function SWEP:UpdateWorldModel()
	if self:IsSilenced() then
		self.WorldModel = self:GetWeaponInfo().SilencerModel
	else
		self.WorldModel = self:GetWeaponInfo().playermodel
	end
end

function SWEP:Holster()
	
	if self:GetDoneSwitchingSilencer() > 0 and self:GetDoneSwitchingSilencer() > CurTime() then
		self:SetHasSilencer( false )
	end
	
	self:UpdateWorldModel()
	
	return BaseClass.Holster( self )
end