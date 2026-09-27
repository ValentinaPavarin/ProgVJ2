local Class = require("lib.hump.class")

local Bullet = Class{}

function Bullet:init(world, x, y)
    self.world = world
    self.x = x
    self.y = y
    self.width = 4
    self.height = 10
    self.speed = 500
    self.isDead = false

    -- Registrar la bala en Bump
    self.world:add(self, self.x, self.y, self.width, self.height)
end

function Bullet:update(dt)
    -- Mover la bala hacia arriba
    local nextY = self.y - self.speed * dt

    local actualX, actualY, cols, len = self.world:move(self, self.x, nextY)
    self.x = actualX
    self.y = actualY

    -- Si sale de la pantalla por la parte superior, marcar para eliminar
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
    love.graphics.setColor(1, 1, 0) -- Amarillo
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1) -- Resetear color
end

return Bullet