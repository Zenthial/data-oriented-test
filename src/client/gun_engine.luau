--!nolint LocalShadow

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local shared = ReplicatedStorage:WaitForChild("Shared")

local Keymaps = require(shared.keymaps)
local Inventory = require(script.Parent.inventory)
local Movement = require(script.Parent.movement)
local Animation = require(script.Parent.animation)
local Weapon = require(script.Parent.weapon)
local Char = require(script.Parent.char)
local Ui = require(script.Parent.ui)
local Battery = require(script.Parent.battery)
local Listener = require(script.Parent.listener)
local Ignored = require(script.Parent.ignored)

local AIMBUFF = 3

local function get_aim(w: Weapon.t, dist: number)
    local minspread = w.min_spread
	local maxspread = w.max_spread
	
	if w.aiming then
		minspread = minspread / AIMBUFF
		maxspread = maxspread / AIMBUFF
	end
	
	local spread = maxspread * (w.recoil / 100) + minspread
	local x = math.random(-(spread/10) * dist, (spread/10) * dist)/10
	local y = math.random(-(spread/10) * dist, (spread/10) * dist)/10
	local z = math.random(-(spread/10) * dist, (spread/10) * dist)/10
	return Vector3.new(x,y,z)
end

local M = {
    weapon_equiping = false
}

function M.raycast(weapon: Weapon.t, origin: Vector3, target: Vector3, range: number?): (Part?, Vector3)
    local range = range or 1000 -- default range to 1000 if none is provided
    local distance = (origin - target).Magnitude
    -- we check if we should apply spread. certain guns are dead accurate from close range, similar to old SMO STAs
    local aim = if distance > weapon.no_spread_distance then target + get_aim(weapon, distance) else target

    local end_pos = (aim - origin).Unit * range
    local result = workspace:Raycast(origin, end_pos, Ignored.raycast_params())
    if result and result.Position then
        return result.Instance, result.Position
    else
        return nil, end_pos
    end
end

function M.can_shoot(weapon: Weapon.t): boolean
    return Battery.depleted(weapon.battery) and Char.alive() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

function M.check_for_damage(weapon: Weapon.t, part: Part)
    -- todo
end

-- will need to replace Weapon.t with the individual data points we need, as this function should be reused for drawing other client's rays
function M.draw_ray(weapon: Weapon.t, end_pos: Vector3)
    local start_pos = Weapon.barrel(weapon)
    local i_dist = (end_pos - start_pos).Magnitude

    local bullet1 = Weapon.bullet(weapon)
    bullet1.Mesh.Scale = Vector3.new(bullet1.Mesh.Scale.X, bullet1.Mesh.Scale.Y, i_dist)
    bullet1.CFrame = CFrame.new(start_pos, end_pos) * CFrame.new(0, 0, -i_dist / 2)
    bullet1.Parent = workspace
    
    local bullet2 = Weapon.bullet(weapon)
    bullet2.Mesh.Scale = Vector3.new(bullet1.Mesh.Scale.X, bullet1.Mesh.Scale.Y, i_dist)
    bullet2.CFrame = CFrame.new(start_pos, end_pos) * CFrame.new(0, 0, -i_dist / 2)
    bullet1.Parent = workspace

    task.delay(0.05, bullet1.Destroy, bullet1)
    task.delay(0.1, bullet2.Destroy, bullet2)
end

function M.shoot(weapon: Weapon.t)
    local origin = Char.origin()
    local target = mouse.Hit.Position
    if origin == nil then return end -- character does not exist, dont shoot
    local part, position = M.raycast(weapon, origin, target)
    M.draw_ray(weapon, position)
    if part ~= nil then
        M.check_for_damage(weapon, part)
    end
end

function M.fire(weapon: Weapon.t)
    if M.can_shoot(weapon) == false then return end

    Weapon.set_shooting(weapon, true)
    if weapon.fire_mode == "Auto" then
        repeat
            M.shoot(weapon)
            task.wait(1 / weapon.fire_rate)
        until M.can_shoot(weapon) == false
    elseif weapon.fire_mode == "Semi" then
        M.shoot(weapon)
    end
    Weapon.set_shooting(weapon, false)
end

function M.unequip_weapon(w: Weapon.t, ani: Animation.t)
    M.weapon_equiping = true
    for animation_name, _ in ani.playing do
        if string.find(animation_name, "sprinting") then
            Animation.stop(ani, animation_name)
        end
    end

    Animation.stop_all(ani, { w.name .. "equipMiddle", w.name .. "equipTop" })

    if w.slot == "Primary" then
        Animation.play(ani, w.name.."equippingArm")
        task.wait(0.3) -- equip time
        Animation.stop(ani, w.name.."equippingArm")
    end

    Listener.send("weld", w.name, true)
    -- task.spawn(Ui.close_cursor)
    M.weapon_equiping = false
end

function M.equip_weapon(w: Weapon.t, inv: Inventory.t<Weapon.t>, ani: Animation.t, sprinting: boolean)
    M.weapon_equiping = true
    Listener.send("weld", w.name, false)

    Animation.play(ani, w.name.."equippingArm")
    task.wait(0.3) -- equip time
    Animation.stop(ani, w.name.."equippingArm")

    if sprinting then
        Animation.play_all(ani, { w.name .. "sprintingMiddle", w.name .. "sprintingTop" })
    else
        Animation.play_all(ani, { w.name .. "equipMiddle", w.name .. "equipTop" })
    end

    local top_text = string.format('<font color="#FF7800">%s</font>', w.name)
    local bottom_text = w.quick_desc
    local tooltip = Ui.make_tooltip()
    local con
    local function cleanup()
        if con ~= nil then
            con:Disconnect()
        end

        Ui.remove_tooltip(tooltip)
    end
    con = RunService.RenderStepped:Connect(function()
        local equipped_item = inv.equipped_item :: Weapon.t -- type thing because luau lsp complains otherwise
        if equipped_item ~= w then
            cleanup()
            return
        end
        tooltip = Ui.draw_tooltip(Weapon.hologram(w), Char.origin(), top_text, bottom_text, tooltip, true, w.slot)
    end)

    task.delay(2, cleanup)
    -- task.spawn(Ui.open_cursor)
    M.weapon_equiping = false
end

function M.overheat(w: Weapon.t, inv: Inventory.t<Weapon.t>)
    local top_text = '<font color="#eb144c">overheated</font>'
    local bottom_text = "battery overheated"

    local tooltip = Ui.make_tooltip()
    local con
    local function cleanup()
        if con ~= nil then
            con:Disconnect()
        end

        Ui.remove_tooltip(tooltip)
    end
    con = RunService.RenderStepped:Connect(function()
        local equipped_item = inv.equipped_item :: Weapon.t -- type thing because luau lsp complains otherwise
        if w.battery.overheated == false then
            cleanup()
            return
        end
        tooltip = Ui.draw_tooltip(Weapon.hologram(w), Char.origin(), top_text, bottom_text, tooltip, equipped_item == w, w.slot)
    end)

    task.delay(2, cleanup)
    Ui.set_overheated(w.model)
end

function M.began(inv: Inventory.t<Weapon.t>, mov: Movement.t, ani: Animation.t, input: InputObject)
    if input.UserInputType == Keymaps.shoot then
        if inv.equipped_item ~= nil then
            M.fire(inv.equipped_item)
        end
    end
    local w
    if input.KeyCode == Keymaps.primary then
        w = Inventory.get(inv, Keymaps.primary.Value)
    elseif input.KeyCode == Keymaps.secondary then
        w = Inventory.get(inv, Keymaps.secondary.Value)
    end
    if w == nil then return end
    if M.weapon_equiping == true then return end

    if inv.equipped_item == w then
        Inventory.unequip(inv)
        M.unequip_weapon(w, ani)
    else
        M.equip_weapon(w, inv, ani, mov.state == "Sprint")
        Inventory.equip(inv, w)
    end
end

return M
