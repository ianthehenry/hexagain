---
title: "Bridges and Connectivity"
weight: 2
---

A bridge is when two pieces are "diagonally apart" from one another, with two empty cells between them.

<script type="application/json">
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"]]
}
</script>

While these pieces aren't actually touching, it would be pretty hard to separate them: there are two empty hexes between them. If white plays on one of them, black can play on the other.

<script type="application/json">
[
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"]]
},
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"], ["white", "c4"]]
},
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"], ["white", "c4"], ["black", "d3"]]
},
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"]]
},
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"], ["white", "d3"]]
},
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"], ["white", "d3"], ["black", "c4"]]
}
]
</script>

<script type="application/json">
{
    "size": 6,
    "pieces": [["black", "c3"], ["black", "d4"]],
    "annotations": [["bridge", "c3", "d4"]]
}
</script>

# Strong Connections

We can generalize this idea to "strong connections." When two pieces, or two groups of pieces, have multiple non-overlapping paths that could connect them, we'll say that they're "strongly connected."

