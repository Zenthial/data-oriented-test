-- main client driver
-- all event driven state is handled here

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")

local Keymaps = require(shared.keymaps)

local Listener = require(script.listener)
local Movement = require(script.movement)
local Animation = require(script.animation)
local Inventory = require(script.inventory)
local Weapon = require(script.weapon)
local Gun_engine = require(script.gun_engine)
local Char = require(script.char)

-- main entrypoint of the client side program
local function main()
    -- state initialization
    -- local character = Char.character()
    local hum = Char.hum()
    local mov: Movement.t = Movement.make(hum)
    local ani: Animation.t = Animation.make(hum)
    local inv: Inventory.t<Weapon.t> = Inventory.make()

    UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed then return end

        Movement.began(inv, mov, ani, input)
        Gun_engine.began(inv, mov, ani, input)
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, processed: boolean)
        if processed then return end

        Movement.ended(inv, mov, ani, input)
    end)

    -- listen for the server to tell us we've received an item
    -- we need to setup the item locally, initializing its stats, finding its keymap, and putting it in our inventory
    -- the item is always parented to the character, so it's model is discoverable that way
    Listener.listen("item", function(item_name: string)
        local model = Char.character():WaitForChild(item_name)
        if model == nil then error(item_name .. " does not exist on character") end

        local w = Weapon.make(item_name, model)
        local slot = Keymaps[w.slot:lower()].Value
        Inventory.add(inv, w, slot)

        Weapon.load_anis(w, ani)
    end)
end

main()
