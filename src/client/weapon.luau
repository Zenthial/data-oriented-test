--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local weapons = ReplicatedStorage:WaitForChild("Weapons")

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

local M = {}

function M.muzzle(weapon: t): Vector3
    return weapon.model.Muzzle.Position
end

function M.bullet(weapon: t): Part & { Mesh: SpecialMesh }
    local weapon_folder = weapons:FindFirstChild(weapon.identifier)
    if weapon_folder == nil then error("No weapon folder for " .. weapon.identifier) end


    local bullet = weapon_folder.Bullet:Clone() :: Part & { Mesh: SpecialMesh }
    CollectionService:AddTag(bullet, "ignore")
    return bullet
end

function M.set_shooting(weapon: t, shooting: boolean): t
    weapon.shooting = true

    return weapon
end

return M
