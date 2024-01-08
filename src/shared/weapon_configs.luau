export type fire_mode = "Auto" | "Semi"
export type slot = "Primary" | "Secondary"

export type t = {
    name: string,
    slot: slot,
    -- gun shooting info
    fire_mode: fire_mode,
    min_spread: number, max_spread: number, no_spread_distance: number,
    fire_rate: number,
    damage: number, headshot_mul: number,
    -- battery info
    depletion_rate: number, 
    recharge_time: number,
    recharge_delay: number,
}

local configs: { t } = {
    {
        name = "W17",
        slot = "Primary",
        fire_mode = "Auto",
        min_spread = 0.5, max_spread = 2.5, no_spread_distance = 0,
        fire_rate = 11,
        damage = 7, headshot_mul = 2,
        depletion_rate = 2,
        recharge_time = 3,
        recharge_delay = 0.3
    }
}

return configs
