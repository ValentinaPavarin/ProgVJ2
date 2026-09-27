local Game = require("game")

local game

function love.load()
    -- Configuración de pantalla
    love.window.setTitle("Space Invaders")
    love.window.setMode(800, 600)

    -- Crear la instancia del juego
    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end