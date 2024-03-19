using POMDPs: actions, actionindex

const MoveAction = Action{:move}
Move(target::Number) = Action{:move}(target)

const TakeAction = Action{:take}
Take() = Action{:take}(0)

function POMDPs.actions(p::BoxWorld)
    moves = Move.(1:length(p.boxes))
    return [moves..., Take()]
end

function POMDPs.actionindex(p::BoxWorld, a::Action)
    return findfirst(isequal(a), actions(p))
end
