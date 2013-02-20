Boss = { MAX_HEALTH = 15, GRAVITY = 350, JUMP_POWER = 200, IDLE_TIME = 1.5, MAX_JUMP = 128 }
Boss.__index = Boss

local BS_IDLE, BS_JUMP, BS_FLY, BS_LAND = 0,1,2,3

function Boss.create(x,y)
	local self = setmetatable({}, Boss)

	self.alive = true
	self.hit = false
	self.x, self.y = x,y
	self.xspeed, self.yspeed = 0,0
	self.time = self.IDLE_TIME
	self.dir = 1
	self.health = self.MAX_HEALTH
	self.addedFire = false

	self.anims = {}
	self.anims[BS_JUMP] = newAnimation(img.boss_jump, 58, 64, 0.14, 5,
		function() 
			self:setState(BS_FLY)
			self.yspeed = -self.JUMP_POWER
			self.xspeed = 0.93*cap(cap(player.x,194,464) - self.x, -self.MAX_JUMP, self.MAX_JUMP)
			self.addedFire = false
		end
	)
	self.anims[BS_LAND] = newAnimation(img.boss_land, 58, 64, 0.14, 7,
		function()
			self:setState(BS_JUMP)
		end
	)

	self:setState(BS_IDLE)

	return self
end

function Boss:update(dt)
	if self.anim then
		self.anim:update(dt)
	end

	if self.state == BS_IDLE then
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = BS_JUMP
			self.anim = self.anims[BS_JUMP]
		end
	elseif self.state == BS_FLY then
		self.yspeed = self.yspeed + self.GRAVITY*dt
		self.x = self.x + self.xspeed*dt
		self.y = self.y + self.yspeed*dt

		if self.yspeed > 0 and self.y > MAPH-48 then
			self:setState(BS_LAND)
		end
	elseif self.state == BS_LAND then
		self.yspeed = self.yspeed + self.GRAVITY*dt
		self.y = self.y + self.yspeed*dt

		if self.y > MAPH-16 then
			self.y = MAPH-16
			self.yspeed = 0
			if self.addedFire == false then
				map:addFire(math.floor((self.x-8)/16), math.floor((self.y-5)/16))
				map:addFire(math.floor((self.x+8)/16), math.floor((self.y-5)/16))
				ingame.shake = 0.4
				self.addedFire = true
			end
		else
			self.x = self.x + self.xspeed*dt
		end
	end

	self.x = cap(self.x, 194, 464)

	if self.health <= 0 then
		self.y = 1000
	end
end

function Boss:draw()
	self.flx = math.floor(self.x)
	self.fly = math.floor(self.y)

	if self.hit == false then
		if self.state == BS_IDLE then
			self.anims[BS_JUMP]:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64, 1)
		elseif self.state == BS_FLY then
			self.anims[BS_LAND]:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64, 1)
		else
			self.anim:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64)
		end
	else
		if self.state == BS_IDLE then
			self.anims[BS_JUMP]:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64, 1, img.boss_jump_hit)
		elseif self.state == BS_FLY then
			self.anims[BS_LAND]:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64, 1, img.boss_land_hit)
		elseif self.state == BS_JUMP then
			self.anim:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64, nil, img.boss_jump_hit)
		elseif self.state == BS_LAND then
			self.anim:draw(self.flx, self.fly, 0, self.dir, 1, 27, 64, nil, img.boss_land_hit)
		end
	end
	self.hit = false
end

function Boss:collideBox(bbox)
	if self.x-11 > bbox.x+bbox.w or self.x+11 < bbox.x
	or self.y-33 > bbox.y+bbox.h or self.y-7 < bbox.y then
		return false
	else
		return true
	end
end

function Boss:getBBox()
	return {x = self.x-11, y = self.y-33, w = 22, h = 26}
end

function Boss:setState(state)
	self.state = state
	self.anim = self.anims[state]
end

function Boss:shot(dt,dir)
	self.health = self.health - dt
	self.hit = true
end
