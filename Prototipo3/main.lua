local Class = require 'lib.class'
local Menu = Class{}

function Menu:init()
    self.fondo = love.graphics.newImage('assets/fondo-inicio.jpg')
    self.btn_start = love.graphics.newImage('assets/start-game.png')
    self.btn_controls = love.graphics.newImage('assets/controls.png')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Escala para que el fondo cubra toda la pantalla de 800x600
    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()

    -- Escala más chica para los botones
    self.btnScale = 0.35 
    
    local btnWidth = self.btn_start:getWidth() * self.btnScale
    local btnHeight = self.btn_start:getHeight() * self.btnScale

    -- Posiciones centradas y más abajo para que no pisen el título
    self.start_x = (screenWidth - btnWidth) / 2
    self.start_y = screenHeight / 2 + 30

    self.controls_x = (screenWidth - btnWidth) / 2
    self.controls_y = self.start_y + btnHeight + 15
end

function Menu:update(dt)
end

function Menu:draw()
    -- Dibujar el fondo escalado a la pantalla
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)

    -- Dibujar botones ajustados
    love.graphics.draw(self.btn_start, self.start_x, self.start_y, 0, self.btnScale, self.btnScale)
    love.graphics.draw(self.btn_controls, self.controls_x, self.controls_y, 0, self.btnScale, self.btnScale)
    
    love.graphics.print("v0.1 - Laboratorio Defender", 20, love.graphics.getHeight() - 30)
end

function Menu:mousepressed(x, y, button)
    if button == 1 then
        local sw = self.btn_start:getWidth() * self.btnScale
        local sh = self.btn_start:getHeight() * self.btnScale
        if x >= self.start_x and x <= self.start_x + sw and y >= self.start_y and y <= self.start_y + sh then
            print("¡Iniciando juego!")
        end
    end
end

local menuActual = nil

function love.load()
    menuActual = Menu()
end

function love.update(dt)
    if menuActual and menuActual.update then menuActual:update(dt) end
end

function love.draw()
    if menuActual and menuActual.draw then menuActual:draw() end
end

function love.mousepressed(x, y, button)
    if menuActual and menuActual.mousepressed then menuActual:mousepressed(x, y, button) end
end