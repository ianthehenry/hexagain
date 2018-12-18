---
title: "Bridges"
weight: 2
---

A bridge is when two pieces are "diagonally apart" from one another, with two empty cells between them.

<script type="application/json">
((dimensions 6x6)
 (stones ((Black C3) (Black D4))))
</script>

While these pieces aren't actually touching, white cannot separate them in a single move. If white plays between the stones, black can always play on the other hex.

<script type="application/json">
(
    ((dimensions 6x6)
     (stones ((Black C3) (Black D4))))
    ((dimensions 6x6)
     (stones ((Black C3) (Black D4) (White C4))))
    ((dimensions 6x6)
     (stones ((Black C3) (Black D4) (White C4) (Black D3))))

    ((dimensions 6x6)
     (stones ((Black C3) (Black D4))))
    ((dimensions 6x6)
     (stones ((Black C3) (Black D4) (White D3))))
    ((dimensions 6x6)
     (stones ((Black C3) (Black D4) (White D3) (Black C4))))
)
</script>

This pattern comes up a lot. When we annotate hex connections, we'll use the following notation to indicate a bridge, or the potential for a bridge:

<script type="application/json">
((dimensions 6x6)
 (stones ((Black C3) (Black D4)))
 (annotations ((Bridge C3 D4))))
</script>

# Strong Connections

We can generalize this idea to "strong connections." When two pieces, or two groups of pieces, have multiple non-overlapping paths that could connect them, we'll say that they're strongly connected.
