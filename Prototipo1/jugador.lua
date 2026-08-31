local Jugador = {}
Jugador.__index = Jugador

function Jugador.nuevo()
    local self = setmetatable({}, Jugador)

    -- Cargar sprites desde assets/
    self.imgIdleHurt = love.graphics.newImage("assets/Hurt.png")
    self.imgJump = love.graphics.newImage("assets/Jump.png")
    self.imgAttack = love.graphics.newImage("assets/Attack_3.png")
    self.imgDead = love.graphics.newImage("assets/Dead.png")

    -- Cargar Sonidos del Jugador
    self.sndPaso = love.audio.newSource("assets/paso.wav", "static")
    self.sndSalto = love.audio.newSource("assets/salto.wav", "static")
    self.sndAtaque = love.audio.newSource("assets/ataque.wav", "static")
    self.sndGolpe = love.audio.newSource("assets/golpe.wav", "static")

    -- Dimensiones
    self.ancho = self.imgIdleHurt:getWidth()
    self.alto = self.imgIdleHurt:getHeight()
    self.x = 100
    self.sueloY = 480 - self.alto
    self.y = self.sueloY

    -- Física y Movimiento
    self.velocidad = 250
    self.velY = 0
    self.fuerzaSalto = -500
    self.gravedad = 1200
    self.enElSuelo = true

    -- Control de Pasos
    self.pasoTimer = 0
    self.pasoIntervalo = 0.35

    -- Vidas, Ataque y Daño Visual
    self.vidas = 3
    self.atacando = false
    self.attackTimer = 0
    self.hitTimer = 0 -- Duración de la capa roja

    return self
end

function Jugador:update(dt)
    -- Temporizador del efecto de daño (capa roja)
    if self.hitTimer > 0 then
        self.hitTimer = self.hitTimer - dt
    end

    -- Temporizador de ataque
    if self.atacando then
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then
            self.atacando = false
        end
    end

    -- Movimiento horizontal y sonido de pasos
    local moviendose = false
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.x = math.max(0, self.x - self.velocidad * dt)
        moviendose = true
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.x = math.min(love.graphics.getWidth() - self.ancho, self.x + self.velocidad * dt)
        moviendose = true
    end

    -- Reproducción periódica del sonido de pasos al caminar sobre el suelo
    if moviendose and self.enElSuelo then
        self.pasoTimer = self.pasoTimer + dt
        if self.pasoTimer >= self.pasoIntervalo then
            self.pasoTimer = 0
            self.sndPaso:stop()
            self.sndPaso:play()
        end
    else
        self.pasoTimer = self.pasoIntervalo
    end

    -- Gravedad y física de salto
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
        self.sndSalto:stop()
        self.sndSalto:play()
    end
end

function Jugador:atacar()
    if not self.atacando then
        self.atacando = true
        self.attackTimer = 0.25
        self.sndAtaque:stop()
        self.sndAtaque:play()
    end
end

function Jugador:recibirDano()
    self.vidas = self.vidas - 1
    self.hitTimer = 0.3 -- Duración del destello rojo (0.3 segundos)
    self.sndGolpe:stop()
    self.sndGolpe:play()
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

    -- Aplicar tinte rojo semitransparente si el jugador fue recientemente golpeado
    if self.hitTimer > 0 then
        love.graphics.setColor(1, 0.2, 0.2, 0.8)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.draw(spriteActual, self.x, self.y)

    -- Resetear el color a blanco puro
    love.graphics.setColor(1, 1, 1, 1)
end

return Jugador