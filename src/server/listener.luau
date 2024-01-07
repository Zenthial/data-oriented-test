-- slight abstraction over remote events

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local function get_or_create(name: string): RemoteEvent
    local remote = folder:FindFirstChild(name)
    if remote ~= nil then return remote end

    remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = folder

    return remote
end

local M = {}

function M.listen(remote_name: string, callback: (player: Player, ...any) -> ())
    local remote = get_or_create(remote_name)

    remote.OnServerEvent:Connect(callback)
end

function M.send_to(remote_name: string, player: Player, ...)
    get_or_create(remote_name):FireClient(player, ...)
end

function M.send_to_many(remote_name: string, players: { Player })
    local remote = get_or_create(remote_name)

    for _, player in players do
        remote:FireClient(player)
    end
end

function M.announce(remote_name: string, ...)
    get_or_create(remote_name):FireAllClients(...)
end

return M
