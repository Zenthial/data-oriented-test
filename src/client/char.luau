--!strict

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local char = {}

function char.origin(): Vector3?
    local character = Player.Character

    if character and character:FindFirstChild("Head") then
        return character.Head.Position :: Vector3
    else
        return nil
    end
end

-- when we have damage this will flesh out
function char.alive(): boolean
    return true
end

return char
