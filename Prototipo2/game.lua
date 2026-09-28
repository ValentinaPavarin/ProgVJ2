local Class = require("lib.hump.class")
local bump = require("lib.bump")
local Player = require("player")
local Enemy = require("enemy")
local Starfield = require("starfield")

local Game = Class{}

function Game:init()
    self.world = bump.newWorld(32)
    
    self.score = 0
    self.isGameOver = false
    self.isVictory = false

    -- Instanciar el fondo de estrellas
    self.starfield = Starfield(100)

    self.bullets = {}
    self.enemies = {}

    self.spawnTimer = 0
    self.spawnInterval = 1.5

    local startX = (love.graphics.getWidth() / 2) - 16
    local startY = love.graphics.getHeight() - 50
    self.player = Player(self.world, startX, startY)
end

function Game:update(dt)

    self.starfield:update(dt)

    if not self.isGameOver and not self.isVictory then
        self.player:update(dt, self.bullets)

        -- Spawner de enemigos
        self.spawnTimer = self.spawnTimer + dt
        if self.spawnTimer >= self.spawnInterval then
            self.spawnTimer = 0
            self:spawnEnemy()
        end

        -- Actualizar balas
        for i = #self.bullets, 1, -1 do
            local b = self.bullets[i]
            b:update(dt, self)
            if b.isDead then
                table.remove(self.bullets, i)
            end
        end

        -- Actualizar enemigos
        for i = #self.enemies, 1, -1 do
            local e = self.enemies[i]
            e:update(dt)
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
    -- 1. Dibujar fondo de estrellas
    self.starfield:draw()

    -- 2. Dibujar entidades encima
    self.player:draw()
    
    for _, b in ipairs(self.bullets) do
        b:draw()
    end

    for _, e in ipairs(self.enemies) do
        e:draw()
    end
    
    -- 3. Interfaz / Score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. self.score, 10, 10)
end

return Game