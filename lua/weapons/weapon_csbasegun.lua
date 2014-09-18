AddCSLuaFile()

DEFINE_BASECLASS( "weapon_csbase" )

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true

function SWEP:Initialize()
	BaseClass.Initialize( self )
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Float" , 5 , "ZoomFullyActiveTime" )
	
end

function SWEP:DoFireEffects()
	self:GetOwner():MuzzleFlash()
end