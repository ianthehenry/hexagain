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

If we annotate this situation, we can see that there are two disjoint paths
between the stones, each of which require a single stone to become connected.

<script type="application/json">
((dimensions 6x6)
 (annotations (
   (Dot C4)
   (Line C4 D4)
   (Line C3 C4)
   (Dot D3)
   (Line D3 D4)
   (Line C3 D3)))
 (stones (
   (Black C3)
   (Black D4))))
</script>

But since this pattern comes up so often, we'll abbreviate this with the
following notation instead:

<script type="application/json">
((dimensions 6x6)
 (stones ((Black C3) (Black D4)))
 (annotations ((Bridge C3 D4))))
</script>
