local Class = require("lib.hump.class")
local bump = require("lib.bump")
local Player = require("player")

local Game = Class{}

function Game:init()
    -- Crear el mundo de colisiones de Bump
    self.world = bump.newWorld(32)
    
    self.score = 0
    self.isGameOver = false
    self.isVictory = false

    -- Instanciar al jugador centrado en la parte inferior
    local startX = (love.graphics.getWidth() / 2) - 16
    local startY = love.graphics.getHeight() - 50
    self.player = Player(self.world, startX, startY)
end

function Game:update(dt)
    if not self.isGameOver and not self.isVictory then
        self.player:update(dt)
    end
end

function Game:draw()
    self.player:draw()
    
    -- Dibujar puntaje en pantalla
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. self.score, 10, 10)
end

return Game