export type t = {
    -- state
    charge: number, -- always 0 to 100
    overheated: boolean,
    last_use: number,
    -- stats
    depletion_rate: number, 
    recharge_time: number,
    recharge_delay: number,
}

local M = {}

function M.make(depletion_rate: number, recharge_time: number,recharge_delay: number): t
    return {
        charge = 100,
        overheated = false,
        last_use = 0,
        depletion_rate = depletion_rate, 
        recharge_time = recharge_time,
        recharge_delay = recharge_delay,
    }
end

function M.depleted(bat: t): boolean
    return bat.charge > 0 and not bat.overheated
end

function M.recharge(bat: t)
    local last_use = tick()
    bat.last_use = last_use
    task.wait(bat.recharge_delay)

    local recharge_wait = 10 / bat.recharge_time
    while bat.charge ~= 100 and bat.last_use == last_use do
        bat.charge = math.clamp(bat.charge + recharge_wait, 0, 100)
        print(bat.charge)
        task.wait(0.1)
    end

    if bat.overheated and bat.charge == 100 then
        bat.overheated = false
    end
end

function M.use(bat: t)
    bat.charge = math.clamp(bat.charge - bat.depletion_rate, 0, 100)
    if bat.charge == 0 then bat.overheated = true end
    task.spawn(M.recharge, bat)
end

return M
