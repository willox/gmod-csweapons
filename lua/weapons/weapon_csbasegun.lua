AddCSLuaFile()

SWEP.Base = "weapon_csbase"

DEFINE_BASECLASS( SWEP.Base )

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true

function SWEP:Initialize()
	BaseClass.Initialize( self )
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Float" , 4 , "ZoomFullyActiveTime" )
	
end