--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local weapons = ReplicatedStorage:WaitForChild("Weapons")
local shared = ReplicatedStorage:WaitForChild("Shared")

local Util = require(shared.util)
local Weapon_configs = require(shared.weapon_configs)
local Battery = require(script.Parent.battery)
local Animation = require(script.Parent.animation)

export type t = Weapon_configs.t & {
    shooting: boolean,
    battery: Battery.t,
    model: Model & { Muzzle: Part }
}

local M = {}

function M.make(weapon_name: string, model: Model): t 
    local config = Util.find(Weapon_configs, function(config: Weapon_configs.t) return config.name == weapon_name end)
    if config == nil then
        error("No config for " .. weapon_name)
    end

    local w = table.clone(config)
    local state = {
        shooting = false,
        battery = Battery.make(w.depletion_rate, w.recharge_time, w.recharge_delay),
        model = model
    }

    return Util.merge(w, state) :: t
end

function M.load_anis(w: t, ani: Animation.t)
    local animation_folder = weapons[w.name].Anims 

    Animation.load(ani, animation_folder:GetChildren(), w.name)
end

function M.muzzle(weapon: t): Vector3
    return weapon.model.Muzzle.Position
end

function M.bullet(weapon: t): Part & { Mesh: SpecialMesh }
    local weapon_folder = weapons:FindFirstChild(weapon.name)
    if weapon_folder == nil then error("No weapon folder for " .. weapon.name) end


    local bullet = weapon_folder.Bullet:Clone() :: Part & { Mesh: SpecialMesh }
    CollectionService:AddTag(bullet, "ignore")
    return bullet
end

function M.set_shooting(weapon: t, shooting: boolean): t
    weapon.shooting = true

    return weapon
end

return M
