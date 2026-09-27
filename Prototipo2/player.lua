local Class = require("lib.hump.class")

local Player = Class{}

function Player:init(world, x, y)
    self.world = world
    self.x = x
    self.y = y
    
    -- Cargar sprite
    self.image = love.graphics.newImage("assets/player.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    self.speed = 300
    self.lives = 3

    -- Registrar al jugador en Bump
    self.world:add(self, self.x, self.y, self.width, self.height)
end

function Player:update(dt)
    local dx = 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        dx = dx - self.speed * dt
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        dx = dx + self.speed * dt
    end

    -- Mover y limitar horizontalmente a la pantalla
    if dx ~= 0 then
        local nextX = math.max(0, math.min(love.graphics.getWidth() - self.width, self.x + dx))
        self.x, self.y = self.world:move(self, nextX, self.y)
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, self.x, self.y)
end

return Player