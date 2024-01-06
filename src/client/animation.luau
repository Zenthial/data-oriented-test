--!nolint LocalShadow
--!strict
export type t = {
    tracks: { [string]: AnimationTrack? }, -- loaded tracks
    playing: { [string]: AnimationTrack? }, -- hashtable lookup technically will take longer, but easier to program
    animator: Animator
}

local animation = {}

function animation.make(model: Model): t
    local animator = model:FindFirstChildOfClass("Animator")
    if animator == nil then
        error("Model " .. model.Name .. " does not have an Animator")
    end

    return { tracks = {}, playing = {}, animator = animator }
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

function animation.stop(ani: t, track: string)
    local playing_track = ani.playing[track]
    if playing_track == nil then warn("Track " .. track .. " is not playing"); return end
    ani.playing[track] = nil

    playing_track:Stop()
end

return animation
