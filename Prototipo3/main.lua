local Class = require 'lib.class'

---------------------------------------------------
-- CLASE MENU PRINCIPAL
---------------------------------------------------
local Menu = Class{}

function Menu:init()
    self.fondo = love.graphics.newImage('assets/fondo-inicio.jpg')
    self.btn_start = love.graphics.newImage('assets/start-game.png')
    self.btn_controls = love.graphics.newImage('assets/controls.png')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()
    self.btnScale = 0.35 
    
    local btnWidth = self.btn_start:getWidth() * self.btnScale
    local btnHeight = self.btn_start:getHeight() * self.btnScale

    self.start_x = (screenWidth - btnWidth) / 2
    self.start_y = screenHeight / 2 + 30

    self.controls_x = (screenWidth - btnWidth) / 2
    self.controls_y = self.start_y + btnHeight + 15
end

function Menu:update(dt)
end

function Menu:draw()
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)
    love.graphics.draw(self.btn_start, self.start_x, self.start_y, 0, self.btnScale, self.btnScale)
    love.graphics.draw(self.btn_controls, self.controls_x, self.controls_y, 0, self.btnScale, self.btnScale)
    love.graphics.print("v0.1 - Laboratorio Defender", 20, love.graphics.getHeight() - 30)
end

function Menu:mousepressed(x, y, button)
    if button == 1 then
        local sw = self.btn_start:getWidth() * self.btnScale
        local sh = self.btn_start:getHeight() * self.btnScale

        -- Clic en START GAME
        if x >= self.start_x and x <= self.start_x + sw and y >= self.start_y and y <= self.start_y + sh then
            print("¡Iniciando juego...")
        
        -- Clic en CONTROLS
        elseif x >= self.controls_x and x <= self.controls_x + sw and y >= self.controls_y and y <= self.controls_y + sh then
            cambiarEstado("controles")
        end
    end
end


---------------------------------------------------
-- CLASE MENÚ DE CONTROLES
---------------------------------------------------
local ControlsMenu = Class{}

function ControlsMenu:init()
    -- Asegúrate de guardar la imagen con este nombre exacto en la raíz
    self.imgControls = love.graphics.newImage('assets/controls-menu.jpg')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Escalar la imagen de controles para que cubra exactamente toda la pantalla
    self.scaleX = screenWidth / self.imgControls:getWidth()
    self.scaleY = screenHeight / self.imgControls:getHeight()
end

function ControlsMenu:update(dt)
end

function ControlsMenu:draw()
    -- Dibuja la imagen ocupando toda la pantalla (800x600)[cite: 8]
    love.graphics.draw(self.imgControls, 0, 0, 0, self.scaleX, self.scaleY)
    
    -- Pequeño aviso abajo para indicar cómo volver
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 250, 550, 300, 30, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Haz clic en cualquier parte para volver", 0, 556, love.graphics.getWidth(), "center")
end

function ControlsMenu:mousepressed(x, y, button)
    if button == 1 then
        -- Con un clic en cualquier parte de la pantalla vuelve al menú principal
        cambiarEstado("menu")
    end
end


---------------------------------------------------
-- CONTROLADOR DE ESTADOS GLOBAL
---------------------------------------------------
local estadoActual = nil

function cambiarEstado(nuevoEstado)
    if nuevoEstado == "menu" then
        estadoActual = Menu()
    elseif nuevoEstado == "controles" then
        estadoActual = ControlsMenu()
    end
end

function love.load()
    cambiarEstado("menu")
end

function love.update(dt)
    if estadoActual and estadoActual.update then estadoActual:update(dt) end
end

function love.draw()
    if estadoActual and estadoActual.draw then estadoActual:draw() end
end

function love.mousepressed(x, y, button)
    if estadoActual and estadoActual.mousepressed then estadoActual:mousepressed(x, y, button) end
end