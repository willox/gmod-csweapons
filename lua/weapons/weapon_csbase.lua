AddCSLuaFile()

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "NextPrimaryAttack" )
	self:NetworkVar( "Float" , 1 , "NextSecondaryAttack" )
	self:NetworkVar( "Float" , 2 , "Accuracy" )
	self:NetworkVar( "Float" , 3, "NextIdle" )
	
	self:NetworkVar( "Int"	, 0 , "WeaponType" )
	self:NetworkVar( "Bool"	, 0 , "InReload" )
	
end

function SWEP:InReload()
	return self:GetInReload()
end

function SWEP:IsPistol()
	return self:GetWeaponType() == 0	--WEAPONTYPE_PISTOL
end

function SWEP:IsAwp()
	return false
end

function SWEP:PlayEmptySound()
	if self:IsPistol() then
		self:EmitSound( "Default.ClipEmpty_Pistol" , nil , nil , nil , CHAN_AUTO )	--an actual undocumented feature!
	else
		self:EmitSound( "Default.ClipEmpty_Rifle" , nil , nil , nil , CHAN_AUTO )
	end
end