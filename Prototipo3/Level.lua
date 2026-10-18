local Class = require 'lib.class'
local Player = require 'Player'

-- Definición de la clase PlatformObj directamente aquí para evitar errores de require
local PlatformObj = Class{}

function PlatformObj:init(x, y, scale)
    self.x = x
    self.y = y
    self.scale = scale or 0.30
    
    self.image = love.graphics.newImage('assets/plataforma.png')
    self.w = self.image:getWidth() * self.scale
    self.h = self.image:getHeight() * self.scale
end

function PlatformObj:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
end

---------------------------------------------------------
-- Clase Level (Nivel principal)
---------------------------------------------------------
local Level = Class{}

function Level:init()
    self.fondo = love.graphics.newImage('assets/fondo-juego.jpg')

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.scaleX = screenWidth / self.fondo:getWidth()
    self.scaleY = screenHeight / self.fondo:getHeight()

    -- Instanciar las plataformas usando PlatformObj localmente
    self.platforms = {
        PlatformObj(80, 410, 0.30),
        PlatformObj(380, 330, 0.30),
        PlatformObj(150, 230, 0.30)
    }

    -- Instanciar al jugador
    self.player = Player(180, 360)
end

function Level:update(dt)
    self.player:update(dt, self.platforms)
end

function Level:draw()
    -- Dibujar fondo
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)

    -- Dibujar cada plataforma
    for _, platform in ipairs(self.platforms) do
        platform:draw()
    end

    -- Dibujar jugador
    self.player:draw()

    -- HUD
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 20, 20, 220, 40, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("HP: " .. self.player.hp .. " | Muni: " .. self.player.ammo, 30, 32)

    -- Volver al menú
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 540, 20, 220, 35, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("ESC para volver al menú", 550, 28)
end

function Level:keypressed(key)
    if key == 'escape' then
        cambiarEstado("menu")
    end
end

function Level:mousepressed(x, y, button)
    if button == 1 then -- Click izquierdo
        self.player:shoot()
    end
end
return Level