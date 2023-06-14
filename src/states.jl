function Base.CartesianIndices(p::BoxWorld)
    nlocations = length(p.boxes) + 1  # "+ 1" for `spawn` as a location
    box_item_combos = fill(length(p.items), length(p.boxes))
    return CartesianIndices((box_item_combos..., nlocations))
end

function Base.LinearIndices(p::BoxWorld)
    return LinearIndices(CartesianIndices(p))
end

function Base.length(p::BoxWorld)
    return length(CartesianIndices(p)) + 1
end

function POMDPs.stateindex(p::BoxWorld, s::State)
    if isterminal(p, s)
        return length(p)
    end

    pos_idx   = findfirst(isequal(s.pos), locations(p))
    int_boxes = [findfirst(isequal(item), p.items) for item in s.items]
    as_index  = CartesianIndex((int_boxes..., pos_idx))

    stateindex = LinearIndices(p)[as_index]
    return stateindex
end

function Base.getindex(p::BoxWorld, stateindex::Int)
    if stateindex == length(p)
        return p.terminal
    end

    indices = CartesianIndices(p)[stateindex].I
    (item_idxs, location_idx) = (indices[1:end - 1], indices[end])

    location = locations(p)[location_idx]
    items = [p.items[item_idx] for item_idx in item_idxs]

    state = State(location, items)

    return state
end

function Base.iterate(p::BoxWorld, stateindex::Int = 1)
    if stateindex > length(p)
        return nothing
    end

    state = p[stateindex]
    return (state, stateindex + 1)
end

function POMDPs.states(p::BoxWorld)
    return collect(p)    
end

function POMDPs.initialstate(p::BoxWorld)
    spawnstates = filter(s -> s.pos == p.spawn, states(p))

    probs = fill(1 / length(spawnstates), length(spawnstates))
    dist  = SparseCat(spawnstates, probs)

    return dist
end