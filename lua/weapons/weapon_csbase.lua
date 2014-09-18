AddCSLuaFile()

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self:SetDelayFire( true )
end


--[[
	loads the keyvalues data from the files in the data folder and then sets the appropriate values on the weapon table,
	the parsed table can then be accessed with self:GetWeaponInfo()
	
	NOTE: this function should be called right after AddCSLuaFile() on the SWEP object
	
	
]]

function SWEP:ParseWeaponInfo( classname )
	--TODO
end

--[[
	returns the raw data parsed from the vdf in table form,
	some of this data is already applied to the weapon table ( such as .Slot, .PrintName and etc )
]]
function SWEP:GetWeaponInfo()
	--TODO
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
	
	self:NetworkVar( "Bool"	, 0 , "InReload" )
	self:NetworkVar( "Bool" , 1 , "HasSilencer" )
	self:NetworkVar( "Bool"	, 2 , "DelayFire" )
	
end

function SWEP:Deploy()
	self:SetNextDecreaseShotsFired( CurTime() )
	self:SetShotsFired( 0 )
	self:SetAccuracy( 0.2 )
	
	return true
end

function SWEP:Reload()
	if self:GetMaxClip1() ~= -1 and not self:InReload() and self:GetNextPrimaryAttack() < CurTime() then
		self:SetShotsFired( 0 )
		
		local reload = self:MainReload( ACT_VM_RELOAD )
		
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
	
	self:WeaponSound( "RELOAD" )

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

function SWEP:Think()
	local pPlayer = self:GetOwner()

	if not IsValid( pPlayer ) then
		return
	end
	
	--Jvs:	this is where the reload actually ends, this might be moved into its own function so other coders
	--		can add other behaviours ( such as cs:go finishing the reload with a different delay, based on when the 
	--		magazine actually gets inserted )
	
	if self:InReload() and self:GetNextPrimaryAttack() <= CurTime() then
		-- complete the reload. 
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
			if self:GetShotsFired() > 0 && self:GetNextDecreaseShotsFired() < CurTime() then
				self:SetNextDecreaseShotsFired( CurTime() + 0.0225 )
				self:SetShotsFired( self:GetShotsFired() - 1 )
			end
		end

		self:Idle()
	end
end

function SWEP:Idle()
	if CurTime() > self:GetNextIdle() then
		self:SendWeaponAnim( ACT_VM_IDLE )
	end
end

function SWEP:Holster()

end

function SWEP:InReload()
	return self:GetInReload()
end

function SWEP:IsPistol()
	return self:GetWeaponType() == CS_WEAPONTYPE_PISTOL
end

function SWEP:IsAwp()
	return false
end

function SWEP:IsSilenced()
	return self:GetHasSilencer()
end

--TODO: use getweaponinfo and shit to emit the sound here
function SWEP:WeaponSound( soundtype )

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