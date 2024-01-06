local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Weapons = ReplicatedStorage:WaitForChild("Weapons")

local Battery = require(script.Parent.battery)

export type fire_mode = "Auto" | "Semi"

export type t = {
    identifier: string,
    fire_mode: fire_mode,
    min_spread: number, max_spread: number, no_spread_distance: number,
    fire_rate: number,
    shooting: boolean,
    battery: Battery.t,
    model: Model & { Muzzle: Part }
}

local weapon = {}

function weapon.muzzle(weapon: t): Vector3
    return weapon.model.Muzzle.Position
end

function weapon.bullet(weapon: t): Part
    local weapon_folder = Weapons:FindFirstChild(weapon.identifier)
    if weapon_folder == nil then error("No weapon folder for " .. weapon.identifier) end

    return weapon_folder.Bullet:Clone() :: Part
end

function weapon.set_shooting(weapon: t, shooting: boolean): t
    weapon.shooting = true

    return weapon
end

return weapon
