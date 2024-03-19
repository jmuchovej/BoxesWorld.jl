using POMDPs: reward
using Distances: euclidean

function POMDPs.reward(p::BoxWorld, s::State, a::MoveAction)
    box = s.pos
    boxp = p.boxes[a.target].pos

    mv_cost = -1 * euclidean(box, boxp)

    #* Is the agent staying at an already visited box? Penalize them.
    exploration_bonus = box == boxp ? -p.rewards[s.items[a.target]] : 0

    return mv_cost + exploration_bonus
end

function POMDPs.reward(p::BoxWorld, s::State, a::TakeAction)
    box_idx = findfirst(isequal(s.pos), [box.pos for box ∈ p.boxes])

    reward = -1
    if isa(box_idx, Nothing)
        return -1
        # return -1e4
    end

    item = s.items[box_idx]
    return reward + p.rewards[item]
end
