local Class = require 'lib.class'
local Player = require 'Player'
local Enemy = require 'Enemy'

-- Definición de la clase PlatformObj
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

    -- Instanciar plataformas
    self.platforms = {
        PlatformObj(80, 410, 0.30),
        PlatformObj(350, 330, 0.30),
        PlatformObj(150, 230, 0.30)
    }

    self.enemiesDefeated = 0
    self.totalEnemiesTarget = 10
    self.enemies = {}

    -- Carga segura de sonidos de victoria y derrota
    self.winSound = (pcall(love.audio.newSource, 'assets/victoria.wav', 'static')) and love.audio.newSource('assets/victoria.wav', 'static') or nil
    self.loseSound = (pcall(love.audio.newSource, 'assets/derrota.wav', 'static')) and love.audio.newSource('assets/derrota.wav', 'static') or nil
    self.soundPlayed = false

    -- Alturas específicas predefinidas para las 3 franjas (alta, media, baja)
    self.spawnHeights = { 200, 290, 390 }

    -- Generar los primeros 3 enemigos iniciales (uno en cada altura)
    for i = 1, 3 do
        self:spawnNextEnemy()
    end

    -- Instanciar al jugador
    self.player = Player(180, 360)
end

function Level:spawnNextEnemy()
    -- Solo genera si aún no alcanzamos el total objetivo de 10
    if self.enemiesDefeated + #self.enemies < self.totalEnemiesTarget then
        local heightIndex = ((self.enemiesDefeated + #self.enemies) % #self.spawnHeights) + 1
        local yPos = self.spawnHeights[heightIndex]
        
        -- Dirección aleatoria (1 izquierda a derecha, -1 derecha a izquierda)
        local dir = (math.random(0, 1) == 0) and 1 or -1
        
        -- Posición X inicial fuera de la pantalla según la dirección
        local screenWidth = love.graphics.getWidth()
        local xPos = (dir == 1) and -50 or (screenWidth + 50)

        table.insert(self.enemies, Enemy(xPos, yPos, dir))
    end
end

function Level:update(dt)
    -- Condición de derrota: HP en 0 O (munición en 0 sin haber ganado aún)
    local outOfAmmo = (self.player.ammo <= 0 and self.enemiesDefeated < self.totalEnemiesTarget)
    local isGameOver = (self.player.hp <= 0 or outOfAmmo)
    local isVictory = (self.enemiesDefeated >= self.totalEnemiesTarget)

    -- Si ya ganó o perdió, pausamos la acción del juego y reproducimos sonido único
    if isGameOver or isVictory then
        if not self.soundPlayed then
            self.soundPlayed = true
            if isGameOver and self.loseSound then
                self.loseSound:play()
            elseif isVictory and self.winSound then
                self.winSound:play()
            end
        end
        return
    end

    self.player:update(dt, self.platforms, self.enemies)
    
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        enemy:update(dt)
        
        if not enemy.alive then
            table.remove(self.enemies, i)
            self.enemiesDefeated = self.enemiesDefeated + 1
            self:spawnNextEnemy()
        end
    end
end

function Level:draw()
    -- Dibujar fondo
    love.graphics.draw(self.fondo, 0, 0, 0, self.scaleX, self.scaleY)

    -- Dibujar plataformas
    for _, platform in ipairs(self.platforms) do
        platform:draw()
    end

    -- Dibujar enemigos activos
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    -- Dibujar jugador
    self.player:draw()

    -- HUD dinámico
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 20, 20, 310, 40, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("HP: " .. self.player.hp .. " | Muni: " .. self.player.ammo .. " | Derrotados: " .. self.enemiesDefeated .. "/" .. self.totalEnemiesTarget, 30, 32)

    -- Pantalla de Victoria al llegar a los 10
    if self.enemiesDefeated >= self.totalEnemiesTarget then
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 150, 180, 500, 120, 10, 10)
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.print("¡VICTORIA! Laboratorio Defendido", 210, 210, 0, 1.2, 1.2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Presiona ESC para volver al menú", 250, 255)
    end

    -- Pantalla de Derrota (Game Over) si HP llega a 0 o se acaba la munición
    local outOfAmmoDraw = (self.player.ammo <= 0 and self.enemiesDefeated < self.totalEnemiesTarget)
    if self.player.hp <= 0 or outOfAmmoDraw then
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 150, 180, 500, 120, 10, 10)
        love.graphics.setColor(1, 0, 0, 1)
        
        local mensajeDerrota = (self.player.hp <= 0) and "¡DERROTA! El laboratorio ha caído" or "¡DERROTA! Sin munición para defender"
        love.graphics.print(mensajeDerrota, 175, 210, 0, 1.1, 1.1)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Presiona ESC para volver al menú", 250, 255)
    end

    -- Volver al menú
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 540, 20, 220, 35, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("ESC para volver al menú", 550, 28)
end

function Level:mousepressed(x, y, button)
    if button == 1 and self.enemiesDefeated < self.totalEnemiesTarget and self.player.hp > 0 and self.player.ammo > 0 then
        self.player:shoot()
    end
end

function Level:keypressed(key)
    if key == 'escape' then
        cambiarEstado("menu")
    end
end

return Level