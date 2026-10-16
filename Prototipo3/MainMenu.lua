local Class = require 'lib.class'
local MainMenu = Class{}

function MainMenu:init()
    self.fondo = love.graphics.newImage('assets/fondo-inicio.jpg')
    self.btn_start = love.graphics.newImage('assets/start-game.png')
    self.btn_controls = love.graphics.newImage('assets/controls.png')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()
    
    self.btnScale = 0.35 
    
    self.startWidth = self.btn_start:getWidth() * self.btnScale
    self.startHeight = self.btn_start:getHeight() * self.btnScale

    self.ctrlWidth = self.btn_controls:getWidth() * self.btnScale
    self.ctrlHeight = self.btn_controls:getHeight() * self.btnScale

    local gap = 15
    local totalHeight = self.startHeight + self.ctrlHeight + gap

    -- Aumentamos el desplazamiento hacia abajo (+ 60 en lugar de + 10) para que bajen y no tapen el título
    self.start_x = (screenWidth - self.startWidth) / 2
    self.start_y = (screenHeight / 2) - (totalHeight / 2) + 65

    self.controls_x = (screenWidth - self.ctrlWidth) / 2
    self.controls_y = self.start_y + self.startHeight + gap
end

function MainMenu:update(dt)
end

function MainMenu:draw()
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)
    love.graphics.draw(self.btn_start, self.start_x, self.start_y, 0, self.btnScale, self.btnScale)
    love.graphics.draw(self.btn_controls, self.controls_x, self.controls_y, 0, self.btnScale, self.btnScale)
    
    love.graphics.print("v0.1 - Laboratorio Defender", 20, love.graphics.getHeight() - 30)
end

function MainMenu:mousepressed(x, y, button)
    if button == 1 then
        -- Clic en Start Game
        if x >= self.start_x and x <= self.start_x + self.startWidth and 
           y >= self.start_y and y <= self.start_y + self.startHeight then
            cambiarEstado("nivel")
        
        -- Clic en Controls
        elseif x >= self.controls_x and x <= self.controls_x + self.ctrlWidth and 
               y >= self.controls_y and y <= self.controls_y + self.ctrlHeight then
            cambiarEstado("controles")
        end
    end
end

function MainMenu:keypressed(key)
    if key == 'return' or key == 'kpenter' or key == 'space' then
        cambiarEstado("nivel")
    end
end

return MainMenu