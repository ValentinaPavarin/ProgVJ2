local Class = require("lib.hump.class")

local Starfield = Class{}

function Starfield:init(numStars)
    self.stars = {}
    self.numStars = numStars or 80

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Crear estrellas con posiciones y velocidades aleatorias
    for i = 1, self.numStars do
        table.insert(self.stars, {
            x = math.random(0, screenW),
            y = math.random(0, screenH),
            speed = math.random(20, 120),  -- Las más rápidas parecen estar más cerca
            size = math.random(1, 3)       -- Tamaño según la profundidad
        })
    end
end

function Starfield:update(dt)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    for _, star in ipairs(self.stars) do
        -- Mover estrella hacia abajo
        star.y = star.y + star.speed * dt

        -- Si sale de la pantalla por abajo, reaparece arriba en X aleatoria
        if star.y > screenH then
            star.y = 0
            star.x = math.random(0, screenW)
        end
    end
end

function Starfield:draw()
    for _, star in ipairs(self.stars) do
        -- Las estrellas más rápidas dibujan más brillantes
        local brightness = star.speed / 120
        love.graphics.setColor(brightness, brightness, brightness)
        love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
    end
    -- Resetear color a blanco para no afectar el resto del dibujo
    love.graphics.setColor(1, 1, 1)
end

return Starfield