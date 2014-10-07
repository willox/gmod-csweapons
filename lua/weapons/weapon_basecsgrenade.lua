AddCSLuaFile()
DEFINE_BASECLASS( "weapon_csbase" )

function SWEP:Initialize()
	BaseClass.Initialize( self )
	--Jvs TODO: set the normal holdtype to slam, then when the user holds the firebutton down switch to grenade
	--			and when he's done redrawing, set back to slam
	self:SetHoldType( "grenade" )
	self:SetRedraw( false )
	self:SetPinPulled( false )
	self:SetThrowTime( 0 )
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	self:NetworkVar( "Bool" , 4 , "Redraw" )
	self:NetworkVar( "Bool" , 5 , "PinPulled" )
	self:NetworkVar( "Float" , 5 , "ThrowTime" )
	
end

function SWEP:Deploy()
	self:SetRedraw( false )
	self:SetPinPulled( false )
	self:SetThrowTime( 0 )
	if SERVER then
		if IsValid( self:GetOwner() ) then
			if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
				self:GetOwner():DropWeapon( self )
				self:Remove()
				return false
			end
		end
	end

	return BaseClass.Deploy( self )
end

function SWEP:Holster()
	self:SetRedraw( false )
	self:SetPinPulled( false )
	self:SetThrowTime( 0 )
	if SERVER then
		if IsValid( self:GetOwner() ) then
			if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
				self:GetOwner():DropWeapon( self )
				self:Remove()
				return false
			end
		end
	end
	
	return BaseClass.Holster( self )
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryAttack() > CurTime() or self:GetRedraw() or self:GetPinPulled() or self:GetThrowTime() > 0 then
		return
	end
	
	if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		return
	end
	
	self:SendWeaponAnim( ACT_VM_PULLPIN )
	self:SetPinPulled( true )
	
	self:SetNextIdle( CurTime() + self:SequenceDuration() )
	
	self:SetNextPrimaryAttack( CurTime() + self:SequenceDuration() )
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryAttack() > CurTime() or self:GetRedraw() then
		return
	end
	
	if self:GetOwner():Crouching() then
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_HAULBACK )
	end
	
	self:SetNextIdle( CurTime() + self:SequenceDuration() )
	self:SetNextSecondaryAttack( CurTime() + self:SequenceDuration() )
end

function SWEP:Reload()
	if self:GetRedraw() and self:GetNextPrimaryAttack() <= CurTime() and self:GetNextSecondaryAttack() <= CurTime() then
		self:SendWeaponAnim( ACT_VM_DRAW )
		
		self:SetNextPrimaryAttack( CurTime() + self:SequenceDuration() )
		self:SetNextIdle( CurTime() + self:SequenceDuration() )
		self:SetNextSecondaryAttack( CurTime() + self:SequenceDuration() )
		self:SetRedraw( false )
	end
end

function SWEP:Think()
	local cmd = self:GetOwner():GetCurrentCommand()
	
	if self:GetPinPulled() and not cmd:KeyDown( IN_ATTACK )  then
		self:GetOwner():DoAttackEvent()
		self:SetThrowTime( CurTime() + 0.1 )
		self:SetPinPulled( false )
		self:SendWeaponAnim( ACT_VM_THROW )
		self:SetNextPrimaryAttack( CurTime() + self:SequenceDuration() )
		self:SetNextIdle( CurTime() + self:SequenceDuration() )
		self:SetNextSecondaryAttack( CurTime() + self:SequenceDuration() )
	elseif self:GetThrowTime() > 0 and self:GetThrowTime() < CurTime() then
		self:GetOwner():RemoveAmmo( 1 , self:GetPrimaryAmmoType() )
		self:ThrowGrenade()
	elseif self:GetRedraw() then
		if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
			if SERVER then
				self:GetOwner():DropWeapon( self )
				self:Remove()
			end
			return
		else
			--self:GetOwner():SwitchToNextBestweapon ????
		end
		self:Idle()
		--return
	elseif not self:GetRedraw() then
		BaseClass.Think( self )
	end
end

function SWEP:Idle()
	if self:GetNextIdle() < CurTime() and self:GetRedraw() then
		self:Reload()
	end
end

function SWEP:ThrowGrenade()
	self:SetRedraw( true )
	self:SetThrowTime( 0 )
	
	self:GetOwner():EmitSound( "Weapon_Grenade.Throw" )
	
	if SERVER then
		local angThrow = self:GetOwner():EyeAngles()
	
		--Jvs: what the fuck is this, their version of angle normalize?
		
		if angThrow.x < 90 then
			angThrow.x = -10 + angThrow.x * ( 100 / 90 )
		else
			angThrow.x = 360 - angThrow.x
			angThrow.x = -10 +  angThrow.x * - ( 80 / 90 )
		end
		
		local flVel = ( 90 - angThrow.x ) * 6
		
		if flVel > 750 then
			flVel = 750
		end
		
		local vForward	= angThrow:Forward()
		local vRight	= angThrow:Right()
		local vUp		= angThrow:Up()
		
		local vecSrc = self:GetOwner():GetShootPos()
		
		local trace =	util.TraceHull { 
			start = vecSrc, 
			endpos = vecSrc + vForward * 16 , 
			mins = Vector( -2,-2,-2 ) , 
			maxs = Vector( 2,2,2 ),
			mask = MASK_SOLID,
			filter = self:GetOwner()
		}
		vecSrc = trace.HitPos
		
		local vecThrow = vForward * flVel + self:GetOwner():GetAbsVelocity()
		self:EmitGrenade( vecSrc , angle_zero , vecThrow , Vector( 600 , math.random( -1200, 1200 ) , 0 ), self:GetOwner() )
	end
end

function SWEP:EmitGrenade( vecSrc , vecAngles , vecVel , angImpulse , pPlayer )

end