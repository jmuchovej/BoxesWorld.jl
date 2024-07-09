using POMDPs: reward
using Distances: euclidean

function POMDPs.reward(p::BoxWorld, s::State, a::MoveAction)
    box = s.pos
    boxp = p.boxes[a.target].pos

    mv_cost = -1 * euclidean(box, boxp)

    #* Is the agent loitering at the current box? Penalize them.
    loitering_penalty = box == boxp ? -1 : 0

    return mv_cost + loitering_penalty
end

function POMDPs.reward(p::BoxWorld, s::State, a::TakeAction)
    box_idx = findfirst(isequal(s.pos), [box.pos for box ∈ p.boxes])

    reward = -1
    if isnothing(box_idx)
        return reward
    end

    item = s.items[box_idx]
    return reward + p.rewards[item]
end
