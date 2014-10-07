AddCSLuaFile()

function EFFECT:Init( data )
	self._EntIndex = data:GetMaterialIndex()
	print( self._EntIndex )
	self.Origin = data:GetOrigin()
	self.Exponent = 2
	self.Radius = 400
	self.Time = 0.1
	self.Decay = 768
	
	self.DynamicLight = DynamicLight( self._EntIndex )
	self.DynamicLight.pos = self.Origin
	self.DynamicLight.dietime = CurTime() + self.Time
	self.DynamicLight.r = color_white.r
	self.DynamicLight.g = color_white.g
	self.DynamicLight.b = color_white.b
	self.DynamicLight.decay = self.Decay
	self.DynamicLight.brightness = self.Exponent
	self.DynamicLight.size = self.Radius
	self.DieTime = CurTime() + self.Time
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end