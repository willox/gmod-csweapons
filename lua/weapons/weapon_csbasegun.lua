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

function SWEP:Deploy()
	self:SetDelayFire( false )
	self:SetZoomFullyActiveTime( -1 )
	return BaseClass.Deploy( self )
end

function SWEP:Think()
	--Jvs: TODO, I don't know what this code actually does, but it seems important for their AWP crap to prevent accuracy exploits or some other shit
	
--[[
	//GOOSEMAN : Return zoom level back to previous zoom level before we fired a shot. This is used only for the AWP.
	// And Scout.
	if ( (m_flNextPrimaryAttack <= gpGlobals->curtime) && (pPlayer->m_bResumeZoom == TRUE) )
	{
#ifndef CLIENT_DLL
		pPlayer->SetFOV( pPlayer, pPlayer->m_iLastZoom, 0.05f )
		m_zoomFullyActiveTime = gpGlobals->curtime + 0.05f// Make sure we think that we are zooming on the server so we don't get instant acc bonus

		if ( pPlayer->GetFOV() == pPlayer->m_iLastZoom )
		{
			// return the fade level in zoom.
			pPlayer->m_bResumeZoom = false
		}
#endif
	}
]]
	BaseClass.Think( self )
end

function SWEP:DoFireEffects()
	self:GetOwner():MuzzleFlash()
end

function SWEP:Idle()
	if self:Clip1() ~= 0 then
		BaseClass.Idle( self )
	end
end

--Jvs TODO: bullet firing code and animations

function SWEP:BaseGunFire( spread , cycletime , primarymode )
	
	local pPlayer = self:GetOwner()
	local pCSInfo = self:GetWeaponInfo()

	self:SetDelayFire( true )
	self:SetShotsFired( self:GetShotsFired() + 1 )
	
	// These modifications feed back into flSpread eventually.
	if pCSInfo.AccuracyDivisor ~= -1 then
		local iShotsFired = self:GetShotsFired()

		if pCSInfo.AccuracyQuadratic then
			iShotsFired = iShotsFired * iShotsFired
		else
			iShotsFired = iShotsFired * iShotsFired * iShotsFired
		end
		
		self:SetAccuracy(( iShotsFired / pCSInfo.AccuracyDivisor) + pCSInfo.AccuracyOffset )
		
		if self:GetAccuracy() > pCSInfo.MaxInaccuracy then
			self:SetAccuracy( pCSInfo.MaxInaccuracy )
		end
	end

	// Out of ammo?
	if self:Clip1() <= 0 then
		self:PlayEmptySound()
		self:SetNextPrimaryAttack( CurTime() + 0.2 )
		return false
	end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:SetClip1( self:Clip1() -1 )

	// player "shoot" animation
	pPlayer:DoAttackEvent()
	
	
	--Jvs: TODO
	self:FireCSSBullet( pPlayer:EyeAngles() + 2 * pPlayer:GetViewPunchAngles() , primarymode , spread )
	
	--[[
	FX_FireBullets(
		pPlayer->entindex(),
		pPlayer->Weapon_ShootPosition(),
		pPlayer->EyeAngles() + 2.0f * pPlayer->GetPunchAngle(),
		GetWeaponID(),
		bPrimaryMode?Primary_Mode:Secondary_Mode,
		CBaseEntity::GetPredictionRandomSeed() & 255,
		flSpread )
	]]
	
	self:DoFireEffects()

	self:SetNextPrimaryAttack( CurTime() + cycletime )
	self:SetNextSecondaryAttack( CurTime() + cycletime )

	self:SetNextIdle( CurTime() + pCSInfo.TimeToIdleAfterFire )
	return true
end

--Jvs: there's LOTS of shit to do here, this'll have to wait until Willox finishes the weapon info parser
function SWEP:FireCSSBullet( ang , primarymode , spread )
end