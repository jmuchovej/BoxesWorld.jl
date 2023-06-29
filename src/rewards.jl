function POMDPs.reward(p::BoxWorld, s::State, a::MoveAction)
    box = s.pos
    boxp = p.boxes[a.target].pos

    return -1. * euclidean(box, boxp)
end

function POMDPs.reward(p::BoxWorld, s::State, a::TakeAction)
    box_idx = findfirst(isequal(s.pos), [box.pos for box in p.boxes]) 

    if isa(box_idx, Nothing)
        return 0
    end

    item = s.items[box_idx]
    return p.rewards[item]
end