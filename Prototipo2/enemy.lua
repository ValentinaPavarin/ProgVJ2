local Class = require("lib.hump.class")

local Enemy = Class{}

function Enemy:init(world, x, y)
    self.world = world
    self.x = x
    self.y = y
    
    self.image = love.graphics.newImage("assets/enemy.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    self.speed = 100
    self.scoreValue = 100
    self.isDead = false

   
    self.world:add(self, self.x, self.y, self.width, self.height)
end

function Enemy:update(dt)
    if self.isDead then return end 

    self.y = self.y + self.speed * dt
    self.x, self.y = self.world:move(self, self.x, self.y)

    if self.y > love.graphics.getHeight() then
        self:destroy()
    end
end

function Enemy:destroy()
    if not self.isDead then
        self.isDead = true
        if self.world:hasItem(self) then
            self.world:remove(self)
        end
    end
end

function Enemy:draw()
    if not self.isDead then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.image, self.x, self.y)
    end
end

return Enemy