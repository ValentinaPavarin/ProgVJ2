local Class = require 'lib.class'
local ControlsMenu = Class{}

function ControlsMenu:init()
    -- Puedes cambiar 'controls-menu.jpg' por el nombre de tu imagen o fondo de controles
    self.fondo = love.graphics.newImage('assets/controls-menu.jpg')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()
end

function ControlsMenu:update(dt)
end

function ControlsMenu:draw()
    -- Dibujar fondo de controles
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)
    
    -- Mensaje indicador para regresar
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 250, 530, 300, 40, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Haz clic o presiona ESC para volver", 0, 542, love.graphics.getWidth(), "center")
end

function ControlsMenu:mousepressed(x, y, button)
    if button == 1 then
        cambiarEstado("menu")
    end
end

function ControlsMenu:keypressed(key)
    if key == 'escape' or key == 'return' or key == 'space' then
        cambiarEstado("menu")
    end
end

return ControlsMenu