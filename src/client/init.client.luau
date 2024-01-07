-- main client driver
-- all event driven state is handled here

local UserInputService = game:GetService("UserInputService")

local Listener = require(script.listener)
local Movement = require(script.movement)
local Animation = require(script.animation)
local Char = require(script.char)

-- main entrypoint of the client side program
local function main()
    -- state initialization
    -- local character = Char.character()
    local hum = Char.hum()
    local mov: Movement.t = Movement.make(hum)
    local ani: Animation.t = Animation.make(hum)

    UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if processed then return end

        Movement.began(mov, ani, input)
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, processed: boolean)
        if processed then return end

        Movement.ended(mov, ani, input)
    end)

    -- listen for the server to tell us we've received an item
    -- we need to setup the item locally, initializing its stats, finding its keymap, and putting it in our inventory
    -- the item is always parented to the character, so it's model is discoverable that way
    Listener.listen("item", function(item_name: string)
        print(item_name)
    end)
end

main()
