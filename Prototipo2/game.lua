local Class = require("lib.hump.class")
local bump = require("lib.bump")
local Player = require("player")
local Enemy = require("enemy")
local Starfield = require("starfield")

local Game = Class{}

function Game:init()
    self.world = bump.newWorld(32)
    
    self.score = 0
    self.targetScore = 2500
    self.lives = 3

    self.isGameOver = false
    self.isVictory = false

    self.starfield = Starfield(100)
    self.bullets = {}
    self.enemies = {}

    self.spawnTimer = 0
    self.spawnInterval = 1.2

    local startX = (love.graphics.getWidth() / 2) - 16
    local startY = love.graphics.getHeight() - 50
    self.player = Player(self.world, startX, startY)
end

function Game:loseLife()
    if self.isGameOver or self.isVictory then return end

    self.lives = self.lives - 1
    if self.lives <= 0 then
        self.lives = 0
        self.isGameOver = true
    end
end

function Game:addScore(points)
    if self.isGameOver or self.isVictory then return end

    self.score = self.score + points
    if self.score >= self.targetScore then
        self.isVictory = true
    end
end

function Game:update(dt)
    self.starfield:update(dt)

    -- Reiniciar partida con R
    if (self.isGameOver or self.isVictory) and love.keyboard.isDown("r") then
        self:init()
        return
    end

    if not self.isGameOver and not self.isVictory then
        self.player:update(dt, self.bullets)

        -- Spawner de enemigos
        self.spawnTimer = self.spawnTimer + dt
        if self.spawnTimer >= self.spawnInterval then
            self.spawnTimer = 0
            self:spawnEnemy()
        end

        -- Actualizar balas (PASANDO 'self' PARA PERMITIR SUMAR PUNTAJE)
        for i = #self.bullets, 1, -1 do
            local b = self.bullets[i]
            b:update(dt, self)
            if b.isDead then
                table.remove(self.bullets, i)
            end
        end

        -- Actualizar enemigos (PASANDO 'self' PARA PERMITIR RESTAR VIDAS)
        for i = #self.enemies, 1, -1 do
            local e = self.enemies[i]
            e:update(dt, self)
            if e.isDead then
                table.remove(self.enemies, i)
            end
        end
    end
end

function Game:spawnEnemy()
    local enemyWidth = 32
    local randomX = math.random(0, love.graphics.getWidth() - enemyWidth)
    local startY = -40

    local newEnemy = Enemy(self.world, randomX, startY)
    table.insert(self.enemies, newEnemy)
end

function Game:draw()
    self.starfield:draw()

    if not self.isGameOver then
        self.player:draw()
    end
    
    for _, b in ipairs(self.bullets) do
        b:draw()
    end

    for _, e in ipairs(self.enemies) do
        e:draw()
    end

    -- 1. Mostrar Puntaje en texto
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. self.score .. " / " .. self.targetScore, 10, 10)

    -- 2. Dibujar Vidas como CÍRCULOS ROJOS en la esquina superior derecha
    local startX = love.graphics.getWidth() - 30
    local circleY = 20
    local radius = 8

    for i = 1, self.lives do
        love.graphics.setColor(1, 0.2, 0.2) -- Color Rojo
        love.graphics.circle("fill", startX - ((i - 1) * 22), circleY, radius)
    end

    -- Pantallas de Fin de Juego
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if self.isGameOver then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("¡GAME OVER!", 0, screenH / 2 - 30, screenW, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona 'R' para reiniciar", 0, screenH / 2 + 10, screenW, "center")
    elseif self.isVictory then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("¡VICTORIA!", 0, screenH / 2 - 30, screenW, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona 'R' para reiniciar", 0, screenH / 2 + 10, screenW, "center")
    end
end

return Game