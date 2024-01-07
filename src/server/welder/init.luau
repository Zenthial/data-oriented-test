--!nolint LocalShadow

local Holsters = require(script.holsters)
local Handles = require(script.handles)

type limb_type = "Torso" | "Left Arm" | "Right Arm"

type t = {
    limb: limb_type,
    C0: CFrame,
    C1: CFrame
}

local function inverse_weld(part0: BasePart, part1: BasePart, c0: CFrame?, c1: CFrame?)
    assert(part0, "Part0 does not exist")
    assert(part1, "Part1 does not exist")
    local weld = part0:FindFirstChild("HandleWeld") :: ManualWeld
    if not weld then
        weld = Instance.new("ManualWeld")
        weld.Name = "HandleWeld"
    end

    weld.Part0 = part1
    weld.Part1 = part0

    if c0 then
        weld.C0 = c0
    end
    if c1 then
        weld.C1 = c1
    end
    
    weld.Parent = part0
end

local M = {}

function M.weld(char: Model, weapon: Model, weapon_name: string, unequipped: boolean)
    local welds = Handles[weapon_name]

    if unequipped then welds = Holsters.Back end

    for i, weld in welds do
	local handle = weapon:FindFirstChild("Handle"..tostring((i > 1) and i or ""))
	local limbName = weld.limb
	local limb = char:FindFirstChild(limbName)
	inverse_weld(handle, limb, weld.C0, weld.C1)
    end
end

return M
