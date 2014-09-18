AddCSLuaFile()

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true

function SWEP:Initialize()
	self:SetHoldType( "normal" )
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
	self:NetworkVar( "Float" , 3, "NextIdle" )
	
	self:NetworkVar( "Int"	, 0 , "WeaponType" )
	self:NetworkVar( "Int"	, 1 , "ShotsFired" )
	self:NetworkVar( "Int"	, 2 , "Direction" )
	
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
	if self:GetShotsFired() == 1 then// This is the first round fired
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