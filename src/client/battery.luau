export type t = {
    charge: number, -- always 0 to 100
    depletion_rate: number, 
    recharge_rate: number,
    recharge_delay: number,
}

local battery = {}

function battery.depleted(bat: t): boolean
    return bat.charge > 0
end

function battery.recharge(bat: t)
    task.wait(bat.recharge_delay)
    while bat.charge ~= 100 do
        bat.charge = math.clamp(bat.charge + bat.recharge_rate, 0, 100)
        task.wait(0.1)
    end
end

function battery.use(bat: t)
    bat.charge = math.clamp(bat.charge - bat.depletion_rate, 0, 100)
    if bat.charge == 0 then
        task.spawn(battery.recharge, bat)
    end
end

return battery
