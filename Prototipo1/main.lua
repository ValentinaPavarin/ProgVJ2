local Jugador = require("jugador")
local Enemigo = require("enemigo")

local jugador
local murcielagos = {}
local totalMurcielagos = 10
local murcielagosDerrotados = 0

-- Temporizador de generación
local spawnTimer = 0
local spawnIntervalo = 2.0 

local imgCielo, imgSuelo
local estadoJuego = "JUGANDO"

-- Sonidos de Fin de Juego
local sndVictoria, sndDerrota
local sonidoFinReproducido = false

local function colision(a, b)
    local margenX = 15
    local margenY = 10

    local a_left = a.x + margenX
    local a_right = a.x + a.ancho - margenX
    local a_top = a.y + margenY
    local a_bottom = a.y + a.alto - margenY

    local b_left = b.x + margenX
    local b_right = b.x + b.ancho - margenX
    local b_top = b.y + margenY
    local b_bottom = b.y + b.alto - margenY

    return a_left < b_right and
           a_right > b_left and
           a_top < b_bottom and
           a_bottom > b_top
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")

    imgCielo = love.graphics.newImage("assets/cielo.png")
    imgSuelo = love.graphics.newImage("assets/suelo.png")

    -- Cargar Sonidos de Sistema
    sndVictoria = love.audio.newSource("assets/victoria.wav", "static")
    sndDerrota = love.audio.newSource("assets/derrota.wav", "static")

    jugador = Jugador.nuevo()
    Enemigo.cargarRecursos()
end

function love.keypressed(key)
    if estadoJuego ~= "JUGANDO" then return end

    if key == "space" then
        jugador:saltar()
    end
end

function love.mousepressed(x, y, button)
    if estadoJuego ~= "JUGANDO" then return end

    if button == 1 then
        jugador:atacar()
    end
end

function love.update(dt)
    if estadoJuego ~= "JUGANDO" then return end

    jugador:update(dt)
    Enemigo.actualizarAnimacion(dt)

    -- Aparición continua
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnIntervalo then
        spawnTimer = 0
        table.insert(murcielagos, Enemigo.nuevo())
    end

    -- Actualización y colisiones de murciélagos
    for i = #murcielagos, 1, -1 do
        local m = murcielagos[i]
        if m.activo then
            m:update(dt)

            if colision(jugador, m) then
                if jugador.atacando then
                    m.activo = false
                    murcielagosDerrotados = murcielagosDerrotados + 1
                else
                    jugador:recibirDano()
                    m.activo = false
                end
            elseif m.x < -m.ancho then
                m.activo = false
            end
        end
    end

    -- Verificación de fin de juego y reproducción de audio final
    if jugador.vidas <= 0 then
        estadoJuego = "DERROTA"
        if not sonidoFinReproducido then
            sndDerrota:play()
            sonidoFinReproducido = true
        end
    elseif murcielagosDerrotados >= totalMurcielagos then
        estadoJuego = "VICTORIA"
        if not sonidoFinReproducido then
            sndVictoria:play()
            sonidoFinReproducido = true
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- Dibujar escenario
    love.graphics.draw(imgCielo, 0, 0, 0, love.graphics.getWidth() / imgCielo:getWidth(), love.graphics.getHeight() / imgCielo:getHeight())
    
    local escalaSueloX = love.graphics.getWidth() / imgSuelo:getWidth()
    love.graphics.draw(imgSuelo, 0, 480, 0, escalaSueloX, 1)

    -- Dibujar murciélagos
    for _, m in ipairs(murcielagos) do
        m:draw()
    end

    -- Dibujar jugador
    jugador:draw(estadoJuego)

    -- HUD
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Vidas: " .. jugador.vidas, 20, 20)
    love.graphics.print("Murcielagos eliminados: " .. murcielagosDerrotados .. "/" .. totalMurcielagos, 20, 40)
    love.graphics.print("A/D: Moverse | ESPACIO: Saltar | CLIC: Atacar", 20, 60)

    -- Mensajes finales
    if estadoJuego == "VICTORIA" then
        love.graphics.setColor(0, 0.6, 0, 1)
        love.graphics.print("¡VICTORIA! Eliminaste a todos los murcielagos", 220, 250, 0, 1.5, 1.5)
    elseif estadoJuego == "DERROTA" then
        love.graphics.setColor(0.8, 0, 0, 1)
        love.graphics.print("GAME OVER - El jugador ha sido derrotado", 220, 250, 0, 1.5, 1.5)
    end
end