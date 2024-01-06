local Players = game:GetService("Players")

local Weapon = require(script.Parent.weapon)
local Char = require(script.Parent.char)
local Battery = require(script.Parent.battery)
local Ignored = require(script.Parent.ignored)

local mouse = Players:GetMouse()

local gun_engine = {}

function gun_engine.raycast(weapon: Weapon.t, origin: Vector3, target: Vector3, range: number?): (Part?, Vector3)
    -- bit of mutability but oh well
    if range == nil then range = 1000 end -- default range to 1000 if none is provided
    local random = Random.new()

    local spread = (random:NextNumber(weapon.min_spread, weapon.max_spread) / 500) or 0
    local distance = (origin - target).Magnitude
    local spread_variance = spread * distance
    local aim = target

    -- we check if we should apply spread. certain guns are dead accurate from close range, similar to old SMO STAs
    if distance > weapon.no_spread_distance then
        aim = Vector3.new(
            target.X + random:NextNumber(-spread_variance, spread_variance),
            target.Y + random:NextNumber(-spread_variance, spread_variance),
            target.Z + random:NextNumber(-spread_variance, spread_variance)
        )
    end

    local end_pos = (aim - origin).Unit * range
    local result = workspace:Raycast(origin, end_pos, Ignored.raycast_params())
    if result and result.Position then
        return result.Instance, result.Position
    else
        return nil, end_pos
    end
end

function gun_engine.can_shoot(weapon: Weapon.t): boolean
    return Battery.depleted(weapon.battery) and Char.alive()
end

function gun_engine.check_for_damage(weapon: Weapon.t, part: Part)

end

function gun_engine.draw_ray(weapon: Weapon.t, end_pos: Vector3)
    local start_pos = Weapon.muzzle(weapon)
    local i_dist = (end_pos - start_pos).Magnitude

    local bullet1 = Weapon.bullet(weapon)
    bullet1.Mesh.Scale = Vector3.new(bullet1.Mesh.Scale.X, bullet1.Mesh.Scale.Y, i_dist)
    bullet1.CFrame = CFrame.new(start_pos, end_pos) * CFrame.new(0, 0, -i_dist / 2)
    
    local bullet2 = Weapon.bullet(weapon)
    bullet2.Mesh.Scale = Vector3.new(bullet1.Mesh.Scale.X, bullet1.Mesh.Scale.Y, i_dist)
    bullet2.CFrame = CFrame.new(start_pos, end_pos) * CFrame.new(0, 0, -i_dist / 2)

    task.delay(0.05, bullet1.Destroy, bullet1)
    task.delay(0.1, bullet2.Destroy, bullet2)
end

function gun_engine.shoot(weapon: Weapon.t)
    local origin = Char.origin()
    local target = mouse.Position
    if origin == nil then return end -- character does not exist, dont shoot
    local part, position = gun_engine.raycast(weapon, origin, target)
    gun_engine.draw_ray(weapon, position)
    gun_engine.check_for_damage(weapon, part)
end

function gun_engine.fire(weapon: Weapon.t)

end

return gun_engine