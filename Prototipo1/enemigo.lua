local Enemigo = {}
Enemigo.__index = Enemigo

local imgBat = nil
local batQuads = {}
local batFrame = 1
local batTimer = 0
local batFrameTime = 0.15

function Enemigo.cargarRecursos()
    if not imgBat then
        imgBat = love.graphics.newImage("assets/bat.png")
        local batAnchoFrame = imgBat:getWidth() / 2
        local batAltoFrame = imgBat:getHeight()

        batQuads[1] = love.graphics.newQuad(0, 0, batAnchoFrame, batAltoFrame, imgBat:getWidth(), imgBat:getHeight())
        batQuads[2] = love.graphics.newQuad(batAnchoFrame, 0, batAnchoFrame, batAltoFrame, imgBat:getWidth(), imgBat:getHeight())
    end
end

function Enemigo.actualizarAnimacion(dt)
    batTimer = batTimer + dt
    if batTimer >= batFrameTime then
        batTimer = 0
        batFrame = (batFrame % 2) + 1
    end
end

function Enemigo.nuevo()
    local self = setmetatable({}, Enemigo)

    local batAnchoFrame = imgBat:getWidth() / 2
    local batAltoFrame = imgBat:getHeight()

    -- Aparecen justo fuera del borde derecho de la pantalla
    self.x = love.graphics.getWidth() + 50
    -- Altura ajustada: entre 300px y 420px (al alcance de los saltos y ataques)
    self.y = math.random(300, 420)
    
    self.ancho = batAnchoFrame
    self.alto = batAltoFrame
    
    -- Velocidad horizontal constante de avance hacia la izquierda
    self.velX = math.random(-180, -120)
    -- Oscilación vertical suave alcanzable
    self.velY = math.random(-30, 30)
    self.activo = true

    return self
end

function Enemigo:update(dt)
    if not self.activo then return end

    self.x = self.x + self.velX * dt
    self.y = self.y + self.velY * dt

    -- Mantener la oscilación vertical en un rango alcanzable
    if self.y < 280 or self.y > 430 then
        self.velY = -self.velY
    end
end

function Enemigo:draw()
    if self.activo then
        love.graphics.draw(imgBat, batQuads[batFrame], self.x, self.y, 0, 2, 2)
    end
end

return Enemigo