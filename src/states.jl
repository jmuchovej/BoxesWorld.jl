using POMDPs: stateindex, states, initialstate
using LinearAlgebra: normalize

function Base.CartesianIndices(p::BoxWorld)
    nlocations = length(locations(p))
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

    pos_idx = findfirst(isequal(s.pos), locations(p))
    int_boxes = [findfirst(isequal(item), p.items) for item ∈ s.items]
    as_index = CartesianIndex((int_boxes..., pos_idx))

    stateindex = LinearIndices(p)[as_index]
    return stateindex
end

function Base.getindex(p::BoxWorld, stateindex::Int)
    if stateindex == length(p)
        return p.terminal
    end

    index = CartesianIndices(p)[stateindex]
    return getindex(p, index)
end

function Base.getindex(p::BoxWorld, stateindex::CartesianIndex)
    (item_idxs..., location_idx) = stateindex.I

    location = locations(p)[location_idx]
    items = [p.items[idx] for idx ∈ item_idxs]

    state = BoxesWorld.State(location, items)

    return state
end

function Base.iterate(p::BoxWorld, stateindex::Int=1)
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
    spawn_index = findfirst(isequal(p.spawn), locations(p))
    num_boxes = ntuple(_ -> Colon(), length(p.boxes))
    indices = CartesianIndices(p)[num_boxes..., spawn_index]
    spawnstates = [p[index] for index ∈ indices][:]

    probs = normalize(ones(length(spawnstates)), 1)
    dist = SparseCat(spawnstates, probs)

    return dist
end
