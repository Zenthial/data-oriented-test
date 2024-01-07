--!strict

local Players = game:GetService("Players")

local player = Players.LocalPlayer

export type character = Model & { Humanoid: Humanoid & { Animator: Animator }}

local char = {}

function char.origin(): Vector3?
    local character = player.Character

    if character and character:FindFirstChild("Head") then
        return character.Head.Position :: Vector3
    else
        return nil
    end
end

function char.character(): character
    if player.Character == nil then
        player.CharacterAdded:Wait()
    end

    return player.Character
end

function char.hum(): Humanoid
    local c = char.character()
    if c:FindFirstChild("Humanoid") == nil then
        repeat task.wait() until c:FindFirstChild("Humanoid") ~= nil
    end
    return char.character().Humanoid
end

-- when we have damage this will flesh out
function char.alive(): boolean
    return true
end

return char
