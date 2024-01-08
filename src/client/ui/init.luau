--!nolint LocalShadow
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local core = player_gui:WaitForChild("Core")
local assets = ReplicatedStorage:WaitForChild("Ui")
local camera = workspace.CurrentCamera
local cursor = core:WaitForChild("Cursor") :: Frame

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

local function get_bottom_left(frame: Frame): Vector2
    local frame_pos = frame.AbsolutePosition
    local frame_size = frame.AbsoluteSize

    local x = frame_pos.X
    local y = frame_pos.Y + frame_size.Y

    return Vector2.new(x, y)
end

type tooltip = {
    tip: Frame & { TipName: TextLabel, TipInfo: TextLabel, Bar: Frame },
    line: Frame
}

local M = {}

function M.draw_tooltip(world_pos: Vector3, tip_pos: Vector3?, top_text: string, info_text: string, tooltip: tooltip): tooltip
    if tip_pos == nil then
	tooltip.tip.Position = UDim2.new(-2, 0, -2, 0)
	tooltip.line.Position = UDim2.new(-2, 0, -2, 0)
    end
    local screen_pos = camera:WorldToScreenPoint(world_pos)
    local tip_pos = camera:WorldToScreenPoint(tip_pos)
    local tip_pos = UDim2.new(0, tip_pos.X + 100, 0, tip_pos.Y - 75)

    tooltip.tip.Position = tip_pos
    tooltip.tip.TipName.Text = top_text:lower()
    tooltip.tip.TipInfo.Text = info_text:lower()

    local corner = get_bottom_left(tooltip.tip.Bar)
    draw_line(tooltip.line, screen_pos.X, screen_pos.Y, corner.X, corner.Y, true)

    return tooltip
end

function M.make_tooltip(world_pos: Vector3, tip_pos: Vector3?, top_text: string, info_text: string): tooltip
    local tip = assets.Tooltip:Clone() :: Frame
    tip.Parent = core
    local line = assets.Line:Clone()
    line.Parent = core

    local tooltip = { tip = tip, line = line }
    return M.draw_tooltip(world_pos, tip_pos, top_text, info_text, tooltip)
end

function M.remove_tooltip(tooltip: tooltip)
    tooltip.tip:Destroy()
    tooltip.line:Destroy()
end

function M.cursor(pos: Vector2)
    cursor.Position = UDim2.new(0, pos.X, 0, pos.Y)
end

function M.open_cursor()
    for _, thing in cursor:GetChildren() do
	if thing:IsA("Frame") == false then continue end
	TweenService:Create(thing, TweenInfo.new(0.1), { Position = thing:GetAttribute("open_pos") }):Play()
    end

    task.wait(0.075)

    for _, thing in cursor:GetChildren() do
	if thing:IsA("Frame") == false then continue end
	TweenService:Create(thing, TweenInfo.new(0.1), { Size = thing:GetAttribute("open_size") }):Play()
    end
end

function M.close_cursor()
    for _, thing in cursor:GetChildren() do
	if thing:IsA("Frame") == false then continue end
	TweenService:Create(thing, TweenInfo.new(0.1), { Size = thing:GetAttribute("close_size") }):Play()
    end

    task.wait(0.075)

    for _, thing in cursor:GetChildren() do
	if thing:IsA("Frame") == false then continue end
	TweenService:Create(thing, TweenInfo.new(0.1), { Position = thing:GetAttribute("close_pos") }):Play()
    end
end

return M
