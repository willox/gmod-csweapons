AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

CSParseWeaponInfo( SWEP , [[WeaponData
{
	"MaxPlayerSpeed"		"250"
	"WeaponType"			"Pistol"
	"FullAuto"				0
	"WeaponPrice"			"500"
	"WeaponArmorRatio"		"1.0"
	"CrosshairMinDistance"		"8"
	"CrosshairDeltaDistance" 	"3"
	"Team" 				"ANY"
	"BuiltRightHanded" 		"0"
	"PlayerAnimationExtension" 	"pistol"
	"MuzzleFlashScale"		"1"
	
	"CanEquipWithShield" 		"1"
	
	
	// Weapon characteristics:
	"Penetration"			"1"
	"Damage"			"34"
	"Range"				"4096"
	"RangeModifier"			"0.79"
	"Bullets"			"1"
	"CycleTime"			"0.15"
	
	// New accuracy model parameters
	"Spread"					0.00400
	"InaccuracyCrouch"			0.00600
	"InaccuracyStand"			0.00800
	"InaccuracyJump"			0.28725
	"InaccuracyLand"			0.05745
	"InaccuracyLadder"			0.01915
	"InaccuracyFire"			0.03495
	"InaccuracyMove"			0.01724
								
	"SpreadAlt"					0.00300
	"InaccuracyCrouchAlt"		0.00600
	"InaccuracyStandAlt"		0.00800
	"InaccuracyJumpAlt"			0.29625
	"InaccuracyLandAlt"			0.05925
	"InaccuracyLadderAlt"		0.01975
	"InaccuracyFireAlt"			0.02504
	"InaccuracyMoveAlt"			0.01778
								 
	"RecoveryTimeCrouch"		0.23371
	"RecoveryTimeStand"			0.28045
	
	// Weapon data is loaded by both the Game and Client DLLs.
	"printname"			"#Cstrike_WPNHUD_USP45"
	"viewmodel"			"models/weapons/v_pist_usp.mdl"
	"playermodel"			"models/weapons/w_pist_usp.mdl"
	"shieldviewmodel"		"models/weapons/v_shield_usp_r.mdl"	
	"SilencerModel"			"models/weapons/w_pist_usp_silencer.mdl"
	"anim_prefix"			"anim"
	"bucket"			"1"
	"bucket_position"		"1"

	"clip_size"			"12"
	
	"primary_ammo"			"BULLET_PLAYER_45ACP"
	"secondary_ammo"		"None"

	"weight"			"5"
	"item_flags"			"0"

	// Sounds for the weapon. There is a max of 16 sounds per category (i.e. max 16 "single_shot" sounds)
	SoundData
	{
		//"reload"			"Default.Reload"
		//"empty"				"Default.ClipEmpty_Rifle"
		"single_shot"		"Weapon_USP.Single"
		"special1"			"Weapon_USP.SilencedShot"
		"special2"			"Weapon_USP.DetachSilencer"
		"special3"			"Weapon_USP.AttachSilencer"
	}

	// Weapon Sprite data is loaded by the Client DLL.
	TextureData
	{
		"weapon"
		{
				"font"		"CSweaponsSmall"
				"character"	"A"
		}
		"weapon_s"
		{	
				"font"		"CSweapons"
				"character"	"A"
		}
		"ammo"
		{
				"font"		"CSTypeDeath"
				"character"		"M"
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
			Mins	"-7 -4 -14"
			Maxs	"24 9 -2"
		}
		World
		{
			Mins	"-1 -4 -3"
			Maxs	"17 5 6"
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
	self:SetHoldType( "pistol" )
end

function SWEP:Deploy()
	
	self:SetAccuracy( 0.92 )
	self:SetDoneSwitchingSilencer( 0 )
	return BaseClass.Deploy( self )
end

function SWEP:Holster()
	if self:GetDoneSwitchingSilencer() > 0 and self:GetDoneSwitchingSilencer() > CurTime() then
		self:SetHasSilencer( false )
	end
	
	return BaseClass.Holster( self )
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryAttack() > CurTime() then return end
	
	if self:IsSilenced() then
		if not self:GetOwner():OnGround() then
			self:GunFire( 1.3 * ( 1- self:GetAccuracy()), true )
		elseif self:GetOwner():GetAbsVelocity():Length2D() > 5 then
			self:GunFire( 0.25 * ( 1- self:GetAccuracy()), true )
		elseif self:GetOwner():Crouching() then
			self:GunFire( 0.125 * ( 1- self:GetAccuracy()), true )
		else
			self:GunFire( 0.15 * ( 1- self:GetAccuracy()), true )
		end
		
	else
		if not self:GetOwner():OnGround() then
			self:GunFire( 1.2 * ( 1- self:GetAccuracy()), false )
		elseif self:GetOwner():GetAbsVelocity():Length2D() > 5 then
			self:GunFire( 0.225 * ( 1- self:GetAccuracy()), false )
		elseif self:GetOwner():Crouching() then
			self:GunFire( 0.08 * ( 1- self:GetAccuracy()), false )
		else
			self:GunFire( 0.1 * ( 1- self:GetAccuracy()), false )
		end
	end
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

function SWEP:GunFire( spread , mode )
	
	--Jvs: technically this should be > 1, but since this is increased in basegunfire, we have to do it this way
	if self:GetShotsFired() > 0 then return end
	
	self:SetAccuracy( self:GetAccuracy() - 0.275 * ( 0.3 - CurTime() - self:GetLastFire() ) )

	if self:GetAccuracy() > 0.92 then
		self:SetAccuracy( 0.92 )
	elseif self:GetAccuracy() < 0.6 then
		self:SetAccuracy( 0.6 )
	end
	
	self:SetNextIdle( CurTime() + 2 )
	
	if not self:BaseGunFire( spread, self:GetWeaponInfo().CycleTime, mode ) then return end
	
	

	local angle = self:GetOwner():GetViewPunchAngles()
	angle.p = angle.p - 2
	self:GetOwner():SetViewPunchAngles( angle )
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
	self:SetDoneSwitchingSilencer( CurTime() + 3 )
	self:SetNextSecondaryAttack( CurTime() + 3 )
	self:SetNextPrimaryAttack( CurTime() + 3 )
	self:SetNextIdle( CurTime() + 3 )
end