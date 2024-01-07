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
            local track = ani.animator:LoadAnimation(animation)
            ani.tracks[animation.Name] = track
        end
    end

    return ani
end

local animation = {}

function animation.make(instance: Instance): t
    local animator = instance:FindFirstChildOfClass("Animator")
    if animator == nil then
        error("Instance " .. instance.Name .. " does not have an Animator")
    end

    local ani = load_default_animations({ tracks = {}, playing = {}, animator = animator })
    return ani
end

function animation.load(ani: t, animations: { Animation }): t
    for _, animation in animations do
        local track = ani.animator:LoadAnimation(animation)
        ani.tracks[animation.Name] = track
    end

    return ani
end

function animation.play(ani: t, track: string): AnimationTrack
    local playing_track = ani.tracks[track]
    if playing_track == nil then error("Attempted to play track " .. track .. " that does not exist") end
    ani.playing[track] = playing_track

    playing_track:Play()
    return playing_track
end

function animation.play_all(ani: t, tracks: { string })
    for _, track in tracks do
        animation.play(ani, track)
    end
end

function animation.stop(ani: t, track: string)
    local playing_track = ani.playing[track]
    if playing_track == nil then warn("Track " .. track .. " is not playing"); return end
    ani.playing[track] = nil

    playing_track:Stop()
end

function animation.stop_all(ani: t, tracks: { string })
    for _, track in tracks do
        animation.stop(ani, track)
    end
end

return animation
