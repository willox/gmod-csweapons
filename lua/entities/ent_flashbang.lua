AddCSLuaFile()

DEFINE_BASECLASS( "ent_basecsgrenade" )

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/weapons/w_eq_flashbang_thrown.mdl" )
	end
	BaseClass.Initialize( self )	--Jvs: garry's setmodel crap also sets the collision bounds, so I have to do this here last
end

function ENT:Detonate()
	self:RadiusFlash( self:GetPos() , self , self:GetThrower() , 4 , DMG_BLAST )
	self:EmitSound( "Flashbang.Explode" )
	self:Remove()
end


function ENT:BounceSound()
	self:EmitSound( "Flashbang.Bounce" )
end

local function PercentageOfFlashForEntity( pEntity , flashPos , pevInflictor )
	local retval = 0
	local tr
	
	local pos = pEntity:EyePos()
	local vecRight , vecUp
	
	local tempAngle = pos - flashPos
	tempAngle = tempAngle:Angle()
	
	vecRight = tempAngle:Right()
	vecUp = tempAngle:Up()
	
	vecRight:Normalize()
	vecUp:Normalize()
	
	tr = util.TraceLine {
		start = flashPos,
		endpos = pos,
		mask = bit.bor( CONTENTS_SOLID , CONTENTS_MOVEABLE , CONTENTS_DEBRIS , CONTENTS_MONSTER ),
		filter = pevInflictor
	}
	if tr.Fraction == 1 or tr.Entity == pEntity then
		return 1
	end
	
	--[[
	if not pPlayer:IsPlayer() then
		return 0
	end
	]]
	
	for i = 1 , 3 do
	
		if i == 1 then
			pos = flashPos + vecUp * 50
		else
			pos = flashPos + vecRight * 75 + vecUp * 10
		end
		
		tr = util.TraceLine {
			start = flashPos,
			endpos = pos,
			mask = bit.bor( CONTENTS_SOLID , CONTENTS_MOVEABLE , CONTENTS_DEBRIS , CONTENTS_MONSTER ),
			filter = pevInflictor
		}
		
		pos = pEntity:EyePos()
		
		tr = util.TraceLine {
			start = tr.HitPos,
			endpos = pos,
			mask = bit.bor( CONTENTS_SOLID , CONTENTS_MOVEABLE , CONTENTS_DEBRIS , CONTENTS_MONSTER ),
			filter = pevInflictor
		}
		
		if tr.Fraction == 1 or tr.Entity == pEntity then
			retval = retval + 0.167
		end
		
	end
	
	return retval
end

function ENT:RadiusFlash( pos , inflictor , attacker , flDamage , damagetype )
	pos.z = pos.z + 1
	if not IsValid( attacker ) then
		attacker = inflictor
	end
	
	local tr
	local flAdjustedDamage
	local vecEyePos
	local fadeTime = 0
	local fadeHold = 0
	local vForward
	local vecLOS
	local flDot
	
	local flRadius = 1500
	local falloff = flDamage / flRadius
	
	local bInWater = util.PointContents( pos ) == CONTENTS_WATER
	
	for _ , pEntity in pairs( ents.FindInSphere( pos , flRadius ) ) do
		local bPlayer = pEntity:IsPlayer()
		local bHostage = pEntity:GetClass() == "hostage_entity"
		
		if not bPlayer and not bHostage then
			continue
		end
		
		vecEyePos = pEntity:EyePos()
		
		if bInWater and pEntity:WaterLevel() == 0 then
			continue
		end
		
		if not bInWater and pEntity:WaterLevel() == 3 then
			continue
		end
		
		local percentageOfFlash = PercentageOfFlashForEntity( pEntity , pos , inflictor )
		if percentageOfFlash > 0 then
			flAdjustedDamage = flDamage - ( pos - vecEyePos ):Length() * falloff
			if flAdjustedDamage > 0 then
				vForward = pEntity:EyeAngles():Forward()
				vecLOS = ( pos - vecEyePos )
				local flDistance = vecLOS:Length()
				
				vecLOS:Normalize()
				
				flDot = vecLOS:Dot( vForward )
				
				local startingAlpha = 255
				
				if flDot >= 0.5 then
					fadeTime = flAdjustedDamage * 2.5
					fadeHold = flAdjustedDamage * 1.25
				elseif flDot >= -0.5 then
					fadeHold = flAdjustedDamage * 1.75
					fadeHold = flAdjustedDamage * 0.8
				else
					fadeTime = flAdjustedDamage * 1
					fadeHold = flAdjustedDamage * 0.75
					startingAlpha = 200
				end
				
				fadeTime = fadeTime * percentageOfFlash
				fadeHold = fadeHold * percentageOfFlash
				
				if bPlayer then
					self:BlindPlayer( pEntity , fadeHold , fadeTime , startingAlpha )
					self:DeafenPlayer( pEntity , flDistance )
				elseif bHostage then
					pEntity:Input( "flashbang" , inflictor , attacker , fadeTime )
				end
				
			end
		end
	end
	
	local te = EffectData()
	te:SetOrigin( pos )
	te:SetMaterialIndex( self:EntIndex() )	--used only for the dynamic light index, doesn't matter if the entity goes invalid afterwards
	
	util.Effect( "flashbang_light" , te )
end

function ENT:BlindPlayer( pPlayer , holdTime , fadeTime , startingAlpha )
	local clr = Color( 255 , 255 , 255 , startingAlpha )
	
	if pPlayer:GetObserverMode() ~= OBS_MODE_NONE and pPlayer:GetObserverMode() ~= OBS_MODE_IN_EYE then
		clr.a = 150
		fadeTime = math.min( fadeTime , 0.5 )				-- make sure the spectator flashbang time is 1/2 second or less.
		holdTime = math.min( holdTime , fadeTime * 0.5 )	-- adjust the hold time to match the fade time.
	else
		fadeTime = fadeTime / 1.4
	end
	
	--Jvs: there's some other code here about extending the duration if the user is already blinded but I don't give a damn
	pPlayer:ScreenFade( SCREENFADE.IN , clr , fadeTime, holdTime )
end

function ENT:DeafenPlayer( pPlayer , flDistance )
	if pPlayer:GetObserverMode() == OBS_MODE_NONE or pPlayer:GetObserverMode() == OBS_MODE_IN_EYE then
		local effect
		
		if flDistance < 600 then
			effect = 35--134
		elseif flDistance < 800 then
			effect = 36--135
		elseif flDistance < 1000 then
			effect = 37--136
		else
			return
		end
		pPlayer:SetDSP( effect , false )
	end
end


