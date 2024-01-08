--!nolint LocalShadow
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local global_animations = ReplicatedStorage:WaitForChild("GlobalAnimations")

export type t = {
    tracks: { [string]: AnimationTrack? }, -- loaded tracks
    playing: { [string]: AnimationTrack? }, -- hashtable lookup technically will take longer, but easier to program
    animator: Animator
}

local function load_default_animations(ani: t): t
    for _, animation in global_animations:GetChildren() do
        if animation:IsA("Animation") then
            if ani.tracks[animation.Name] ~= nil then continue end
            local track = ani.animator:LoadAnimation(animation)
            ani.tracks[animation.Name] = track
        end
    end

    return ani
end

local M = {}

function M.make(instance: Instance): t
    local animator = instance:FindFirstChildOfClass("Animator")
    if animator == nil then
        error("Instance " .. instance.Name .. " does not have an Animator")
    end

    local ani = load_default_animations({ tracks = {}, playing = {}, animator = animator })
    return ani
end

function M.load(ani: t, animations: { Animation }, name_prefix: string?): t
    for _, animation in animations do
        local track = ani.animator:LoadAnimation(animation)
        local name = (name_prefix or "") .. animation.Name
        if ani.tracks[name] ~= nil then continue end
        ani.tracks[name] = track
    end

    return ani
end

function M.play(ani: t, track: string): AnimationTrack
    local playing_track = ani.tracks[track]
    if playing_track == nil then error("Attempted to play track " .. track .. " that does not exist") end
    ani.playing[track] = playing_track

    playing_track:Play()
    return playing_track
end

function M.play_all(ani: t, tracks: { string })
    for _, track in tracks do
        M.play(ani, track)
    end
end

function M.stop(ani: t, track: string)
    local playing_track = ani.playing[track]
    if playing_track == nil then return end
    ani.playing[track] = nil

    playing_track:Stop()
end

function M.stop_all(ani: t, tracks: { string })
    for _, track in tracks do
        M.stop(ani, track)
    end
end

function M.stop_playing(ani: t)
    for _, track in ani.playing do
        if track == nil then continue end
        track:Stop()
    end

    table.clear(ani.playing)
end

return M
