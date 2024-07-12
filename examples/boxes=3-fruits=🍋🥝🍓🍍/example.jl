using POMDPs
using BoxesWorld

const BOXES = [Box(1, 5), Box(5, 5), Box(5, 1)]
const ITEMS = [:🍋, :🍓, :🥝, :🍍]
rewards = OrderedDict(zip(ITEMS, [-40., 5., 15, 40]))

pomdp = BoxWorld(;
    items=ITEMS,
    spawn=Point(1, 1),
    boxes=BOXES,
)

solver = SARSOPSolver()
policy = solve(solver, pomdp)
