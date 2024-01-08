--!strict

export type t<T> = {
    items: { T },
    equipped_item: T?
}

local M = {}

function M.make<T>(): t<T>
    return { items = table.create(2), equipped_item = nil }
end

function M.add<T>(inv: t<T>, item: T, slot: number)
    inv.items[slot] = item
end

function M.get<T>(inv: t<T>, slot: number): T?
    return inv.items[slot]
end

function M.equip<T>(inv: t<T>, item: T)
    inv.equipped_item = item
end

function M.unequip<T>(inv: t<T>)
    inv.equipped_item = nil
end

function M.remove<T>(inv: t<T>, item: T)
    local idx = table.find(inv.items, item)
    if idx ~= nil then
        if inv.equipped_item == item then
            inv.equipped_item = nil
        end

        inv.items[idx] = nil
    end
end

return M
