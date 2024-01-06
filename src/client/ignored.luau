local CollectionService = game:GetService("CollectionService")

local ignored = {}

-- could be expanded to handle multi ignore lists
function ignored.get_ignored()
    return CollectionService:GetTagged("ignore")
end

function ignored.raycast_params()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignored.get_ignored()

    return params
end

return ignored
