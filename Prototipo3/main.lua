local Menu = require 'Menu'
local Level = require 'Level'

local estadoActual = nil

function cambiarEstado(nuevoEstado)
    if nuevoEstado == "menu" then
        estadoActual = Menu()
    elseif nuevoEstado == "nivel" then
        estadoActual = Level()
    end
end

function love.load()
    cambiarEstado("menu")
end

function love.update(dt)
    if estadoActual and estadoActual.update then 
        estadoActual:update(dt) 
    end
end

function love.draw()
    if estadoActual and estadoActual.draw then 
        estadoActual:draw() 
    end
end

function love.mousepressed(x, y, button)
    if estadoActual and estadoActual.mousepressed then 
        estadoActual:mousepressed(x, y, button) 
    end
end

function love.keypressed(key)
    if estadoActual and estadoActual.keypressed then 
        estadoActual:keypressed(key) 
    end
end