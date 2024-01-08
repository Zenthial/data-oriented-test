--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local weapons = ReplicatedStorage:WaitForChild("Weapons")
local shared = ReplicatedStorage:WaitForChild("Shared")

local Util = require(shared.util)
local Weapon_configs = require(shared.weapon_configs)
local Battery = require(script.Parent.battery)
local Animation = require(script.Parent.animation)

type weapon_model = Model & { Barrel: Part, Handle: Part, Hologram: Part }

type state = {
    aiming: boolean,
    has_equipped: boolean,
    shooting: boolean,
    recoil: number,
    battery: Battery.t,
    model: weapon_model
}

export type t = Weapon_configs.t & state
local M = {}

function M.make(weapon_name: string, model: Model): t 
    local config = Util.find(Weapon_configs, function(config: Weapon_configs.t) return config.name == weapon_name end)
    if config == nil then
        error("No config for " .. weapon_name)
    end

    local w = table.clone(config)
    local state: state = {
        aiming = false,
        has_equipped = false,
        shooting = false,
        recoil = 0,
        battery = Battery.make(w.depletion_rate, w.recharge_time, w.recharge_delay),
        model = model :: weapon_model
    }

    return Util.merge(w, state) :: t
end

function M.load_anis(w: t, ani: Animation.t)
    local animation_folder = weapons[w.name].Anims 

    Animation.load(ani, animation_folder:GetChildren(), w.name)
end

function M.barrel(weapon: t): Vector3
    return weapon.model.Barrel.Position
end

function M.hologram(weapon: t): Vector3
    return weapon.model.Hologram.Position
end

function M.handle(weapon: t): Vector3
    return weapon.model.Handle.Position
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
