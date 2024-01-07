-- main client driver
-- all event driven state is handled here

local UserInputService = game:GetService("UserInputService")

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
end

main()
