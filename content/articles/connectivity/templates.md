---
title: "Templates"
weight: 5
---

- templates are useful for short-circuiting, and knowing when something is connected
- templates are also useful for short-circuiting and knowing when something is *not* connected
- this page looks really bad because I can't draw non-rhomboidal boards yet

Templates are shortcuts for recognizing when pieces are connected, and for quickly responding when a strongly connected piece is threatened.

The most useful template to recognize is the following one:

<script type="application/json">
((dimensions 4x3)
 (rotation   Flat)
 (annotations (
   (Bridge C1 D2)
   (Line   B2 A3)
   (Line   B2 B3)
   (Line   D2 C3)
   (Line   D2 D3)
   (Line   C1 B2)))
 (stones ((Black C1)))
 (disabled (A1 B1 A2)))
</script>

We'll call this template the trapezoid.

This template comes up so frequently when analyzing connectivity that we'll use a separate notation for it:

<script type="application/json">
((dimensions 4x3)
 (rotation   Flat)
 (annotations (
   (Line   C1 D1)
   (Line   D1 D3)
   (Line   D3 A3)
   (Line   A3 C1)))
 (stones ((Black C1)))
 (disabled (A1 B1 A2)))
</script>

# Other third-row templates

There's another third-row template that comes up less often.

<script type="application/json">
((dimensions 5x3)
 (rotation   Flat)
 (annotations (
    (Bridge d1 e2)
    (Line b2 a3)
    (Line b2 b3)
    (Line e2 d3)
    (Line e2 e3)
    (Bridge d1 b2)))
 (stones ((Black D1) (White C3)))
 (disabled (A1 B1 A2)))
</script>

This comes up less often as an edge template, but it can be useful to recognize it as an interior template. More on that later.

# Fourth row templates

The simplest fourth row template is this one:

<script type="application/json">
((dimensions 8x4)
 (rotation   Flat)
 (annotations (
    (Line c2 d2)
    (Line d2 d4)
    (Line d4 a4)
    (Line a4 c2)
    (Line g2 h2)
    (Line h2 h4)
    (Line h4 e4)
    (Line e4 g2)
    (Bridge f1 d2)
    (Bridge f1 g2)))
 (stones ((Black F1) (White E3)))
 (disabled (A1 B1 C1 D1 H1 A2 B2 A3)))
</script>

Two bridges to trapezoids.

But due to the smaller size, this one is more common:

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
    (Line c2 d2)
    (Line d2 d4)
    (Line d4 a4)
    (Line a4 c2)
    (Line f2 g2)
    (Line g2 g4)
    (Line g4 d4)
    (Line d4 f2)
    (Line e1 d2)
    (Bridge e1 f2)))
 (stones ((Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))
</script>

It's not obvious why this template works. The other templates we've seen have consisted of two completely disjoint paths to the edge, and the right response to a threat to one of them has been playing in the other.

But this one actually consists of three -- though I haven't drawn the third.

But in this template, while we can see the left and the right path, there is an intersection -- a weak point. A play there threatens both the left and the right path at the same time. So how should black respond?

Well, the obvious thing is to play here and reduce it to a smaller template.

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
    (Bridge e2 f3)
    (Line c3 b4)
    (Line c3 c4)
    (Line f3 e4)
    (Line f3 f4)
    (Bridge e2 c3)
    ))
 (stones ((Black E1) (White D4) (Black E2)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))
</script>

You can actually respond in any of the inflection points in that template and succeed. Why would you want to do that? Well, why not?

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3))
 (moves (e1 d4 c3))
 (initial_stones 3))
</script>

Why does that work?

This move serves two purposes: it strengthens the left-hand path, forcing white to block it. But it *also* sets up a ladder-escape that makes the right-hand path viable.

White must block in response, which cuts off the left-hand path, leaving the board in this state:

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
    (Line f2 g2)
    (Line g2 g4)
    (Line g4 d4)
    (Line d4 f2)
    (Bridge e1 f2)))
 (stones ((Black E1) (White D4) (Black C3) (White D2)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))
</script>

Now what? It's not obvious that the right-hand path is viable: after all, there's a white piece inside that trapezoid. Doesn't that mean that piece isn't connected?

No! It just means that it can't be connected within that trapezoid. But it can be connected if we leave the trapezoid borders -- which we will do.

Black bridges into the trapezoid, and play continues.

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3))
 (moves (e1 d4 c3 d2 f2 f3 e3 e4 d3))
 (initial_stones 4))
</script>

It's a trivial ladder, but it's a ladder escape nonetheless.
