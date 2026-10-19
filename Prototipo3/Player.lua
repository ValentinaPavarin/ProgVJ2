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

    -- Cargar recursos visuales
    self.idleImg = love.graphics.newImage('assets/hurt.png')
    self.walkSheet = love.graphics.newImage('assets/walk.png')
    self.jumpSheet = love.graphics.newImage('assets/jump.png')
    self.attackSheet = love.graphics.newImage('assets/attack.png')
    self.bulletImg = love.graphics.newImage('assets/municion.png')

   
     self.shootSound = (pcall(love.audio.newSource, 'assets/disparo.wav', 'static')) and love.audio.newSource('assets/disparo.wav', 'static') or nil
     self.jumpSound = (pcall(love.audio.newSource, 'assets/salto.wav', 'static')) and love.audio.newSource('assets/salto.wav', 'static') or nil
     self.hurtSound = (pcall(love.audio.newSource, 'assets/danio.wav', 'static')) and love.audio.newSource('assets/danio.wav', 'static') or nil

    self.walkFrames = self:loadQuads(self.walkSheet, 8)
    self.jumpFrames = self:loadQuads(self.jumpSheet, 8)
    self.attackFrames = self:loadQuads(self.attackSheet, 2) -- 2 frames exactos

    self.animTimer = 0
    self.currentFrame = 1
    self.isGrounded = false
    self.isAttacking = false
    self.attackTimer = 0

    -- Dimensiones de colisión
    self.width = 24
    self.height = 50

    -- Atributos de juego
    self.hp = 100
    self.maxHp = 100
    self.ammo = 30

    -- Lista de proyectiles activos del jugador
    self.bullets = {}
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

-- Función para disparar mediante evento personalizado
function Player:shoot()
    if self.ammo > 0 then
        self.ammo = self.ammo - 1
        self.isAttacking = true
        self.attackTimer = 0.25 -- Duración visual del ataque
        self.currentFrame = 1 -- Reiniciar frame al empezar a disparar

        -- Reproducir sonido de disparo si existe
        if self.shootSound then
            self.shootSound:stop()
            self.shootSound:play()
        end

        -- Crear proyectil
        local bulletX = self.x + (self.facing * 20)
        local bulletY = self.y - 5
        table.insert(self.bullets, {
            x = bulletX,
            y = bulletY,
            vx = self.facing * 500,
            facing = self.facing
        })

        -- Disparar evento personalizado
        EventDispatcher.publish("PLAYER_SHOOT", self.ammo)
    end
end

function Player:update(dt, platforms, enemies)
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

    -- Límites de pantalla
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
        
        -- Reproducir sonido de salto
        if self.jumpSound then
            self.jumpSound:stop()
            self.jumpSound:play()
        end

        EventDispatcher.publish("PLAYER_JUMPED")
    end

    -- Gravedad
    self.vy = self.vy + self.gravity * dt
    self.y = self.y + self.vy * dt

    self.isGrounded = false

    -- Colisiones con plataformas
    if platforms then
        for _, p in ipairs(platforms) do
            local feetY = self.y + self.height / 2
            local prevFeetY = feetY - (self.vy * dt)

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

    -- Suelo del nivel
    local floorY = 480
    if (self.y + self.height / 2) >= floorY then
        self.y = floorY - self.height / 2
        self.vy = 0
        self.isGrounded = true
    end

    -- Colisiones con enemigos
    if enemies then
        for _, enemy in ipairs(enemies) do
            if enemy.alive then
                local dx = math.abs(self.x - enemy.x)
                local dy = math.abs(self.y - enemy.y)
                if dx < (self.width / 2 + enemy.width / 2) and dy < (self.height / 2 + enemy.height / 2) then
                    if not self.invulnerableTimer or self.invulnerableTimer <= 0 then
                        self.hp = math.max(0, self.hp - 10)
                        self.invulnerableTimer = 1.0

                        -- Reproducir sonido de daño
                        if self.hurtSound then
                            self.hurtSound:stop()
                            self.hurtSound:play()
                        end

                        EventDispatcher.publish("PLAYER_DAMAGED", self.hp)
                    end
                end

                -- Colisión de proyectiles con enemigos
                for i = #self.bullets, 1, -1 do
                    local b = self.bullets[i]
                    if math.abs(b.x - enemy.x) < enemy.width / 2 and math.abs(b.y - enemy.y) < enemy.height / 2 then
                        enemy.hp = enemy.hp - 20
                        table.remove(self.bullets, i)
                        if enemy.hp <= 0 then
                            enemy.alive = false
                        end
                        break
                    end
                end
            end
        end
    end

    if self.invulnerableTimer and self.invulnerableTimer > 0 then
        self.invulnerableTimer = self.invulnerableTimer - dt
    end

    -- Temporizador de ataque visual
    if self.isAttacking then
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then
            self.isAttacking = false
        end
    end

    -- Actualizar proyectiles activos
    for i = #self.bullets, 1, -1 do
        local b = self.bullets[i]
        b.x = b.x + b.vx * dt
        if b.x < 0 or b.x > screenWidth then
            table.remove(self.bullets, i)
        end
    end

    -- Actualizar animaciones de forma segura según el estado actual
    if self.isAttacking then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 0.1 then
            self.animTimer = 0
            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > #self.attackFrames then
                self.currentFrame = 1
            end
        end
    elseif not self.isGrounded then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 0.08 then
            self.animTimer = 0
            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > #self.jumpFrames then
                self.currentFrame = #self.jumpFrames
            end
        end
    elseif self.vx ~= 0 then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 0.1 then
            self.animTimer = 0
            self.currentFrame = self.currentFrame + 1
            if self.currentFrame > #self.walkFrames then
                self.currentFrame = 1
            end
        end
    else
        self.currentFrame = 1
    end
end

function Player:draw()
    local scale = 0.16

    -- Dibujar proyectiles
    for _, b in ipairs(self.bullets) do
        local bScale = 0.08
        local bw, bh = self.bulletImg:getWidth(), self.bulletImg:getHeight()
        love.graphics.draw(self.bulletImg, b.x, b.y, 0, b.facing * bScale, bScale, bw / 2, bh / 2)
    end

    -- Dibujar jugador de forma segura evitando índices nulos
    if self.isAttacking and self.attackFrames[self.currentFrame] then
        local q = self.attackFrames[self.currentFrame]
        local _, _, w, h = q:getViewport()
        love.graphics.draw(self.attackSheet, q, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    elseif not self.isGrounded and self.jumpFrames[self.currentFrame] then
        local q = self.jumpFrames[self.currentFrame]
        local _, _, w, h = q:getViewport()
        love.graphics.draw(self.jumpSheet, q, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    elseif self.vx ~= 0 and self.walkFrames[self.currentFrame] then
        local q = self.walkFrames[self.currentFrame]
        local _, _, w, h = q:getViewport()
        love.graphics.draw(self.walkSheet, q, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    else
        local w, h = self.idleImg:getWidth(), self.idleImg:getHeight()
        love.graphics.draw(self.idleImg, self.x, self.y, 0, self.facing * scale, scale, w / 2, h / 2)
    end
end

return Player