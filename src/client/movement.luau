local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local shared = ReplicatedStorage:WaitForChild("Shared")

local Animation = require(script.Parent.animation)
local Keymaps = require(shared.keymaps)

export type movement_state = "Sprint" | "Roll" | "Walk" | "Crouch"

export type t = {
    state: movement_state,
    hum: Humanoid, -- holds the humanoid for easy speed update
    playing_animations: { string }
}

local M = {}

function M.update_speed(mov: t)
    local speed = 16 -- default walkspeed

    if mov.state == "Crouch" then speed -= 8
    elseif mov.state == "Sprint" or mov.state == "Roll" then speed += 10
    end

    mov.hum.WalkSpeed = speed
end

function M.update_animations(mov: t, ani: Animation.t)
    Animation.stop_all(ani, mov.playing_animations)
    table.clear(mov.playing_animations)
    if mov.state == "Crouch" then
        table.insert(mov.playing_animations, "globalcrouchMiddle")
        table.insert(mov.playing_animations, "globalcrouchBottom")
        Animation.play_all(ani, { "globalcrouchMiddle", "globalcrouchBottom" })
    elseif mov.state == "Roll" then
        table.insert(mov.playing_animations, "globalrollMiddle")
        local rolling = Animation.play(ani, "globalrollMiddle")
        rolling.Stopped:Wait()
        if UserInputService:IsKeyDown(Keymaps.sprint) then
            mov.state = "Sprint"
        else
            mov.state = "Crouch"
        end
    end
end

function M.update(mov, ani)
    M.update_animations(mov, ani)
    M.update_speed(mov)
end

function M.crouch(mov: t, ani: Animation.t)
    -- to whoever is reading this in the future, tom of 1/06/24 liked this format
    -- because he had been doing a lot of OCaml. he thought it was more clear and concise
    if mov.state == "Walk" then mov.state = "Crouch"
    elseif mov.state == "Crouch" then mov.state = "Walk"
    elseif mov.state == "Roll" then return
    elseif mov.state == "Sprint" then mov.state = "Roll"
    end

    M.update(mov, ani)
end

function M.sprint(mov: t, ani: Animation.t)
    if mov.state == "Walk" or mov.state == "Crouch" then mov.state = "Sprint"
    elseif mov.state == "Sprint" then mov.state = "Walk"
    elseif mov.state == "Roll" then return
    end

    M.update(mov, ani)
end

function M.make(hum: Humanoid): t
    return { state = "Walk", hum = hum, playing_animations = {} }
end

function M.began(mov: t, ani: Animation.t, input: InputObject)
    if input.KeyCode == Keymaps.crouch then
        M.crouch(mov, ani)
    elseif input.KeyCode == Keymaps.sprint then
        M.sprint(mov, ani)
    end
end

function M.ended(mov: t, ani: Animation.t, input: InputObject)
    if input.KeyCode == Keymaps.sprint then
        M.sprint(mov, ani)
    end
end

return M
