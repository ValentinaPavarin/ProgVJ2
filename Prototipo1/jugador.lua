local Jugador = {}
Jugador.__index = Jugador

function Jugador.nuevo()
    local self = setmetatable({}, Jugador)

    -- Rutas actualizadas apuntando a la subcarpeta assets/
    self.imgIdleHurt = love.graphics.newImage("assets/Hurt.png")
    self.imgJump = love.graphics.newImage("assets/Jump.png")
    self.imgAttack = love.graphics.newImage("assets/Attack_3.png")
    self.imgDead = love.graphics.newImage("assets/Dead.png")

    -- Dimensiones e inicio
    self.ancho = self.imgIdleHurt:getWidth()
    self.alto = self.imgIdleHurt:getHeight()
    self.x = 100
    self.sueloY = 480 - self.alto -- Alineado con la superficie del suelo
    self.y = self.sueloY

    -- Física y Movimiento
    self.velocidad = 250
    self.velY = 0
    self.fuerzaSalto = -500
    self.gravedad = 1200
    self.enElSuelo = true

    -- Estados de combate
    self.vidas = 3
    self.atacando = false
    self.attackTimer = 0

    return self
end

function Jugador:update(dt)
    -- Temporizador de ataque
    if self.atacando then
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then
            self.atacando = false
        end
    end

    -- Movimiento horizontal (A / D o Flechas)
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.x = math.max(0, self.x - self.velocidad * dt)
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.x = math.min(love.graphics.getWidth() - self.ancho, self.x + self.velocidad * dt)
    end

    -- Física de salto y gravedad
    if not self.enElSuelo then
        self.velY = self.velY + self.gravedad * dt
        self.y = self.y + self.velY * dt

        if self.y >= self.sueloY then
            self.y = self.sueloY
            self.velY = 0
            self.enElSuelo = true
        end
    end
end

function Jugador:saltar()
    if self.enElSuelo then
        self.velY = self.fuerzaSalto
        self.enElSuelo = false
    end
end

function Jugador:atacar()
    self.atacando = true
    self.attackTimer = 0.25
end

function Jugador:recibirDano()
    self.vidas = self.vidas - 1
end

function Jugador:draw(estadoJuego)
    local spriteActual = self.imgIdleHurt

    if estadoJuego == "DERROTA" then
        spriteActual = self.imgDead
    elseif self.atacando then
        spriteActual = self.imgAttack
    elseif not self.enElSuelo then
        spriteActual = self.imgJump
    end

    love.graphics.draw(spriteActual, self.x, self.y)
end

return Jugador