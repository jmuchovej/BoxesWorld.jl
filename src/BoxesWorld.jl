module BoxesWorld

using POMDPs
using POMDPs: POMDP, isterminal, discount
using POMDPTools: SparseCat, Deterministic
using StaticArrays: SVector, @SVector
using Distances: euclidean
using DataStructures: OrderedDict

export Point, State, Action, Move, MoveAction, Take, TakeAction, Box, BoxWorld

const Point = SVector{2, R} where {R <: Real}

struct State{K}
    pos::Point
    items::SVector{K, Symbol}
end
function State(pos::Point, items::Vector)
    items = SVector{length(items)}(items)
    return State{length(items)}(pos, items)
end
Base.:(==)(state::State, p::Point) = state.pos == p
Base.length(::State{K}) where {K} = K
function Base.iterate(state::State, index::Int=1)
    if index > length(state.items)
        return nothing
    end

    return (state.items[index], index + 1)
end

struct Action{t}
    target::Number
end

struct Box
    pos::Point
end
Box(x::Number, y::Number) = Box(Point(x, y))
Base.:(==)(state::State, box::Box) = state.pos == box.pos

struct BoxWorld{K} <: POMDP{State{K}, Action, Symbol}
    spawn::Point

    items::Vector{Symbol}
    boxes::SVector{K, Box}

    terminal::State{K}

    rewards::OrderedDict{Symbol, <:Number}
    discount::Real
end

function BoxWorld(;
    items::Vector{Symbol},
    boxes::Vector,
    spawn::Point,
    rewards::OrderedDict{Symbol, Real},
    discount=0.95,
)
    terminal = State{length(boxes)}(Point(-1, -1), fill(:null, length(boxes)))

    @assert issubset(items, keys(rewards))

    boxes = SVector{length(boxes)}(boxes)
    return BoxWorld{length(boxes)}(spawn, items, boxes, terminal, rewards, discount)
end

locations(p::BoxWorld) = [p.spawn, [box.pos for box ∈ p.boxes]...]

function POMDPs.isterminal(p::BoxWorld, s::State)
    return s == p.terminal
end

function POMDPs.discount(p::BoxWorld)
    return p.discount
end

include("./states.jl")
include("./actions.jl")
include("./transitions.jl")
include("./observations.jl")
include("./rewards.jl")

end
