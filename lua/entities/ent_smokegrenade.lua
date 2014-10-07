AddCSLuaFile()

DEFINE_BASECLASS( "ent_basecsgrenade" )

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/weapons/w_eq_smokegrenade_thrown.mdl" )
	end
	BaseClass.Initialize( self )
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	
end

function ENT:Think()
	if CLIENT then return end
	
	if self:IsEFlagSet( EFL_KILLME ) then return end
	
	
	
end

if SERVER then

	function ENT:DetonateThink()

	end

	function ENT:FadeThink()

	end


else
	
	function ENT:Draw()

	end

end