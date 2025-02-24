local anglefish = love.graphics.newImage("anglefish.png")
local clownfish = love.graphics.newImage("clownfish.png")
local neon_tetra = love.graphics.newImage("neon_tetra.png")

local fish = {}

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function love.load()
    love.window.setMode(900, 700)
    love.window.setTitle("fisk")
end

function love.update(dt)
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
