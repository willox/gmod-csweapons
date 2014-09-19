AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbasegun" )

--Jvs: I wish this weapon defining shit was this easy
SWEP:ParseWeaponInfo( "weapon_ak47" )
SWEP.Spawnable = true

--[[
	NOTE TO RESKINNERS
	If you want to make your own CS:S weapon by applying another viewmodel or whatever, you should have this in your custom weapon file
	
	AddCSLuaFile()
	DEFINE_BASECLASS( "weapon_gunyouwanttocopyfrom" )

	SWEP:ParseWeaponInfo( "weapon_gunyouwanttocopyfrom" )
	
	SWEP.ViewModel = "blablabla.mdl"
	SWEP.WorldModel "blablabla.mdl"
	
	Support for modifying other weapon values directly from here will come soon ( once the parser actually gets finished )
	Ideally it should be done like this
	
	SWEP.WeaponInfo.Damage = 69
	SWEP.WeaponInfo.SingleShot = Sound( "MyAwesome.Sound" )
]]

--TODO:	primary attack bullcrap

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryAttack() > CurTime() then return end
	
	--Jvs: valve sure is good at pulling values out of their ass
	
	if not self:GetOwner():OnGround() then
		self:GunFire( 0.04 + 0.4 * self:GetAccuracy() )
	elseif self:Getowner():GetAbsVelocity():Length2D() > 140 then
		self:GunFire( 0.04 + 0.07 * self:GetAccuracy() )
	else
		self:GunFire( 0.0275 * self:GetAccuracy() )
	end
end

function SWEP:GunFire( spread )
	
	if not self:BaseGunFire( spread, self:GetWeaponInfo().CycleTime, true ) then
		return
	end
	
	--Jvs: this is so goddamn lame
	
	if self:GetOwner():GetAbsVelocity():Length2D() > 5 then
		self:KickBack( 1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7 )
	elseif not self:GetOwner():OnGround() then
		self:KickBack( 2, 1.0, 0.5, 0.35, 9, 6, 5 )
	elseif self:GetOwner():Crouching() then
		self:KickBack( 0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9 )
	else
		self:KickBack( 1, 0.375, 0.175, 0.0375, 5.75, 1.75, 8 )
	end
end