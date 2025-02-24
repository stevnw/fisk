local anglefish = love.graphics.newImage("anglefish.png")
local clownfish = love.graphics.newImage("clownfish.png")
local neon_tetra = love.graphics.newImage("neon_tetra.png")
local bubbleImg = love.graphics.newImage("bubble.png")

local fish = {}
local bubbles = {}

function love.load()
    love.window.setMode(900, 700)
    love.window.setTitle("fisk")

    for i = 1, 10 do
        spawnBubble()
    end
end

function spawnBubble()
    table.insert(bubbles, {
        x = love.math.random(0, 900),
        y = love.math.random(750, 1000),
        speed = love.math.random(30, 80),
        scale = love.math.random(30, 50) / 100,
        flipped = love.math.random(0, 1) == 1,
        wobble = love.math.random() < 0.5,
        wobbleTimer = love.math.random(0, 2 * math.pi),
        wobbleSpeed = love.math.random(2, 4),
        wobbleAmount = love.math.random(5, 15)
    })
end

function love.update(dt)
    for i = #bubbles, 1, -1 do
        local b = bubbles[i]
        b.y = b.y - b.speed * dt

        if b.wobble then
            b.wobbleTimer = b.wobbleTimer + dt * b.wobbleSpeed
            b.x = b.x + math.sin(b.wobbleTimer) * b.wobbleAmount * dt
        end

        if b.y < -bubbleImg:getHeight() * b.scale then
            table.remove(bubbles, i)
            spawnBubble()
        end
    end

    for i, f in ipairs(fish) do
        if f.state == "moving" then
            local dx = f.targetX - f.x
            local dy = f.targetY - f.y
            local distance = math.sqrt(dx * dx + dy * dy)
            local closeEnough = 5
            if distance > closeEnough then
                local directionX = dx / distance
                local directionY = dy / distance
                local speed = 100
                f.x = f.x + directionX * speed * dt
                f.y = f.y + directionY * speed * dt
                if math.abs(dx) > 15 then
                    if dx > 0 and not f.flipped then
                        f.flipped = true
                    elseif dx < 0 and f.flipped then
                        f.flipped = false
                    end
                end
            else
                f.x, f.y = f.targetX, f.targetY
                f.state = "waiting"
                f.timer = love.math.random(0.5, 2)
            end
        elseif f.state == "waiting" then
            f.timer = f.timer - dt
            if f.timer <= 0 then
                f.state = "moving"
                f.targetX = love.math.random(50, 850)
                f.targetY = love.math.random(50, 650)
            end
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.6, 0.8, 0.9)

    for _, b in ipairs(bubbles) do
        local scaleX = b.flipped and -b.scale or b.scale
        love.graphics.draw(bubbleImg, b.x, b.y, 0, scaleX, b.scale)
    end

    love.graphics.setColor(1, 1, 1)
    for i, f in ipairs(fish) do
        local scaleX = f.flipped and -0.2 or 0.2
        love.graphics.draw(f.img, f.x, f.y, 0, scaleX, 0.2, f.img:getWidth() / 2, f.img:getHeight() / 2)
    end
end

function love.mousepressed(x, y, b)
    if b == 1 then
        local fishImages = {anglefish, clownfish, neon_tetra}
        local fishImage = fishImages[love.math.random(1, 3)]
        local targetX = love.math.random(50, 850)
        local targetY = love.math.random(50, 650)
        table.insert(fish, {
            id = #fish + 1,
            img = fishImage,
            x = x,
            y = y,
            targetX = targetX,
            targetY = targetY,
            state = "moving",
            timer = love.math.random(0.5, 2),
            flipped = false,
        })
    end
end
