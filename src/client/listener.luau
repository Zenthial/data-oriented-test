-- slight abstraction over remote events
-- pairs with the server listener

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:WaitForChild("Remotes")

local function get_or_wait(name: string): RemoteEvent
    local remote = folder:WaitForChild(name)
    return remote
end

local M = {}

function M.listen(remote_name: string, callback: (...any) -> ())
    local remote = get_or_wait(remote_name)

    remote.OnClientEvent:Connect(callback)
end

function M.send(remote_name: string, ...)
    get_or_wait(remote_name):FireServer(...)
end

return M
