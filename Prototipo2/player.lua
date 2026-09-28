local Class = require("lib.hump.class")
local Bullet = require("bullet")

local Player = Class{}

function Player:init(world, x, y)
    self.world = world
    self.x = x
    self.y = y
    
    self.image = love.graphics.newImage("assets/player.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    self.speed = 300
    self.lives = 3

    -- Control de disparo
    self.canShoot = true
    self.shootCooldown = 0.25 -- Tiempo en segundos entre disparos
    self.shootTimer = 0

    self.world:add(self, self.x, self.y, self.width, self.height)
end

function Player:update(dt, bullets)
    -- Movimiento
    local dx = 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        dx = dx - self.speed * dt
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        dx = dx + self.speed * dt
    end

    if dx ~= 0 then
        local nextX = math.max(0, math.min(love.graphics.getWidth() - self.width, self.x + dx))
        self.x, self.y = self.world:move(self, nextX, self.y)
    end

   
    if not self.canShoot then
        self.shootTimer = self.shootTimer + dt
        if self.shootTimer >= self.shootCooldown then
            self.canShoot = true
            self.shootTimer = 0
        end
    end

    -- Disparar con Espacio
    if love.keyboard.isDown("space") and self.canShoot then
        self:shoot(bullets)
    end
end

function Player:shoot(bullets)
    self.canShoot = false
    
    -- Posición X
    local bulletX = self.x + (self.width / 2) - 4
    
    -- Posición Y
    local bulletY = self.y - 30 

    local newBullet = Bullet(self.world, bulletX, bulletY)
    table.insert(bullets, newBullet)
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, self.x, self.y)
end

return Player