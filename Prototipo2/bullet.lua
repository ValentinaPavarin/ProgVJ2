local Class = require("lib.hump.class")

local Bullet = Class{}

local function bulletFilter(item, other)
    if other.scoreValue then
        return "touch"
    end
    return nil
end

function Bullet:init(world, x, y)
    self.world = world
    self.x = x
    self.y = y
    
    self.image = love.graphics.newImage("assets/bullet.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    self.speed = 500
    self.isDead = false

    self.world:add(self, self.x, self.y, self.width, self.height)
end

function Bullet:update(dt, game)
    if self.isDead then return end

    local futureY = self.y - self.speed * dt
    local actualX, actualY, cols, len = self.world:move(self, self.x, futureY, bulletFilter)
    self.x = actualX
    self.y = actualY

    for i = 1, len do
        local other = cols[i].other
        if other.scoreValue and not other.isDead then
            other:destroy()
            self:destroy()
            if game then
                game:addScore(other.scoreValue)
            end
            break
        end
    end

    if self.y + self.height < 0 then
        self:destroy()
    end
end

function Bullet:destroy()
    if not self.isDead then
        self.isDead = true
        if self.world:hasItem(self) then
            self.world:remove(self)
        end
    end
end

function Bullet:draw()
    if not self.isDead then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.image, self.x, self.y)
    end
end

return Bullet