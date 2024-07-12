# BoxesWorld

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jmuchovej.github.io/BoxesWorld.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jmuchovej.github.io/BoxesWorld.jl/dev/)
[![Build Status](https://github.com/jmuchovej/BoxesWorld.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jmuchovej/BoxesWorld.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jmuchovej/BoxesWorld.jl/branch/main/graph/badge.svg?token=tnd1L7sWgI)](https://codecov.io/gh/jmuchovej/BoxesWorld.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

A scalable MOMDP that mirrors a box-searching task for an item.
As a MOMDP, the agent will always know their `location` (represented by a `Point`), but
their belief will vary over the contents of the given boxes.

Suppose that:
- $B = \\{ \text{Box(1, 5)}, \text{Box(5, 5)}, \text{Box(5, 1)} \\}$
- $L = \\{ \text{Point(1, 1)}, \text{Point(1, 5)}, \text{Point(5, 5)}, \text{Point(5, 1)} \\}$
- $I = \\{ 🍋, 🍓, 🥝, 🍍 \\}$

**Note:** $\text{Point(1, 1)}$ is the spawn location.

- Action space ($\mathcal{A}$): `[[Move(box) for box in B]..., Take()]`
  - `Move(box)` will move the agent from its current location to the targeted `box`.
  - `Take()` will take the contents at the current box. At the spawn location, this is
    an invalid action which does not transition to a new state.
- Observation space ($\mathcal{O}$): `[item for item in I]`
  - `item` only has the requirement that it's a `Symbol`. Thus, the agent may observe
    whatever items you specify are allowed to be in the boxes.
    
    **Note** that `BoxesWorld` does not support items only being in certain boxes (e.g.,
    lemons (🍋) are only allowed in odd-number boxes).
- State space ($\mathcal{S}$): Each state is a known location drawn from $L$ and
  potential box contents, drawn from $I$ spread across the given boxes, thus there
  are $|B|^{|I|}$ combinations of items $I$ in boxes $B$.
  The state-space is always $|L| \times |B|^{|I|}$ where $|L|$ is the number of locations, $|B|$ is
  the number of boxes, and $|I|$ is the number of items.

## Example (3 boxes, 4 fruits: [🍋, 🍓, 🥝, 🍍])

<small>Example code in `examples/boxes=3-fruits=🍋🍓🥝🍍`</small>

The world is rotated by 45 degrees to accentuate costs, but is set in a 5x5 grid-like
world. Specifically, there are 3 boxes at `(1, 5)`, `(5, 5)`, and `(5, 1)`. Each box
may contain only one fruit, but collectively there may be any combination of fruits.

- Action space: `[Move(1), Move(2), Move(3), Take()]`
- Observation space: `[:🍋, :🍓, :🥝, :🍍]`
- State space:
```julia
  states = map([Point(1, 1), Point(1, 5), Point(5, 5), Point(5, 1)]) do location
    map(product(ITEMS, ITEMS, ITEMS)) do (box1, box2, box3)
      return State(location, [box1, box2, box3])
    end
  end |> flatten |> collect
  ```
  
  **Note** that `Point(1, 1)` is the spawn location – this is where initial beliefs may
  be modified so represent non-uniform initial beliefs!

<p align="middle">
  <img 
    src="./examples/boxes=3-fruits=🍋🥝🍓🍍/world.png"
    alt="Example of the BoxWorld layout with an agent, three boxes, and a kiwi, lemon, and strawberry in boxes 1, 2, and 3 respectively."
    width="45%"
    hspace="20"
    />
  <img 
    src="./examples/boxes=3-fruits=🍋🥝🍓🍍/trajectory.png"
    alt="Example of an Agent's trajectory in a BoxesWorld with three boxes. Boxes 1 and 2 have lemons, Box 3 has a strawberry. The agent moved to Box 2, then Box 3, and took the strawberry."
    width="45%"
    />
</p>

On the left, we have an agent in a 3-box world with a kiwi (🥝), lemon (🍋), and
strawberry (🍓) in boxes 1, 2, and 3, respectively. The agent cannot observe the
contents of the box until it visits the box.

On the right, we have an agent in a similar world but with lemons (🍋) in boxes 1
and 2, and a kiwi (🥝) in box 3. The agent took actions `Move(2), Move(3), Take()`.
Thus, the agent observed a lemon (🍋) in Box 2, then a strawberry (🍓) in Box 3, and took the
strawberry (🍓) in Box 3.