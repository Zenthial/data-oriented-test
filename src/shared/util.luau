local M = {}

function M.find<T>(tbl: { T }, search: (T) -> boolean): T?
    for _, thing in tbl do
        if search(thing) then
            return thing
        end
    end

    return nil
end

function M.merge(...)
  local result = {}
  -- For each source table
  for _, t in ipairs{...} do
    -- For each pair in t
    for k, v in pairs(t) do
      result[k] = v
    end
  end
  return result
end

return M
