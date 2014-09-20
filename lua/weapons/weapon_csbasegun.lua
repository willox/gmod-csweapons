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
	
	self:NetworkVar( "Float" , 6 , "ZoomLevel" )
	
	--Jvs: stuff that is scattered around all the weapons code that I'm going to try and unify here
	
	self:NetworkVar( "Bool"	, 3 , "BurstFiring" )		--is currently burstfiring
	self:NetworkVar( "Float" , 7 , "NextBurstFire" ) 	--when the next burstfire is gonna happen, same as nextprimaryattack
	self:NetworkVar( "Float" , 8 , "BurstFireDelay" )	--the speed of the burst fire itself, 0.5 means two shots every second etc
	self:NetworkVar( "Int" , 3 , "BurstFires" )			--goes from X to 0, how many burst fires we're going to do
	self:NetworkVar( "Float" , 8 , "DoneSwitchingSilencer" )
end

function SWEP:Deploy()
	self:SetDelayFire( false )
	self:SetZoomFullyActiveTime( -1 )
	return BaseClass.Deploy( self )
end

function SWEP:Think()
	--Jvs: TODO, I don't know what this code actually does, but it seems important for their AWP crap to prevent accuracy exploits or some other shit
	
--[[
	--GOOSEMAN : Return zoom level back to previous zoom level before we fired a shot. This is used only for the AWP.
	-- And Scout.
	if ( (m_flNextPrimaryAttack <= gpGlobals->curtime) && (pPlayer->m_bResumeZoom == TRUE) )
	{
#ifndef CLIENT_DLL
		pPlayer->SetFOV( pPlayer, pPlayer->m_iLastZoom, 0.05f )
		m_zoomFullyActiveTime = gpGlobals->curtime + 0.05f-- Make sure we think that we are zooming on the server so we don't get instant acc bonus

		if ( pPlayer->GetFOV() == pPlayer->m_iLastZoom )
		{
			-- return the fade level in zoom.
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
	if CurTime() <= self:GetNextIdle() then return end
	
	if self:GetNextPrimaryAttack() > CurTime() or self:GetNextSecondaryAttack() > CurTime() then return end
	
	if self:Clip1() ~= 0 then
		self:SetNextIdle( CurTime() + self:GetWeaponInfo().IdleInterval )
		self:SendWeaponAnim( ACT_VM_IDLE )
	end
end

function SWEP:IsScoped()
	--TODO: do something better than the shitty hacks valve does
	return false
end

--Jvs TODO: bullet firing code and animations

function SWEP:BaseGunFire( spread , cycletime , primarymode )
	
	local pPlayer = self:GetOwner()
	local pCSInfo = self:GetWeaponInfo()

	self:SetDelayFire( true )
	self:SetShotsFired( self:GetShotsFired() + 1 )
	
	-- These modifications feed back into flSpread eventually.
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

	-- Out of ammo?
	if self:Clip1() <= 0 then
		self:PlayEmptySound()
		self:SetNextPrimaryAttack( CurTime() + 0.2 )
		return false
	end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:SetClip1( self:Clip1() -1 )

	-- player "shoot" animation
	pPlayer:DoAttackEvent()
	
	self:WeaponSound( "single_shot" )
	
	--Jvs: TODO
	self:FireCSSBullet( pPlayer:GetAimVector():Angle() + 2 * pPlayer:GetViewPunchAngles() , primarymode , spread )
	
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

	self:SetNextIdle( CurTime() + pCSInfo.TimeToIdle )
	return true
end

--Jvs: there's LOTS of shit to do here, this'll have to wait until Willox finishes the weapon info parser
function SWEP:FireCSSBullet( ang , primarymode , spread )

	local ply = self:GetOwner()

	local r = util.SharedRandom( "Spread" , 0, 2 * math.pi )

	local x = math.sin( r ) * util.SharedRandom( "SpreadX" , 0, 0.5 )
	local y = math.cos( r ) * util.SharedRandom( "SpreadY" , 0, 1 )

	local dir = ang:Forward() +
		x * spread * ang:Right() +
		y * spread * ang:Up()

	dir:Normalize()

	ply:FireBullets {
		Attacker = ply,
		Src = ply:GetShootPos(),
		Dir = dir,
		Spread = Vector(0, 0, 0)
	}

end

if CLIENT then
	
	SWEP.ScopeArcTexture = Material( "materials/gmod/scope.vmt" )
	SWEP.ScopeDustTexture = Material( "" )
	
	--[[
		m_iScopeArcTexture = vgui::surface()->CreateNewTextureID();
		vgui::surface()->DrawSetTextureFile(m_iScopeArcTexture, "sprites/scope_arc", true, false);

		m_iScopeDustTexture = vgui::surface()->CreateNewTextureID();
		vgui::surface()->DrawSetTextureFile(m_iScopeDustTexture, "overlays/scope_lens", true, false);
	]]
	
	function SWEP:DoDrawCrosshair( x , y )
		if self:IsScoped() or self:GetWeaponType() == CS_WEAPONTYPE_SNIPER_RIFLE then
			return true
		end
		return BaseClass.DoDrawCrosshair( self , x , y )
	end
	
	function SWEP:DrawHUD()
		if self:IsScoped() then
			local screenWide, screenTall = ScrW() , ScrH()

			-- calculate the bounds in which we should draw the scope
			local inset = screenTall / 16
			local y1 = inset
			local x1 = (screenWide - screenTall) / 2 + inset 
			local y2 = screenTall - inset
			local x2 = screenWide - x1

			local x = screenWide / 2
			local y = screenTall / 2

			local uv1 = 0.5 / 256
			local uv2 = 1.0 - uv1
			--[[
			vgui::Vertex_t vert[4]	
			
			Vector2D uv11( uv1, uv1 )
			Vector2D uv12( uv1, uv2 )
			Vector2D uv21( uv2, uv1 )
			Vector2D uv22( uv2, uv2 )

			int xMod = ( screenWide / 2 )
			int yMod = ( screenTall / 2 )

			int iMiddleX = (screenWide / 2 )
			int iMiddleY = (screenTall / 2 )

			vgui::surface()->DrawSetTexture( m_iScopeDustTexture )
			vgui::surface()->DrawSetColor( 255, 255, 255, 255 )

			vert[0].Init( Vector2D( iMiddleX + xMod, iMiddleY + yMod ), uv21 )
			vert[1].Init( Vector2D( iMiddleX - xMod, iMiddleY + yMod ), uv11 )
			vert[2].Init( Vector2D( iMiddleX - xMod, iMiddleY - yMod ), uv12 )
			vert[3].Init( Vector2D( iMiddleX + xMod, iMiddleY - yMod ), uv22 )
			vgui::surface()->DrawTexturedPolygon( 4, vert )
			
			vgui::surface()->DrawSetColor(0,0,0,255)

			--Draw the reticle with primitives
			vgui::surface()->DrawLine( 0, y, screenWide, y )
			vgui::surface()->DrawLine( x, 0, x, screenTall )

			--Draw the outline
			vgui::surface()->DrawSetTexture( m_iScopeArcTexture )

			-- bottom right
			vert[0].Init( Vector2D( x, y ), uv11 )
			vert[1].Init( Vector2D( x2, y ), uv21 )
			vert[2].Init( Vector2D( x2, y2 ), uv22 )
			vert[3].Init( Vector2D( x, y2 ), uv12 )
			vgui::surface()->DrawTexturedPolygon( 4, vert )

			-- top right
			vert[0].Init( Vector2D( x - 1, y1 ), uv12 )
			vert[1].Init( Vector2D ( x2, y1 ), uv22 )
			vert[2].Init( Vector2D( x2, y + 1 ), uv21 )
			vert[3].Init( Vector2D( x - 1, y + 1 ), uv11 )
			vgui::surface()->DrawTexturedPolygon(4, vert)

			-- bottom left
			vert[0].Init( Vector2D( x1, y ), uv21 )
			vert[1].Init( Vector2D( x, y ), uv11 )
			vert[2].Init( Vector2D( x, y2 ), uv12 )
			vert[3].Init( Vector2D( x1, y2), uv22 )
			vgui::surface()->DrawTexturedPolygon(4, vert)

			-- top left
			vert[0].Init( Vector2D( x1, y1 ), uv22 )
			vert[1].Init( Vector2D( x, y1 ), uv12 )
			vert[2].Init( Vector2D( x, y ), uv11 )
			vert[3].Init( Vector2D( x1, y ), uv21 )
			
			surface.DrawTexturedPolygon(4, vert)
		
			surface.DrawFilledRect(0, 0, screenWide, y1)				-- top
			surface.DrawFilledRect(0, y2, screenWide, screenTall)		-- bottom
			surface.DrawFilledRect(0, y1, x1, screenTall)				-- left
			surface.DrawFilledRect(x2, y1, screenWide, screenTall)	-- right
			]]
		end
	end

end