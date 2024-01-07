local Players = game:GetService("Players")

local Player = require(script.player)
local Listener = require(script.listener)
local Welder = require(script.welder)

local function main()
    Players.PlayerAdded:Connect(function(player)
        local p = Player.make(player)

        player.CharacterAdded:Connect(function(char)
            Player.give_items(p)
        end)
    end)

    Listener.listen("weld", function(player, item_name: string, unequip: boolean)
        local char = player.Character
        if char == nil then return end

        local item = char:FindFirstChild(item_name)
        if item == nil then return end
        Welder.weld(char, item, item_name, unequip)
    end)
end

main()
