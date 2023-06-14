using Test
using Random
using BoxesWorld
using POMDPs
using POMDPTools
using QMDP
using NativeSARSOP

const FRUITS = [:🍋, :🍒, :🥝]
pomdp() = BoxWorld(;
    items=FRUITS,
    boxes=[Box(1, 5, :🍋), Box(5, 1, :🥝), Box(5, 5, :🍒)],
    spawn=Point(1, 1),
    rewards=Dict(f => r for (f, r) in zip(FRUITS, [20, 10, 5]))
)

@testset "BoxWorld: S" begin
    p = pomdp()
    state_iter = states(p)
    S = ordered_states(p)
    @test length(state_iter) == length(S)
    @test all([state == S[idx] for (idx, state) in enumerate(state_iter)])
    @test all([state.pos == p.spawn for state in initialstate(p).vals])
    @test has_consistent_initial_distribution(p)
end

@testset "BoxWorld: A" begin
    p = pomdp()
    action_iter = actions(p)
    A = ordered_actions(p)
    @test length(action_iter) == length(A)
    @test length(filter(a -> a isa MoveAction, A)) == length(p.boxes)
    @test all([action == A[idx] for (idx, action) in enumerate(action_iter)])
end

@testset "BoxWorld: O" begin
    rng = MersenneTwister(42)

    p = pomdp()
    obs_iter = observations(p)
    O = ordered_observations(p)
    @test length(obs_iter) == length(O)
    @test all([obs == O[idx] for (idx, obs) in enumerate(obs_iter)])

    s0 = rand(rng, initialstate(p))
    obs = rand(rng, observation(p, Move(1), s0))
    @test obs == s0.items[1]
    # @inferred observation(p, Move(2), s0)
    # @inferred observation(p, Take() , s0)
    obs = rand(rng, observation(p, Take() , s0))
    @test obs == :null
    @test has_consistent_observation_distributions(p)
end

@testset "BoxWorld: Solvers" begin
    p = pomdp()
    qmdp = QMDPSolver()
    policy = solve(qmdp, p)
    @test policy isa AlphaVectorPolicy
    
    p = pomdp()
    sarsop = SARSOPSolver()
    policy = solve(sarsop, p)
    @test policy isa AlphaVectorPolicy
end
