AddCSLuaFile()

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true
SWEP.Category = "Counter Strike: Source"

SWEP.CSSWeapon = true

if CLIENT then
	SWEP.CrosshairDistance = 0
	local cl_crosshaircolor = CreateConVar( "cl_cs_crosshaircolor", "0", FCVAR_ARCHIVE )
	local cl_dynamiccrosshair = CreateConVar( "cl_cs_dynamiccrosshair", "1", FCVAR_ARCHIVE )
	local cl_scalecrosshair = CreateConVar( "cl_cs_scalecrosshair", "1", FCVAR_ARCHIVE )
	local cl_crosshairscale = CreateConVar( "cl_cs_crosshairscale", "0", FCVAR_ARCHIVE )
	local cl_crosshairalpha = CreateConVar( "cl_cs_crosshairalpha", "200", FCVAR_ARCHIVE )
	local cl_crosshairusealpha = CreateConVar( "cl_cs_crosshairusealpha", "0", FCVAR_ARCHIVE )
	
	SWEP.CSSBobbing = false
	
	SWEP.LateralBob = 0
	SWEP.VerticalBob = 0
	
	SWEP.BobTime = 0
	SWEP.LastBobTime = 0
	SWEP.LastSpeed = 0
	
	local cl_bobcycle = CreateConVar( "cl_cs_bobcycle" , "0.8" , FCVAR_ARCHIVE + FCVAR_CHEAT )
	local cl_bob = CreateConVar( "cl_cs_bob" , "0.002" , FCVAR_ARCHIVE + FCVAR_CHEAT )
	local cl_bobup = CreateConVar( "cl_cs_bobup" , "0.5" , FCVAR_ARCHIVE + FCVAR_CHEAT )
	
end

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self:SetDelayFire( true )
	self:SetFullReload( true )
	
	self:SetWeaponType( self.WeaponTypeToString[self:GetWeaponInfo().WeaponType] )
end

SWEP.WeaponTypeToString = {
	Knife = CS_WEAPONTYPE_KNIFE,
	Pistol = CS_WEAPONTYPE_PISTOL,
	Rifle = CS_WEAPONTYPE_RIFLE,
	Shotgun = CS_WEAPONTYPE_SHOTGUN,
	SniperRifle = CS_WEAPONTYPE_SNIPER_RIFLE,
	SubMachinegun = CS_WEAPONTYPE_SUBMACHINEGUN,
	Machinegun = CS_WEAPONTYPE_MACHINEGUN,
	C4 = CS_WEAPONTYPE_C4,
	Grenade = CS_WEAPONTYPE_GRENADE,
}

--[[
	returns the raw data parsed from the vdf in table form,
	some of this data is already applied to the weapon table ( such as .Slot, .PrintName and etc )
]]
function SWEP:GetWeaponInfo()
	return self._WeaponInfo
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float" , 0 , "NextPrimaryAttack" )
	self:NetworkVar( "Float" , 1 , "NextSecondaryAttack" )
	self:NetworkVar( "Float" , 2 , "Accuracy" )
	self:NetworkVar( "Float" , 3 , "NextIdle" )
	self:NetworkVar( "Float" , 4 , "NextDecreaseShotsFired" )
	
	self:NetworkVar( "Int"	, 0 , "WeaponType" )
	self:NetworkVar( "Int"	, 1 , "ShotsFired" )
	self:NetworkVar( "Int"	, 2 , "Direction" )
	self:NetworkVar( "Int"	, 3 , "WeaponID" )
	
	self:NetworkVar( "Bool"	, 0 , "InReload" )
	self:NetworkVar( "Bool" , 1 , "HasSilencer" )
	self:NetworkVar( "Bool"	, 2 , "DelayFire" )
	
	self:NetworkVar( "Bool" , 3 , "FullReload" )
	
end

function SWEP:Deploy()
	self:SetNextDecreaseShotsFired( CurTime() )
	self:SetShotsFired( 0 )
	self:SetInReload( false )
	
	self:SendWeaponAnim( self:TranslateViewModelActivity( ACT_VM_DRAW ) )
	self:SetNextPrimaryAttack( CurTime() + self:SequenceDuration() )
	self:SetNextSecondaryAttack( CurTime() + self:SequenceDuration() )
	
	if IsValid( self:GetOwner() ) and self:GetOwner():IsPlayer() then
		self:GetOwner():SetFOV( 0 , 0 )
	end
	
	return true
end

function SWEP:Reload()
	if self:GetMaxClip1() ~= -1 and not self:InReload() and self:GetNextPrimaryAttack() < CurTime() then
		self:SetShotsFired( 0 )
		
		return self:MainReload( self:TranslateViewModelActivity( ACT_VM_RELOAD ) )
	end
end

--Jvs: can't call it DefaultReload because there's already one in the weapon's metatable and I'd rather not cause conflicts

function SWEP:MainReload( act )
	local pOwner = self:GetOwner()
	
	-- If I don't have any spare ammo, I can't reload
	if pOwner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		return false
	end
	
	local bReload = false
	
	-- If you don't have clips, then don't try to reload them.
	if self:GetMaxClip1() ~= -1 then
		-- need to reload primary clip?
		local primary	= math.min( self:GetMaxClip1() - self:Clip1(), pOwner:GetAmmoCount(self:GetPrimaryAmmoType()))
		if primary ~= 0 then
			bReload = true
		end
	end
	
	if self:GetMaxClip2() ~= -1 then
		-- need to reload secondary clip?
		local secondary = math.min( self:GetMaxClip2() - self:Clip2(), pOwner:GetAmmoCount( self:GetSecondaryAmmoType() ))
		if secondary ~= 0 then
			bReload = true
		end
	end

	if not bReload then
		return false
	end
	
	self:WeaponSound( "reload" )

	self:SendWeaponAnim( act )

	-- Play the player's reload animation
	if pOwner:IsPlayer() then
		pOwner:DoReloadEvent()
	end

	local flSequenceEndTime = CurTime() + self:SequenceDuration()
	
	self:SetNextPrimaryAttack( flSequenceEndTime )
	self:SetNextSecondaryAttack( flSequenceEndTime )
	self:SetInReload( true )
	
	return true
end

function SWEP:GetMaxClip1()
	return self.Primary.ClipSize
end

function SWEP:GetMaxClip2()
	return self.Secondary.ClipSize
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Think()
	local pPlayer = self:GetOwner()

	if not IsValid( pPlayer ) then
		return
	end
	
	--[[
		Jvs:
			this is where the reload actually ends, this might be moved into its own function so other coders
			can add other behaviours ( such as cs:go finishing the reload with a different delay, based on when the 
			magazine actually gets inserted )
	]]
	if self:InReload() and self:GetNextPrimaryAttack() <= CurTime() then
		-- complete the reload. 
		
		--Jvs TODO: shotgun reloading here
		
		
		local j = math.min( self:GetMaxClip1() - self:Clip1(), pPlayer:GetAmmoCount( self:GetPrimaryAmmoType() ) )
		
		-- Add them to the clip
		self:SetClip1( self:Clip1() + j )
		pPlayer:RemoveAmmo( j, self:GetPrimaryAmmoType() )
		
		self:SetInReload( false )
	end
	
	local plycmd = pPlayer:GetCurrentCommand()
	
	if not plycmd:KeyDown( IN_ATTACK ) and not plycmd:KeyDown( IN_ATTACK2 ) then
		-- no fire buttons down

		-- The following code prevents the player from tapping the firebutton repeatedly 
		-- to simulate full auto and retaining the single shot accuracy of single fire
		if self:GetDelayFire() then
			self:SetDelayFire( false )

			if self:GetShotsFired() > 15 then
				self:SetShotsFired( 15 )
			end
			
			self:SetNextDecreaseShotsFired( CurTime() + 0.4 )
		end

		-- if it's a pistol then set the shots fired to 0 after the player releases a button
		if self:IsPistol() then
			self:SetShotsFired( 0 )
		else
			if self:GetShotsFired() > 0 and self:GetNextDecreaseShotsFired() < CurTime() then
				self:SetNextDecreaseShotsFired( CurTime() + 0.0225 )
				self:SetShotsFired( self:GetShotsFired() - 1 )
			end
		end

		self:Idle()
	end
end

function SWEP:Idle()
	if CurTime() > self:GetNextIdle() then
		self:SendWeaponAnim( self:TranslateViewModelActivity( ACT_VM_IDLE ) )
		self:SetNextIdle( CurTime() + self:GetWeaponInfo().IdleInterval )
	end
end

function SWEP:Holster()
	self:SetInReload( false )
	return true
end

function SWEP:InReload()
	return self:GetInReload()
end

function SWEP:IsPistol()
	return self:GetWeaponType() == CS_WEAPONTYPE_PISTOL
end

function SWEP:IsSilenced()
	return self:GetHasSilencer()
end

function SWEP:TranslateViewModelActivity( act )
	return act
end

function SWEP:WeaponSound( soundtype )
	if not self:GetWeaponInfo() then return end
	
	local sndname = self:GetWeaponInfo().SoundData[soundtype]
	
	if sndname then
		self:EmitSound( sndname , nil , nil , nil , CHAN_AUTO )
	end
end

function SWEP:PlayEmptySound()
	if self:IsPistol() then
		self:EmitSound( "Default.ClipEmpty_Pistol" , nil , nil , nil , CHAN_AUTO )	--an actual undocumented feature!
	else
		self:EmitSound( "Default.ClipEmpty_Rifle" , nil , nil , nil , CHAN_AUTO )
	end
end

function SWEP:KickBack( up_base, lateral_base, up_modifier, lateral_modifier, up_max, lateral_max, direction_change )
	if not self:GetOwner():IsPlayer() then 
		return 
	end
	
	local flKickUp
	local flKickLateral
	
	--[[
		Jvs:
			I implemented the shots fired and direction stuff on the cs base because it would've been dumb to do it
			on the player, since it's reset on a gun basis anyway
	]]
	if self:GetShotsFired() == 1 then-- This is the first round fired
		flKickUp = up_base
		flKickLateral = lateral_base
	else
		flKickUp = up_base + self:GetShotsFired() * up_modifier
		flKickLateral = lateral_base + self:GetShotsFired() * lateral_modifier
	end


	local angle = self:GetOwner():GetViewPunchAngles()

	angle.x = angle.x - flKickUp
	if angle.x < -1 * up_max then
		angle.x = -1 * up_max
	end
	
	if self:GetDirection() == 1 then
		angle.y = angle.y + flKickLateral
		if angle.y > lateral_max then
			angle.y = lateral_max
		end
	else
		angle.y = angle.y - flKickLateral
		if angle.y < -1 * lateral_max then
			angle.y = -1 * lateral_max
		end
	end
	
	--[[
		Jvs: uhh I don't get this code, so they run a random int from 0 up to direction_change, 
		( which varies from 5 to 9 in the ak47 case)
		if the random craps out a 0, they make the direction negative and damp it by 1
		the actual direction in the whole source code is only used above, and it produces a different kick if it's at 1
		
		I don't know if the guy that made this was a genius or..
	]]
	
	if math.floor( util.SharedRandom( "KickBack" , 0 , direction_change ) ) == 0 then
		self:SetDirection( 1 - self:GetDirection() )
	end
	
	self:GetOwner():SetViewPunchAngles( angle )
end

--[[
	Jvs:	
		this function is here to make the player faster or slower depending on the weapon equipped ( and mode of the weapon )
		in CS:S the value here is actually a flat movement speed, but here we still want to replicate the movement speed of when you're zoomed in / use a knife
		and forcing flat movement speeds in other gamemodes is dumb as hell
]]

function SWEP:GetSpeedRatio()
	--Jvs: rare case where the speed might still be undefined
	if self:GetWeaponInfo().MaxPlayerSpeed == 1 then
		return 1
	end
	
	return self:GetWeaponInfo().MaxPlayerSpeed / 250
end

if SERVER then

	function SWEP:OnDrop()
		self:SetInReload( false )
	end

else

	local cl_crosshaircolor = GetConVar( "cl_cs_crosshaircolor" )
	local cl_dynamiccrosshair = GetConVar( "cl_cs_dynamiccrosshair" )
	local cl_scalecrosshair = GetConVar( "cl_cs_scalecrosshair" )
	local cl_crosshairscale = GetConVar( "cl_cs_crosshairscale" )
	local cl_crosshairalpha = GetConVar( "cl_cs_crosshairalpha" )
	local cl_crosshairusealpha = GetConVar( "cl_cs_crosshairusealpha" )
	
	local cl_bobcycle = GetConVar( "cl_cs_bobcycle" )
	local cl_bob = GetConVar( "cl_cs_bob" )
	local cl_bobup = GetConVar( "cl_cs_bobup" )
	
	SWEP.LastAmmoCheck = 0
	
	function SWEP:DoDrawCrosshair( x , y )
		
		local iDistance = self:GetWeaponInfo().CrosshairMinDistance -- The minimum distance the crosshair can achieve...
		
		local iDeltaDistance = self:GetWeaponInfo().CrosshairDeltaDistance -- Distance at which the crosshair shrinks at each step
		
		if cl_dynamiccrosshair:GetBool() then
			if not self:GetOwner():OnGround() then
				 iDistance = iDistance * 2.0
			elseif self:GetOwner():Crouching() then
				 iDistance = iDistance * 0.5
			elseif self:GetOwner():GetAbsVelocity():Length() > 100 then
				 iDistance = iDistance * 1.5
			end
		end
	
		
		
		if self:GetShotsFired() > self.LastAmmoCheck then
			self.CrosshairDistance = math.min( 15, self.CrosshairDistance + iDeltaDistance )
		elseif self.CrosshairDistance > iDistance then
			self.CrosshairDistance = 0.1 + self.CrosshairDistance * 0.013
		end
		
		self.LastAmmoCheck = self:GetShotsFired()
		
		if self.CrosshairDistance < iDistance then
			 self.CrosshairDistance = iDistance
		end

		--scale bar size to the resolution
		local crosshairScale = cl_crosshairscale:GetInt()
		if crosshairScale < 1 then
			if ScrH() <= 600 then
				crosshairScale = 600
			elseif ScrH() <= 768 then
				crosshairScale = 768
			else
				crosshairScale = 1200
			end
		end
		
		local scale
		
		if not cl_scalecrosshair:GetBool() then
			scale = 1
		else
			scale = ScrH() / crosshairScale
		end

		local iCrosshairDistance = math.ceil( self.CrosshairDistance * scale )
		
		local iBarSize = ScreenScale( 5 ) + (iCrosshairDistance - iDistance) / 2

		iBarSize = math.max( 1, iBarSize * scale )
		
		local iBarThickness = math.max( 1, math.floor( scale + 0.5 ) )

		local r, g, b
		
		if cl_crosshaircolor:GetInt() == 0 then
			r = 50
			g = 250
			b = 50
		elseif cl_crosshaircolor:GetInt() == 1 then
			r = 250
			g = 50
			b = 50
		elseif cl_crosshaircolor:GetInt() == 2 then
			r = 50
			g = 50
			b = 250
		elseif cl_crosshaircolor:GetInt() == 3 then
			r = 250
			g = 250
			b = 50
		elseif cl_crosshaircolor:GetInt() == 4 then
			r = 50
			g = 250
			b = 250
		else
			r = 50
			g = 250
			b = 50
		end
		
		local alpha = math.Clamp( cl_crosshairalpha:GetInt(), 0, 255 )
		surface.SetDrawColor( r, g, b, alpha )

		if not cl_crosshairusealpha:GetBool() then
			surface.SetDrawColor( r, g, b, 200 )
			draw.NoTexture()
		end

		local iHalfScreenWidth = 0
		local iHalfScreenHeight = 0

		local iLeft		= iHalfScreenWidth - ( iCrosshairDistance + iBarSize )
		local iRight	= iHalfScreenWidth + iCrosshairDistance + iBarThickness
		local iFarLeft	= iBarSize
		local iFarRight	= iBarSize

		if not cl_crosshairusealpha:GetBool() then
			-- Additive crosshair
			surface.DrawTexturedRect( x + iLeft, y + iHalfScreenHeight, iFarLeft, iHalfScreenHeight + iBarThickness )
			surface.DrawTexturedRect( x + iRight, y + iHalfScreenHeight, iFarRight, iHalfScreenHeight + iBarThickness )
		else
			-- Alpha-blended crosshair
			surface.DrawRect( x + iLeft, y + iHalfScreenHeight, iFarLeft, iHalfScreenHeight + iBarThickness )
			surface.DrawRect( x + iRight, y + iHalfScreenHeight, iFarRight, iHalfScreenHeight + iBarThickness )
		end
		
		local iTop		= iHalfScreenHeight - ( iCrosshairDistance + iBarSize )
		local iBottom		= iHalfScreenHeight + iCrosshairDistance + iBarThickness
		local iFarTop		= iBarSize
		local iFarBottom	= iBarSize

		if not cl_crosshairusealpha:GetBool() then
			-- Additive crosshair
			surface.DrawTexturedRect( x + iHalfScreenWidth, y + iTop, iHalfScreenWidth + iBarThickness, iFarTop )
			surface.DrawTexturedRect( x + iHalfScreenWidth, y + iBottom, iHalfScreenWidth + iBarThickness, iFarBottom )
		else
			-- Alpha-blended crosshair
			surface.DrawRect( x + iHalfScreenWidth, y + iTop, iHalfScreenWidth + iBarThickness, iFarTop )
			surface.DrawRect( x + iHalfScreenWidth, y + iBottom, iHalfScreenWidth + iBarThickness, iFarBottom )
		end
		
		return true
	end
	
	--Jvs: CSS' viewmodel bobbing code, if it's disabled it'll just return hl2's
	
	function SWEP:CalcViewModelView( vm , origin , angles , newpos , newang )
		if self.CSSBobbing then
			local forward = angles:Forward()

			self:CalcViewModelBob()

			-- Apply bob, but scaled down to 40%
			origin = origin + forward * self.VerticalBob * 0.4
			
			-- Z bob a bit more
			origin.z = origin.z + self.VerticalBob * 0.1
			
			-- bob the angles
			angles.r = angles.r + self.VerticalBob * 0.5
			angles.p = angles.p - self.VerticalBob * 0.4

			angles.y = angles.y - self.LateralBob  * 0.3
			return origin, angles
		end
	end
	
	
	--Jvs TODO: replace CurTime() with RealTime() to prevent prediction errors from spazzing the viewmodel
	
	function SWEP:CalcViewModelBob()
		
		local cycle = 0
		
		local player = self:GetOwner()
		--Assert( player )

		--NOTENOTE: For now, let this cycle continue when in the air, because it snaps badly without it

		if FrameTime() == 0 or cl_bobcycle:GetFloat() <= 0 or cl_bobup:GetFloat() <= 0 or cl_bobup:GetFloat() >= 1 then
			return
		end

		--Find the speed of the player
		local speed = player:GetAbsVelocity():Length2D()
		local flmaxSpeedDelta = math.max( 0, ( CurTime() - self.LastBobTime ) * player:GetRunSpeed() )

		-- don't allow too big speed changes
		speed = math.Clamp( speed, self.LastSpeed - flmaxSpeedDelta, self.LastSpeed + flmaxSpeedDelta )
		speed = math.Clamp( speed, player:GetRunSpeed() * -1 , player:GetRunSpeed() )

		self.LastSpeed = speed

		--FIXME: This maximum speed value must come from the server.
		--		 MaxSpeed() is not sufficient for dealing with sprinting - jdw

		

		local bob_offset = math.Remap( speed, 0, player:GetRunSpeed(), 0 , 1 )
		
		self.BobTime = self.BobTime + ( CurTime() - self.LastBobTime ) * bob_offset
		self.LastBobTime = CurTime()

		
		--Calculate the vertical bob
		cycle = self.BobTime - ( self.BobTime / cl_bobcycle:GetFloat() ) * cl_bobcycle:GetFloat()
		cycle = cycle / cl_bobcycle:GetFloat()

		if cycle < cl_bobup:GetFloat() then
			cycle = math.pi * cycle / cl_bobup:GetFloat()
		else
			cycle = math.pi + math.pi * ( cycle - cl_bobup:GetFloat() ) / ( 1 - cl_bobup:GetFloat() )
		end
		
		self.VerticalBob = speed * 0.005
		self.VerticalBob = self.VerticalBob * 0.3 + self.VerticalBob * 0.7 * math.sin( cycle )

		self.VerticalBob = math.Clamp( self.VerticalBob, -7.0, 4.0 )

		--Calculate the lateral bob
		cycle = self.BobTime - ( self.BobTime / cl_bobcycle:GetFloat() * 2 ) * cl_bobcycle:GetFloat() * 2
		cycle = cycle / ( cl_bobcycle:GetFloat() * 2 )

		if cycle < cl_bobup:GetFloat() then
			cycle = math.pi * cycle / cl_bobup:GetFloat()
		else
			cycle = math.pi + math.pi * ( cycle - cl_bobup:GetFloat() ) / ( 1 - cl_bobup:GetFloat() )
		end

		self.LateralBob = speed * 0.005
		self.LateralBob = self.LateralBob * 0.3 + self.LateralBob * 0.7 * math.sin( cycle )
		self.LateralBob = math.Clamp( self.LateralBob , -7 , 4 )
		return
	end
end