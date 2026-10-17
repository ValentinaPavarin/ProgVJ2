local Class = require 'lib.class'
local EventDispatcher = require 'EventDispatcher'

local Player = Class{}

function Player:init(x, y)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.speed = 220
    self.gravity = 950
    self.jumpForce = -440

    self.facing = 1 -- 1 derecha, -1 izquierda

    -- Cargar recursos
    self.idleImg = love.graphics.newImage('assets/hurt.png')
    self.walkSheet = love.graphics.newImage('assets/walk.png')
    self.jumpSheet = love.graphics.newImage('assets/jump.png')

    self.walkFrames = self:loadQuads(self.walkSheet, 8)
    self.jumpFrames = self:loadQuads(self.jumpSheet, 8)

    self.animTimer = 0
    self.currentFrame = 1
    self.isGrounded = false

    -- Dimensiones de la caja de colisión del jugador (centrada)
    self.width = 24
    self.height = 50

    -- Atributos de juego
    self.hp = 100
    self.maxHp = 100
    self.ammo = 30
end

function Player:loadQuads(image, frameCount)
    local quads = {}
    local imgW = image:getWidth()
    local imgH = image:getHeight()
    local frameW = imgW / frameCount
    local frameH = imgH

    for i = 0, frameCount - 1 do
        table.insert(quads, love.graphics.newQuad(i * frameW, 0, frameW, frameH, imgW, imgH))
    end
    return quads
end

function Player:update(dt, platforms)
    -- Movimiento horizontal
    self.vx = 0
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.vx = self.speed
        self.facing = 1
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.vx = -self.speed
        self.facing = -1
    end

    self.x = self.x + self.vx * dt

    -- Limitar al jugador dentro de la pantalla (anchura de la ventana = 800 por defecto en Love2D)
    local screenWidth = love.graphics.getWidth()
    if self.x < self.width / 2 then
        self.x = self.width / 2
    elseif self.x > screenWidth - self.width / 2 then
        self.x = screenWidth - self.width / 2
    end

    -- Salto
    if (love.keyboard.isDown('space') or love.keyboard.isDown('w')) and self.isGrounded then
        self.vy = self.jumpForce
        self.isGrounded = false
        EventDispatcher.publish("PLAYER_JUMPED")
    end

    -- Aplicar gravedad vertical
    self.vy = self.vy + self.gravity * dt
    self.y = self.y + self.vy * dt

    -- Por defecto asumimos que está en el aire
    self.isGrounded = false

    -- Comprobar colisiones estrictas con los rectángulos de las plataformas
    -- Dentro de Player:update(dt, platforms)
    if platforms then
        for _, p in ipairs(platforms) do
            local feetY = self.y + self.height / 2
            local prevFeetY = feetY - (self.vy * dt)

            -- Usando el rectángulo exacto (p.x, p.y, p.w, p.h) de la clase Platform
            if self.x + self.width / 3 > p.x and self.x - self.width / 3 < p.x + p.w then
                if prevFeetY <= p.y + 4 and feetY >= p.y and self.vy >= 0 then
                    self.y = p.y - self.height / 2
                    self.vy = 0
                    self.isGrounded = true
                    break
                end
            end
        end
    end

    -- Suelo inferior absoluto del nivel (por si cae al fondo)
    local floorY = 480
    if (self.y + self.height / 2) >= floorY then
        self.y = floorY - self.height / 2
        self.vy = 0
        self.isGrounded = true
    end

    -- Actualizar animaciones
    if self.vx ~= 0 and self.isGrounded then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 0.1 then
            self.animTimer = 0
            self.currentFrame = (self.currentFrame % #self.walkFrames) + 1
        end
    elseif not self.isGrounded then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 0.08 then
            self.animTimer = 0
            self.currentFrame = (self.currentFrame % #self.jumpFrames) + 1
        end
    else
        self.currentFrame = 1
    end
end

function Player:draw()
    local scale = 0.16

    if not self.isGrounded then
        local q = self.jumpFrames[self.currentFrame]
        local _, _, w, h = q:getViewport()
        love.graphics.draw(self.jumpSheet, q, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    elseif self.vx ~= 0 then
        local q = self.walkFrames[self.currentFrame]
        local _, _, w, h = q:getViewport()
        love.graphics.draw(self.walkSheet, q, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    else
        local w, h = self.idleImg:getWidth(), self.idleImg:getHeight()
        love.graphics.draw(self.idleImg, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    end
end

return Player