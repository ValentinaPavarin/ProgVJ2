local Class = require 'lib.class'
local Level = Class{}

function Level:init()
    self.fondo = love.graphics.newImage('fondo-juego.jpg')
    self.imgPlataforma = love.graphics.newImage('plataforma.png')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()

    -- Plataformas del nivel
    self.platforms = {
        { x = 100, y = 430, scaleX = 0.35, scaleY = 0.35 },
        { x = 400, y = 330, scaleX = 0.35, scaleY = 0.35 },
        { x = 200, y = 220, scaleX = 0.35, scaleY = 0.35 }
    }
end

function Level:update(dt)
end

function Level:draw()
    -- Dibujar fondo del nivel
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)

    -- Dibujar plataformas
    for _, p in ipairs(self.platforms) do
        love.graphics.draw(self.imgPlataforma, p.x, p.y, 0, p.scaleX, p.scaleY)
    end

    -- Texto indicador para volver al menú
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 20, 20, 260, 35, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Presiona ESC para volver al menú", 30, 30)
end

function Level:keypressed(key)
    if key == 'escape' then
        cambiarEstado("menu")
    end
end

return Level