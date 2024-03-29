local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local shared = ReplicatedStorage:WaitForChild("Shared")

local Animation = require(script.Parent.animation)
local Inventory = require(script.Parent.inventory)
local Weapon = require(script.Parent.weapon)
local Keymaps = require(shared.keymaps)

export type movement_state = "Sprint" | "Roll" | "Walk" | "Crouch"

export type t = {
    state: movement_state,
    hum: Humanoid, -- holds the humanoid for easy speed update
    playing_animations: { string }
}

local M = {}

function M.update_speed(mov: t, w: Weapon.t?)
    local speed = 16 -- default walkspeed

    if mov.state == "Crouch" then speed -= 8
    elseif mov.state == "Sprint" or mov.state == "Roll" then speed += 10
    end

    mov.hum.WalkSpeed = speed
end

-- w is the potential equipped weapon
-- this function attempts to update animations based off the state passed in, without knowledge of any previous state
-- this might be impossible
function M.update_animations(mov: t, ani: Animation.t, w: Weapon.t?)
    Animation.stop_all(ani, mov.playing_animations)
    table.clear(mov.playing_animations)

    local function play_all(anims: { string })
        Animation.play_all(ani, anims)
        for _, t in anims do
            table.insert(mov.playing_animations, t)
        end
    end

    if mov.state == "Crouch" then
        play_all({ "globalcrouchMiddle", "globalcrouchBottom" })
        if w ~= nil then
            play_all({ w.name .. "equipMiddle", w.name .. "equipTop" })
        end
    elseif mov.state == "Roll" then
        table.insert(mov.playing_animations, "globalrollMiddle")
        local rolling = Animation.play(ani, "globalrollMiddle")
        rolling.Stopped:Wait()
        if UserInputService:IsKeyDown(Keymaps.sprint) then
            mov.state = "Sprint"
        else
            mov.state = "Crouch"
            if w ~= nil then
                play_all({ w.name .. "equipMiddle", w.name .. "equipTop" })
            end
        end
        M.update(mov, ani, w)
    elseif mov.state == "Walk" then
        if w == nil then return end
        -- player has an equipped weapon
        play_all({ w.name .. "equipMiddle", w.name .. "equipTop" })
    elseif mov.state == "Sprint" then
        if w == nil then return end
        play_all({ w.name .. "sprintingMiddle", w.name .. "sprintingTop" })
    end
end

function M.update(mov: t, ani: Animation.t, w: Weapon.t?)
    M.update_animations(mov, ani, w)
    M.update_speed(mov, w)
end

function M.crouch(mov: t, ani: Animation.t, w: Weapon.t?)
    -- to whoever is reading this in the future, tom of 1/06/24 liked this format
    -- because he had been doing a lot of OCaml. he thought it was more clear and concise
    if mov.state == "Walk" then mov.state = "Crouch"
    elseif mov.state == "Crouch" then mov.state = "Walk"
    elseif mov.state == "Roll" then return
    elseif mov.state == "Sprint" then mov.state = "Roll"
    end

    M.update(mov, ani, w)
end

function M.sprint(mov: t, ani: Animation.t, w: Weapon.t?)
    if mov.state == "Walk" or mov.state == "Crouch" then mov.state = "Sprint"
    elseif mov.state == "Sprint" then mov.state = "Walk"
    elseif mov.state == "Roll" then return
    end

    M.update(mov, ani, w)
end

function M.make(hum: Humanoid): t
    return { state = "Walk", hum = hum, playing_animations = {} }
end

function M.began(inv: Inventory.t<Weapon.t>, mov: t, ani: Animation.t, input: InputObject)
    if input.KeyCode == Keymaps.crouch then
        M.crouch(mov, ani, inv.equipped_item)
    elseif input.KeyCode == Keymaps.sprint then
        M.sprint(mov, ani, inv.equipped_item)
    end
end

function M.ended(inv: Inventory.t<Weapon.t>, mov: t, ani: Animation.t, input: InputObject)
    if input.KeyCode == Keymaps.sprint then
        M.sprint(mov, ani, inv.equipped_item)
    end
end

return M
