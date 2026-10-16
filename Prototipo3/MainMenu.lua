local Class = require 'lib.class'
local MainMenu = Class{}

function MainMenu:init()
    self.fondo = love.graphics.newImage('assets/fondo-inicio.jpg')
    self.btn_start = love.graphics.newImage('assets/start-game.png')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()
    
    self.btnScale = 0.4 
    self.btnWidth = self.btn_start:getWidth() * self.btnScale
    self.btnHeight = self.btn_start:getHeight() * self.btnScale

    self.btn_x = (screenWidth - self.btnWidth) / 2
    self.btn_y = (screenHeight / 2) - (self.btnHeight / 2) + 30
end

function MainMenu:update(dt)
end

function MainMenu:draw()
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)
    love.graphics.draw(self.btn_start, self.btn_x, self.btn_y, 0, self.btnScale, self.btnScale)
    love.graphics.print("v0.1 - Laboratorio Defender", 20, love.graphics.getHeight() - 30)
end

function MainMenu:mousepressed(x, y, button)
    if button == 1 then
        if x >= self.btn_x and x <= self.btn_x + self.btnWidth and 
           y >= self.btn_y and y <= self.btn_y + self.btnHeight then
            cambiarEstado("nivel")
        end
    end
end

function MainMenu:keypressed(key)
    if key == 'return' or key == 'kpenter' or key == 'space' then
        cambiarEstado("nivel")
    end
end

return MainMenu