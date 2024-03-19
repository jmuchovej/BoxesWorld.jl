using POMDPs: transition

function POMDPs.transition(p::BoxWorld, s::State, a::MoveAction)
    if isterminal(p, s)
        return Deterministic(s)
    end

    box_pos = p.boxes[a.target].pos
    sp = State(box_pos, s.items)

    return Deterministic(sp)
end

function POMDPs.transition(p::BoxWorld, ::State, ::TakeAction)
    return Deterministic(p.terminal)
end
