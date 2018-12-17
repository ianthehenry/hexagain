---
title: "The Rules of Hex"
weight: 1
---

Hex is a board game for two players. It's played on a grid of hexagons arranged in a rhombus. The edges of the rhombus are colored black, white, black, white.

Two players, black and white, take turns placing stones of their own color on the board. Once a piece is placed, it's there for the rest of the game: there is no way to capture pieces, and there is no way to move them.

<script type="application/json">
{
    "size": 5,
    "initialTurn": 0,
    "moves": ["c2", "d2", "c4", "c3", "b4", "e3", "d5", "e5", "e4", "d4", "c5", "a4", "a5"]
}
</script>

The game ends when a player connects their edges with an unbroken chain of stones of their color.

# The board

Hex can be played on any size board, but the most common is a board with 11 hexes on each edge.

# The Pie Rule

As in most abstract strategy games, the first player has a very strong advantage in Hex.

To mitigate this, it's common for one player to place the first black stone, and for the other player to decide who plays black.

If the opening move is too strong, then the second player will decide to play as black. If the opening move is too weak, then the player who made it is stuck with it while their opponent makes a good move as white.

This creates a natural motivation to balance the first move as much as possible.

The term "pie rule" comes from slicing a pie in half. One person makes a cut, the other. The person making the cut knows they're going to get the smaller piece of pie, so they try to make the pieces as equally-sized as possible.

# Handicaps

Two players of different skill levels can still have interesting games by assigning a handicap to the stronger player.

The simplest handicap is simply playing without the pie rule, and letting the weaker player move first.

The weaker player can be given a further advantage by letting them start with pieces on the board.

Unlike Go, there is no widely recognized standard arrangement of handicap stones or handicap strengths.
