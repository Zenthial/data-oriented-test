--!nolint LocalShadow
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local shared = ReplicatedStorage:WaitForChild("Shared")
local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local core = player_gui:WaitForChild("Core")
local assets = ReplicatedStorage:WaitForChild("Ui")
local camera = workspace.CurrentCamera
-- local cursor = core:WaitForChild("Cursor") :: Frame

local Weapon_configs = require(shared.weapon_configs)

local deg = math.pi / 180
local function draw_line(frame: Frame, x0: number, y0: number, x1: number, y1: number, visible: boolean)
    local dx = x1 - x0
    local dy = y1 - y0
    local length = (dx * dx + dy * dy)^0.5
    local angle = math.atan2(dy, dx)

    frame.Position = UDim2.new(0, (x0 + x1)/2, 0, (y0 + y1)/2)
    frame.Size = UDim2.new(0, length + 1, 0, 2)
    frame.Rotation = angle / deg
    frame.Visible = visible
end

local function get_tip_pos(equipped: boolean, slot: Weapon_configs.slot, tip_pos: Vector2, bar: Frame)
    if slot == "Primary" and equipped == true then
	return UDim2.new(0, tip_pos.X + 100, 0, tip_pos.Y - 75), Vector2.new(bar.AbsolutePosition.X, bar.AbsolutePosition.Y + bar.AbsoluteSize.Y)
    elseif slot == "Primary" and equipped == false then
	return UDim2.new(0, tip_pos.X - 200, 0, tip_pos.Y + 50), Vector2.new(bar.AbsolutePosition.X + bar.AbsoluteSize.X, bar.AbsolutePosition.Y + bar.AbsoluteSize.Y)
    else error("Not supported yet")
    end
end

type tip = Frame & { TipName: TextLabel, TipInfo: TextLabel, Bar: Frame }

local function position_tip(equipped: boolean, slot: Weapon_configs.slot, tip: tip)
    if slot == "Primary" and equipped == true then
	tip.Bar.AnchorPoint = Vector2.new(0, 0.5)
	tip.Bar.Position = UDim2.fromScale(0, 0.5)
	tip.TipName.AnchorPoint = Vector2.new(0, 1)
	tip.TipName.Position = UDim2.fromScale(0.05, 0.45)
	tip.TipName.TextXAlignment = Enum.TextXAlignment.Left
	tip.TipInfo.AnchorPoint = Vector2.new(0, 0)
	tip.TipInfo.Position = UDim2.fromScale(0.05, 0.6)
	tip.TipInfo.TextXAlignment = Enum.TextXAlignment.Left
    elseif slot == "Primary" and equipped == false then
	tip.Bar.AnchorPoint = Vector2.new(1, 0.5)
	tip.Bar.Position = UDim2.fromScale(1, 0.5)
	tip.TipName.AnchorPoint = Vector2.new(1, 1)
	tip.TipName.Position = UDim2.fromScale(0.95, 0.45)
	tip.TipName.TextXAlignment = Enum.TextXAlignment.Right
	tip.TipInfo.AnchorPoint = Vector2.new(1, 0)
	tip.TipInfo.Position = UDim2.fromScale(0.95, 0.6)
	tip.TipInfo.TextXAlignment = Enum.TextXAlignment.Right
    else error("Not supported yet")
    end
end

type tooltip = {
    tip: tip,
    line: Frame
}

local M = {}

function M.draw_tooltip(world_pos: Vector3, tip_pos: Vector3?, top_text: string, info_text: string, tooltip: tooltip, equipped: boolean, slot: Weapon_configs.slot): tooltip
    if tip_pos == nil then
	tooltip.tip.Position = UDim2.new(-2, 0, -2, 0)
	tooltip.line.Position = UDim2.new(-2, 0, -2, 0)
    end
    local screen_pos = camera:WorldToScreenPoint(world_pos)
    local tip_pos = camera:WorldToScreenPoint(tip_pos)
    local tip_pos, corner = get_tip_pos(equipped, slot, tip_pos, tooltip.tip.Bar)

    tooltip.tip.Position = tip_pos
    tooltip.tip.TipName.Text = top_text:lower()
    tooltip.tip.TipInfo.Text = info_text:lower()

    position_tip(equipped, slot, tooltip.tip)

    draw_line(tooltip.line, screen_pos.X, screen_pos.Y, corner.X, corner.Y, true)

    return tooltip
end

function M.make_tooltip(): tooltip
    local tip = assets.Tooltip:Clone() :: Frame
    tip.Parent = core
    local line = assets.Line:Clone()
    line.Parent = core

    local tooltip = { tip = tip, line = line }
    return tooltip
end

function M.remove_tooltip(tooltip: tooltip)
    tooltip.tip:Destroy()
    tooltip.line:Destroy()
end

function M.set_icon()
    UserInputService.MouseIcon = "rbxassetid://5686002178"
end

-- function M.cursor(pos: Vector2)
--     cursor.Position = UDim2.fromOffset(pos.X, pos.Y)
-- end
--
-- function M.open_cursor()
--     for _, thing in cursor:GetChildren() do
-- 	if thing:IsA("Frame") == false then continue end
-- 	TweenService:Create(thing, TweenInfo.new(0.1), { Position = thing:GetAttribute("open_pos") }):Play()
--     end
--
--     task.wait(0.075)
--
--     for _, thing in cursor:GetChildren() do
-- 	if thing:IsA("Frame") == false then continue end
-- 	TweenService:Create(thing, TweenInfo.new(0.1), { Size = thing:GetAttribute("open_size") }):Play()
--     end
-- end
--
-- function M.close_cursor()
--     for _, thing in cursor:GetChildren() do
-- 	if thing:IsA("Frame") == false then continue end
-- 	TweenService:Create(thing, TweenInfo.new(0.1), { Size = thing:GetAttribute("close_size") }):Play()
--     end
--
--     task.wait(0.075)
--
--     for _, thing in cursor:GetChildren() do
-- 	if thing:IsA("Frame") == false then continue end
-- 	TweenService:Create(thing, TweenInfo.new(0.1), { Position = thing:GetAttribute("close_pos") }):Play()
--     end
-- end

function M.set_overheated(weapon_model: Model)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.Adornee = weapon_model
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = weapon_model
end

return M
