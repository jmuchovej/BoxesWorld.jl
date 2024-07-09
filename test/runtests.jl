using Test
using Random
using BoxesWorld
using POMDPs
using POMDPTools
using NativeSARSOP

const FRUITS = [:🍋, :🍒, :🥝]
function pomdp()
    return BoxWorld(;
        items=FRUITS,
        boxes=[Box(1, 3), Box(3, 3), Box(3, 1)],
        spawn=Point(1, 1),
        rewards=Dict(f => r for (f, r) ∈ zip(FRUITS, [20.0, 10.0, 5.0])),
    )
end

@testset "BoxWorld: S" begin
    p = pomdp()
    state_iter = states(p)
    S = ordered_states(p)
    @test length(state_iter) == length(S)
    @test all([state == S[idx] for (idx, state) ∈ enumerate(state_iter)])
    @test all([state.pos == p.spawn for state ∈ initialstate(p).vals])
    @test has_consistent_initial_distribution(p)
end

@testset "BoxWorld: A" begin
    p = pomdp()
    action_iter = actions(p)
    A = ordered_actions(p)
    @test length(action_iter) == length(A)
    @test length(filter(a -> a isa MoveAction, A)) == length(p.boxes)
    @test all([action == A[idx] for (idx, action) ∈ enumerate(action_iter)])
end

@testset "BoxWorld: O|Z" begin
    rng = MersenneTwister(42)

    p = pomdp()
    obs_iter = observations(p)
    O = ordered_observations(p)
    @test length(obs_iter) == length(O)
    @test all([obs == O[idx] for (idx, obs) ∈ enumerate(obs_iter)])

    s0 = rand(rng, initialstate(p))
    obs = rand(rng, observation(p, Move(1), s0))
    @test obs == s0.items[1]
    # @inferred observation(p, Move(2), s0)
    # @inferred observation(p, Take() , s0)
    obs = rand(rng, observation(p, Take(), s0))
    @test obs == :null
    @test has_consistent_observation_distributions(p)
end

@testset "BoxWorld: T" begin
    rng = MersenneTwister(42)
    p = pomdp()

    s = rand(rng, initialstate(p))
    sp = rand(rng, transition(p, s, Move(1)))
    @test sp.pos == p.boxes[1].pos
    @test s.items == sp.items

    @test transition(p, s, Move(1)) isa Deterministic

    s = rand(rng, initialstate(p))
    sp = rand(rng, transition(p, s, Take()))
    @test isterminal(p, sp)
    @test sp.items == p.terminal.items

    @test transition(p, s, Take()) isa Deterministic

    @test has_consistent_transition_distributions(p)
end

@testset "BoxWorld: Solvers" begin
    p = pomdp()
    sarsop = SARSOPSolver()
    policy = solve(sarsop, p)
    @test policy isa AlphaVectorPolicy
end
