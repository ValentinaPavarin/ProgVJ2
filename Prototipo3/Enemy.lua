local Class = require 'lib.class'
local Enemy = Class{}

function Enemy:init(x, y, direction)
    self.x = x or -50
    self.y = y or 200
    self.direction = direction or 1 -- 1 derecha, -1 izquierda
    self.speed = 120
    
    self.image = love.graphics.newImage('assets/enemy.png')
    self.scale = 0.50
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale

    self.hp = 20
    self.alive = true
end

function Enemy:update(dt)
    if not self.alive then return end

    -- Moverse en la dirección asignada
    self.x = self.x + (self.speed * self.direction * dt)

    local screenWidth = love.graphics.getWidth()

    -- Reaparecer por el lado contrario al salir de la pantalla
    if self.direction == 1 and self.x > screenWidth + 60 then
        self.x = -50
    elseif self.direction == -1 and self.x < -60 then
        self.x = screenWidth + 60
    end
end

function Enemy:draw()
    if not self.alive then return end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        self.image, 
        self.x, self.y, 
        0, 
        self.direction * self.scale, self.scale, 
        self.image:getWidth() / 2, self.image:getHeight() / 2
    )
end

return Enemy