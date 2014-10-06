AddCSLuaFile()

function EFFECT:Init( data )
	self.EntIndex = data:GetEntIndex()
	self.Origin = data:GetOrigin()
	self.Exponent = 2
	self.Radius = 400
	self.Time = 0.1
	self.Decay = 768
	
	self.DynamicLight = DynamicLight( self.EntIndex )
	self.DynamicLight.pos = self.Origin
	self.DynamicLight.dietime = CurTime() + self.Time
	self.DynamicLight.r = color_white.r
	self.DynamicLight.g = color_white.g
	self.DynamicLight.b = color_white.b
	self.DynamicLight.decay = self.Decay
	self.DynamicLight.brightness = self.Exponent
	
end

function EFFECT:Think()
	return self.DynamicLight and self.DynamicLight.dietime > CurTime()
end

function EFFECT:Render()

end