AddCSLuaFile()

DEFINE_BASECLASS( "weapon_csbase" )

SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = true


function SWEP:Initialize()
	BaseClass.Initialize( self )
	
	self:SetLastFire( CurTime() )
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	--Jvs: stuff that is scattered around all the weapons code that I'm going to try and unify here

	self:NetworkVar( "Float" , 5 , "ZoomFullyActiveTime" )
	self:NetworkVar( "Float" , 6 , "ZoomLevel" )
	self:NetworkVar( "Float" , 7 , "NextBurstFire" ) 	--when the next burstfire is gonna happen, same as nextprimaryattack
	self:NetworkVar( "Float" , 8 , "DoneSwitchingSilencer" )
	self:NetworkVar( "Float" , 9 , "BurstFireDelay" )	--the speed of the burst fire itself, 0.5 means two shots every second etc
	self:NetworkVar( "Float" , 10 , "LastFire" )
	
	self:NetworkVar( "Bool" , 4 , "BurstFireEnabled" )
	
	self:NetworkVar( "Int" , 4 , "BurstFires" )			--goes from X to 0, how many burst fires we're going to do
	self:NetworkVar( "Int" , 5 , "MaxBurstFires" )
	
	
	
	
end

function SWEP:Deploy()
	self:SetDelayFire( false )
	self:SetZoomFullyActiveTime( -1 )
	self:SetAccuracy( 0.2 )
	self:SetBurstFireEnabled( false )
	self:SetBurstFires( self:GetMaxBurstFires() )
	
	return BaseClass.Deploy( self )
end

function SWEP:Holster()
	return BaseClass.Holster( self )
end

--Jvs : this function handles the zoom smoothing and decay

function SWEP:HandleZoom()
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
end

function SWEP:Think()

	self:UpdateWorldModel()
	
	self:HandleZoom()

	BaseClass.Think( self )
	
	
	if not self:InReload() and self:GetBurstFireEnabled() and self:GetNextBurstFire() < CurTime() and self:GetNextBurstFire() ~= -1 then
		if self:GetBurstFires() < ( self:GetMaxBurstFires() -1 ) then
			if self:Clip1() <= 0 then
				self:SetBurstFires( self:GetMaxBurstFires() )
			else
				self:SetNextPrimaryAttack( CurTime() - 1 )
				self:PrimaryAttack()
				self:SetNextPrimaryAttack( CurTime() + 0.5 )	--this artificial delay is inherited from the glock code
				self:SetBurstFires( self:GetBurstFires() + 1 )
			end
		else
			if self:GetNextBurstFire() < CurTime() and self:GetNextBurstFire() ~= -1 then
				self:SetBurstFires( 0 )
				self:SetNextBurstFire( -1 )
			end
		end
	end
end

function SWEP:DoFireEffects()
	if not self:IsSilenced() then
		--Jvs: on the client, we don't want to show this muzzle flash on the owner of this weapon if he's in first person
		
		--TODO: spectator support? who even gives a damn but ok
		
		if CLIENT then
			if self:IsCarriedByLocalPlayer() and not self:GetOwner():ShouldDrawLocalPlayer() then
				return
			end
		end
		
		--Jvs NOTE: prediction should already prevent this from sending the effect to the owner's client side
		
		local data = EffectData()
		data:SetFlags( 0 )
		data:SetEntity( self )
		data:SetAttachment( 1 )	--TODO: self:LookupAttachment( "muzzle" ) or whatever it's called
		data:SetScale( self:GetWeaponInfo().MuzzleFlashScale )
		
		if self.CSMuzzleX then
			util.Effect( "CS_MuzzleFlash_X", data )
		else
			util.Effect( "CS_MuzzleFlash", data )
		end

	end
end

function SWEP:Idle()
	if CurTime() <= self:GetNextIdle() then return end
	
	if self:GetNextPrimaryAttack() > CurTime() or self:GetNextSecondaryAttack() > CurTime() then return end
	
	if self:Clip1() ~= 0 then
		self:SetNextIdle( CurTime() + self:GetWeaponInfo().IdleInterval )
		self:SendWeaponAnim( self:TranslateViewModelActivity( ACT_VM_IDLE ) )
	end
end

function SWEP:TranslateViewModelActivity( act )
	return BaseClass.TranslateViewModelActivity( self , act )
end

function SWEP:IsScoped()
	--Jvs TODO: do something better than the shitty hacks valve does
	return false
end

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

	self:SendWeaponAnim( self:TranslateViewModelActivity( ACT_VM_PRIMARYATTACK ) )

	self:SetClip1( self:Clip1() -1 )

	-- player "shoot" animation
	pPlayer:DoAttackEvent()
	
	
	self:FireCSSBullet( pPlayer:GetAimVector():Angle() + 2 * pPlayer:GetViewPunchAngles() , primarymode , spread )

	self:DoFireEffects()

	self:SetNextPrimaryAttack( CurTime() + cycletime )
	self:SetNextSecondaryAttack( CurTime() + cycletime )

	self:SetNextIdle( CurTime() + pCSInfo.TimeToIdle )
	if self:GetBurstFireEnabled() then
		self:SetNextBurstFire( CurTime() + self:GetBurstFireDelay() )
	else
		self:SetNextBurstFire( -1 )
	end
	
	self:SetLastFire( CurTime() )
	return true
end

function SWEP:ToggleBurstFire()
	if IsValid( self:GetOwner() ) and self:GetOwner():IsPlayer() then
		if self:GetBurstFireEnabled() then
			self:GetOwner():PrintMessage( HUD_PRINTCENTER, "#Switch_To_SemiAuto" )
		else
			self:GetOwner():PrintMessage( HUD_PRINTCENTER, "#Switch_To_BurstFire" )
		end
	end
	
	self:SetBurstFireEnabled( not self:GetBurstFireEnabled() )
end

function SWEP:FireCSSBullet( ang , primarymode , spread )

	local ply = self:GetOwner()
	local pCSInfo = self:GetWeaponInfo()
	local iDamage = pCSInfo.Damage
	local flRangeModifier = pCSInfo.RangeModifier
	local soundType = "single_shot"
	
	--Valve's horrible hacky balance
	--Jvs: TODO , implement this either in the parser or directly on the weapon itself
	
	if self:GetWeaponID() == CS_WEAPON_GLOCK then
		if not primarymode then
			iDamage = 18	-- reduced power for burst shots
			flRangeModifier = 0.9
		end
	elseif self:GetWeaponID() == CS_WEAPON_M4A1 then
		if not primarymode then
			flRangeModifier = 0.95 -- slower bullets in silenced mode
			soundType = "special1"
		end
	elseif self:GetWeaponID() == CS_WEAPON_USP then
		if not primarymode then
			iDamage = 30 -- reduced damage in silenced mode
			soundType = "special1"
		end
	end
	
	self:WeaponSound( soundType )
	
	for iBullet = 1 , pCSInfo.Bullets do
		local r = util.SharedRandom( "Spread" , 0, 2 * math.pi )

		local x = math.sin( r ) * util.SharedRandom( "SpreadX"..iBullet , 0 , 0.5 )
		local y = math.cos( r ) * util.SharedRandom( "SpreadY"..iBullet , 0 , 1 )

		local dir = ang:Forward() +
			x * spread * ang:Right() +
			y * spread * ang:Up()

		dir:Normalize()
		
		
		ply:FireBullets {
			AmmoType = self.Primary.Ammo,
			Distance = pCSInfo.Range,
			Tracer = 1,
			Attacker = ply,
			Damage = iDamage,
			Src = ply:GetShootPos(),
			Dir = dir,
			Spread = vector_origin,
			Callback = function( hitent , trace , dmginfo )
				--TODO: penetration
				--unfortunately this can't be done with a static function or we'd need to set global variables for range and shit
				
				if flRangeModifier then
					--Jvs: the damage modifier valve actually uses
					local flCurrentDistance = trace.Fraction * pCSInfo.Range
					dmginfo:SetDamage( dmginfo:GetDamage() * math.pow( flRangeModifier, ( flCurrentDistance / 500 ) ) )
				end
			end
		}
	end
end

function SWEP:UpdateWorldModel()
end

if CLIENT then
	
	function SWEP:DrawWorldModel()
		self:UpdateWorldModel()
		self:DrawModel()
	end
	
	function SWEP:PreDrawViewModel( vm , weapon , ply )
		if self:IsScoped() then
			return true
		end
	end
	
	function SWEP:GetTracerOrigin()
		--[[
		if IsValid( self:GetOwner() ) then
			local viewmodel = self:GetOwner():GetViewModel( 0 )
			local attch = viewmodel:GetAttachment( "2" )
			if not attch then return end
			return attch.Pos
		end
		]]
	end
	
	--copied straight from weapon_base
	
	function SWEP:FireAnimationEvent( pos, ang, event, options )
		
		if event == 5001 or event == 5011 or event == 5021 or event == 5031 then
			if self:IsSilenced() or self:IsScoped() then
				return true
			end
			
			local data = EffectData()
			data:SetFlags( 0 )
			data:SetEntity( self:GetOwner():GetViewModel() )
			data:SetAttachment( math.floor( ( event - 4991 ) / 10 ) )
			data:SetScale( self:GetWeaponInfo().MuzzleFlashScale )

			if self.CSMuzzleX then
				util.Effect( "CS_MuzzleFlash_X", data )
			else
				util.Effect( "CS_MuzzleFlash", data )
			end
		
			return true
		end

	end
	
	SWEP.ScopeArcTexture = Material( "gmod/scope.vmt" )
	SWEP.ScopeDustTexture = Material( "" )
	SWEP.ScopeFallback = true
	
	--[[
		m_iScopeArcTexture = vgui::surface()->CreateNewTextureID()
		vgui::surface()->DrawSetTextureFile(m_iScopeArcTexture, "sprites/scope_arc", true, false)

		m_iScopeDustTexture = vgui::surface()->CreateNewTextureID()
		vgui::surface()->DrawSetTextureFile(m_iScopeDustTexture, "overlays/scope_lens", true, false)
	]]
	
	function SWEP:DoDrawCrosshair( x , y )
		if self:IsScoped() or self:GetWeaponType() == CS_WEAPONTYPE_SNIPER_RIFLE then
			return true
		end
		return BaseClass.DoDrawCrosshair( self , x , y )
	end
	
	--Jvs: should this technically be done in DoDrawCrosshair? DrawHUD is technically drawn in the gmod hud element
	
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
			
			
			surface.SetDrawColor( color_black )
			surface.SetMaterial( self.ScopeArcTexture )
			
			--Draw the reticle with primitives
			surface.DrawLine( 0, y, screenWide, y )
			surface.DrawLine( x, 0, x, screenTall )
			
			if self.ScopeFallback then
				surface.DrawTexturedRect( x - ( ScrH() / 2	) , 0 , ScrH() , ScrH() )
				--Jvs TODO: fill in the rest of the screen as well
			end
			
			--[[
				Jvs:can't use the code below until I find a good replacement for the scope, or I get Robotboy to add
				the scope texture to gmod
				Alternatively, I could make it so it uses the fallback above if CS:S isn't mounted, which sounds more reasonable
			]]
			
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