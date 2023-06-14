module BoxesWorld

using POMDPs
using POMDPs: POMDP
using POMDPTools: SparseCat, Deterministic
using StaticArrays: SVector, @SVector
using Distances: euclidean

export Point,
    State,
    Action,
    Move, MoveAction,
    Take, TakeAction,
    Box,
    BoxWorld

const Point = SVector{2, R} where {R <: Real}

struct State{K}
    pos::Point
    items::SVector{K, Symbol}
end
function State(pos::Point, items::Vector)
    items = SVector{length(items)}(items)
    return State{length(items)}(pos, items)
end

struct Action{t}
    target::Number
end

struct Box
    pos::Point
    item::Symbol
end
Box(x::Number, y::Number, item::Symbol) = Box(Point(x, y), item)

struct BoxWorld{K} <: POMDP{State{K}, Action, Symbol}
    spawn::Point

    items::Vector{Symbol}
    boxes::SVector{K, Box}

    terminal::State{K}

    rewards::Dict{Symbol, Number}
end

function BoxWorld(; items::Vector{Symbol}, boxes::Vector, spawn::Point, rewards::Dict)
    terminal = State{length(boxes)}(Point(-1, -1), fill(:null, length(boxes))) 

    @assert issubset(items, keys(rewards))
    @assert issubset([b.item for b in boxes], items)

    boxes = SVector{length(boxes)}(boxes)
    return BoxWorld{length(boxes)}(spawn, items, boxes, terminal, rewards)
end

locations(p::BoxWorld) = [p.spawn, box_locations(p)...]
all_locations(p::BoxWorld) = [p.spawn, box_locations(p)...]
box_locations(p::BoxWorld) = [b.pos for b in p.boxes]
realitems(p::BoxWorld) = [b.item for b in p.boxes]

function POMDPs.isterminal(p::BoxWorld, s::State)
    return s == p.terminal
end

function POMDPs.discount(p::BoxWorld)
    return 0.999
end

include("./states.jl")
include("./actions.jl")
include("./transitions.jl")
include("./observations.jl")
include("./rewards.jl")

end
