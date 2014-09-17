AddCSLuaFile()

SWEP.Base = "weapon_csbase"

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true

function SWEP:Initialize()
	self.BaseClass.Initialize( self )
end

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Float" , 4 , "ZoomFullyActiveTime" )
	
end