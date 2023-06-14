function POMDPs.observations(p::BoxWorld)
    return [p.items..., :null]
end

function POMDPs.obsindex(p::BoxWorld, o::Symbol)
    return findfirst(isequal(o), observations(p))
end

function POMDPs.observation(p::BoxWorld, a::MoveAction, sp::State)
    idx = obsindex(p, sp.items[a.target])

    dist = zeros(length(observations(p)))
    dist[idx] = 1.0

    return SparseCat(observations(p), dist)
end

function POMDPs.observation(p::BoxWorld, a::TakeAction, sp::State)
    idx = obsindex(p, :null)

    dist = zeros(length(observations(p)))
    dist[idx] = 1.0

    return SparseCat(observations(p), dist)
end
