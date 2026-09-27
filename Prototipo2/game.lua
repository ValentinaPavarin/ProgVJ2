local Class = require("lib.hump.class")
local bump = require("lib.bump")
local Player = require("player")

local Game = Class{}

function Game:init()
    self.world = bump.newWorld(32)
    
    self.score = 0
    self.isGameOver = false
    self.isVictory = false

    -- Lista de balas activas
    self.bullets = {}

    local startX = (love.graphics.getWidth() / 2) - 16
    local startY = love.graphics.getHeight() - 50
    self.player = Player(self.world, startX, startY)
end

function Game:update(dt)
    if not self.isGameOver and not self.isVictory then
        self.player:update(dt, self.bullets)

        -- Actualizar y limpiar balas
        for i = #self.bullets, 1, -1 do
            local b = self.bullets[i]
            b:update(dt)

            if b.isDead then
                table.remove(self.bullets, i)
            end
        end
    end
end

function Game:draw()
    self.player:draw()
    
    -- Dibujar todas las balas
    for _, b in ipairs(self.bullets) do
        b:draw()
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. self.score, 10, 10)
end

return Game