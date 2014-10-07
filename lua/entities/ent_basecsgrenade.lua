AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

function ENT:Initialize()
	if SERVER then
		self:SetSolid( SOLID_BBOX )
		self:SetCollisionBounds( Vector( -2 , -2 , -2 ) , Vector( 2 , 2 , 2 ) )
		self:SetSpawnTime( CurTime() )
		self:SetMoveType( MOVETYPE_FLYGRAVITY )
		self:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE )	--MOVECOLLIDE_FLY_CUSTOM	--Jvs: how the crap am I gonna implement this
		self:SetGravity( 0.4 )
		self:SetFriction( 0.2 )
		self:SetElasticity( 0.45 )
		self:SetShakeRadius( 0 )
		self:SetShakeAmplitude( 0 )
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "Thrower" )
	
	self:NetworkVar( "Float" , 0 , "Damage" )
	self:NetworkVar( "Float" , 1 , "DamageRadius" )
	self:NetworkVar( "Float" , 2 , "DetonateTime" )	--Jvs: this is not actually networked in the original code but I'm lazy,people could hook this to do some neat stuff so get off my back
	self:NetworkVar( "Float" , 3 , "SpawnTime" )
	self:NetworkVar( "Float" , 4 , "ShakeAmplitude" )
	self:NetworkVar( "Float" , 5 , "ShakeRadius" )
	
	self:NetworkVar( "Vector" , 0 , "InitialVelocity" )
end

function ENT:SetDetonateTimerLength( timer )
	self:SetDetonateTime( CurTime() + timer )
end

function ENT:Think()
	if SERVER then
		if not self:IsInWorld() then
			self:Remove()
			return
		end
		
		if CurTime() > self:GetDetonateTime() then
			self:Detonate()
			return
		end
		
		--danger sound
		
		if self:WaterLevel() ~= 0 then
			self:SetAbsVelocity( self:GetAbsVelocity() * 0.5 )
		end
	
	end
	self:NextThink( CurTime() + 0.2 )
	return true
end

function ENT:OnRemove()

end

function ENT:Detonate()
	local tr
	local vecSpot
	--SetThink( NULL )
	vecSpot = self:GetPos() +  Vector( 0 , 0 , 8 )
	tr = util.TraceLine { start = vecSpot , vecSpot + Vector( 0 , 0 , -32 ) , mask = MASK_SHOT_HULL , filter = self }
	if tr.StartSolid then
		-- Since we blindly moved the explosion origin vertically, we may have inadvertently moved the explosion into a solid,
		-- in which case nothing is going to be harmed by the grenade's explosion because all subsequent traces will startsolid.
		-- If this is the case, we do the downward trace again from the actual origin of the grenade. (sjb) 3/8/2007  (for ep2_outland_09)
		tr = util.TraceLine { start = GetPos() , GetPos() + Vector( 0 , 0 , -32 ) , mask = MASK_SHOT_HULL , filter = self }
	end
	
	self:Explode( tr , DMG_BLAST )
	
	if self:GetShakeAmplitude() ~= 0 then
		util.ScreenShake( self:GetPos(), self:GetShakeAmplitude() , 150, 1, self:GetShakeRadius() )
	end
end

function ENT:Touch( otherent )
	if otherent == self:GetThrower() then
		return
	end
	
	--Jvs: doesn't work apparently?
	self:BounceSound()
end

function ENT:BounceSound()

end



function ENT:TouchExplode( otherent )
	local tr
	local vecSpot
	
	local velDir = self:GetAbsVelocity()
	velDir:Normalize()
	vecSpot = self:GetPos() - velDir * 32
	tr = util.TraceLine { start = vecSpot , vecSpot + velDir * 64 , mask = MASK_SOLID_BRUSHONLY , filter = self }
	self:Explode( tr , DMG_BLAST )
end

function ENT:Explode( tr , dmgtype )
	if CLIENT then return end
	
	if self:IsEFlagSet( EFL_KILLME ) then return end
	
	self:SetSolid( SOLID_NONE )
	if tr.Fraction ~= 1 then
		self:SetPos( tr.HitPos + tr.Normal * 0.6 )
	end
	
	local vecAbsOrigin = self:GetPos()
	local contents = util.PointContents( vecAbsOrigin )
	
	local te = EffectData()
	
	if tr.Fraction ~= 1 then
		local vecNormal = tr.Normal
		--[[
		te->Explosion( filter, -1.0, // don't apply cl_interp delay
			&vecAbsOrigin,
			!( contents & MASK_WATER ) ? g_sModelIndexFireball : g_sModelIndexWExplosion,
			m_DmgRadius * .03, 
			25,
			TE_EXPLFLAG_NONE,
			m_DmgRadius,
			m_flDamage,
			&vecNormal,
			(char) pdata->game.material );
		]]--Jvs : TODO
		
		te:SetOrigin( vecAbsOrigin )
	else
		--[[
			te->Explosion( filter, -1.0, // don't apply cl_interp delay
			&vecAbsOrigin, 
			!( contents & MASK_WATER ) ? g_sModelIndexFireball : g_sModelIndexWExplosion,
			m_DmgRadius * .03, 
			25,
			TE_EXPLFLAG_NONE,
			m_DmgRadius,
			m_flDamage );
		]]
		te:SetOrigin( vecAbsOrigin )
	end
	
	util.Effect( "Explosion", te )
	
	local vecReported = IsValid( self:GetThrower() ) and self:GetThrower():GetPos() or vector_origin
	local info = DamageInfo()
	info:SetDamage( self:GetDamage() )
	info:SetDamageType( dmgtype )
	info:SetDamageForce( vector_origin )
	info:SetDamagePosition( vecReported )
	self:EmitSound( "BaseGrenade.Explode" )
	self:SetNoDraw( true )
	self:SetAbsVelocity( vector_origin )
	util.BlastDamageInfo( info , self:GetPos() , self:GetDamageRadius() )
	self:Remove()
end

if CLIENT then
	function ENT:Draw()
		-- During the first half-second of our life, don't draw ourselves if he's
		-- still playing his throw animation.
		if IsValid( self:GetThrower() ) then
			if CurTime() - self:GetSpawnTime() < 0.5 then
				return
			end
		end
		
		self:DrawModel()
	end
end