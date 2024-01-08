local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local weapons = ReplicatedStorage:WaitForChild("Weapons")

local Welder = require(script.Parent.welder)
local Listener = require(script.Parent.listener)
local types = require(shared.types)

type character = types.character

local function get_items_for_player(player: Player): { string }
    return { "W17" }
end

local function wait_for_char(player: Player): character
    if player.Character == nil then
        player.CharacterAppearanceLoaded:Wait()

        -- if player.Character then
        --     repeat task.wait() until player.Character:FindFirstChild("Torso")
        -- else
        --     error("loaded without char?")
        -- end
    end

    return player.Character :: character
end

export type t = {
    instance: Player,
    items: { string }
}

local M = {}

function M.give_items(p: t)
    local char = wait_for_char(p.instance)

    for _, item in p.items do
        local model = weapons:FindFirstChild(item)
        if model == nil then error(item .. " does not exist") end

        local item_model = model.Model:Clone()
        item_model.Name = item
        item_model.Parent = char

        Welder.weld(char, item_model, item, true)

        -- the client listens on "item" as an instruction that tells them when they receive an item (weapon)
        Listener.send_to("item", p.instance, item)
    end
end

function M.make(player: Player): t
    return { instance = player, items = get_items_for_player(player) }
end

return M
