--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local player = Players.LocalPlayer

local types = require(shared.types)

type character = types.character

local M = {}

function M.origin(): Vector3?
    local character = player.Character

    if character and character:FindFirstChild("Head") then
        return character.Head.Position :: Vector3
    else
        return nil
    end
end

function M.character(): character
    if player.Character == nil then
        player.CharacterAdded:Wait()
    end

    return player.Character
end

function M.hum(): Humanoid
    local c = M.character()
    if c:FindFirstChild("Humanoid") == nil then
        repeat task.wait() until c:FindFirstChild("Humanoid") ~= nil
    end
    return M.character().Humanoid
end

-- when we have damage this will flesh out
function M.alive(): boolean
    return true
end

return M
