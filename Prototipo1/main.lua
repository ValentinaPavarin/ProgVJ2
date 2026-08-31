local cieloImg
local sueloImg

function love.load()
    love.window.setTitle("Prototipo - Escenario")
    love.window.setMode(800, 600)

    -- Cargar Fondos 
    if love.filesystem.getInfo("assets/sprites/cielo.png") then
        cieloImg = love.graphics.newImage("assets/sprites/cielo.png")
    end

    if love.filesystem.getInfo("assets/sprites/suelo.png") then
        sueloImg = love.graphics.newImage("assets/sprites/suelo.png")
    end
end

function love.update(dt)
    -- Lógica general del escenario si hiciera falta a futuro
end

function love.draw()
    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()
    local altoSuelo = 150
    local ySuelo = altoPantalla - altoSuelo

    -- 1. Dibujar Cielo
    if cieloImg then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(cieloImg, 0, 0, 0, anchoPantalla / cieloImg:getWidth(), altoPantalla / cieloImg:getHeight())
    else
        love.graphics.setColor(0.4, 0.7, 1) -- Azul para el cielo de respaldo
        love.graphics.rectangle("fill", 0, 0, anchoPantalla, altoPantalla)
    end

    -- 2. Dibujar Suelo
    if sueloImg then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sueloImg, 0, ySuelo, 0, anchoPantalla / sueloImg:getWidth(), altoSuelo / sueloImg:getHeight())
    else
        love.graphics.setColor(0.3, 0.7, 0.3) -- Verde para el suelo de respaldo
        love.graphics.rectangle("fill", 0, ySuelo, anchoPantalla, altoSuelo)
    end
end