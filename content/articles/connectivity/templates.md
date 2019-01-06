---
title: "Edge Templates"
weight: 5
---

Take a look at this board. It's white's turn to play. Where is black weakest?

<script type="application/json">
((dimensions 7x7)
 (annotations ())
 (stones ((Black C1))))
</script>

Edge templates are shortcuts that you can use when analyzing connectivity.
Recognizing edge templates in play allows you to quickly short-circuit path
analysis when identifying weak points.

Templates are shortcuts for recognizing when pieces are connected, and for
quickly responding when a strongly connected piece is threatened.

# Third row templates

## The Trapezoid

The most useful template to recognize is the following one:

<script type="application/json">
((dimensions 4x3)
 (rotation   Flat)
 (annotations (
   (Dot D2)
   (Dot B2)
   (Bridge C1 D2)
   (Line   B2 A3)
   (Line   B2 B3)
   (Line   D2 C3)
   (Line   D2 D3)
   (Line   C1 B2)))
 (stones ((Black C1)))
 (disabled (A1 B1 A2)))
</script>

We'll call this template the trapezoid. You might see it referred to as "the
ziggurat" elsewhere.

This template comes up so frequently when analyzing connectivity that we'll use
a separate notation for it:

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

## The Snub Trapezoid

A trapezoid with a corner taken out is not connected -- unless both the top
pieces are occupied.

<script type="application/json">
((dimensions 4x3)
 (rotation   Flat)
 (annotations (
   (Dot B3)
   (Line   D2 D1)
   (Bridge C1 B3)
   (Dot D2)
   (Line D2 C3)
   (Line D2 D3)))
 (stones (
   (Black C1)
   (Black D1)
   (White A3)))
 (disabled (A1 B1 A2)))
</script>

## The Small Suspension Bridge

The small suspension bridge consists of two bridges that "span" over a white
piece, supported by two triangular pylons. It doesn't come up as frequently as
an edge template as the trapezoid, but it can be useful to recognize as an an
interior template. More on that later.

<script type="application/json">
((dimensions 5x3)
 (rotation   Flat)
 (annotations (
   (Dot E2)
   (Dot B2)
   (Bridge d1 e2)
   (Line b2 a3)
   (Line b2 b3)
   (Line e2 d3)
   (Line e2 e3)
   (Bridge d1 b2)))
 (stones ((Black D1) (White C3)))
 (disabled (A1 B1 A2)))
</script>

# Fourth row templates

## The Large Suspension Bridge

This symmetric template consists of two bridges spanning a white piece,
supported by larger trapezoidal pylons. It requires eight empty points along the
edge, though, so it doesn't occur as frequently as the other single-stone
fourth-row edge template.

<script type="application/json">
((dimensions 8x4)
 (rotation   Flat)
 (annotations (
    (Dot G2)
    (Dot D2)
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

## The Triple

The triple only requires seven edge pieces, so it shows up more frequently.

<script type="application/json">
(
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
    (Dot F2)
    (Dot D2)
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
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
   (Dot F3)
   (Dot C3)
   (Dot E2)
   (Line   E2 E1)
   (Line   F3 F4)
   (Line   F3 E4)
   (Bridge E2 F3)
   (Line   C4 C3)
   (Line   C3 B4)
   (Bridge E2 C3)))
 (stones ((Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))
)
</script>

This template consists of three separate paths to the edge, and there is no one
point where all three paths overlap. Any stone that breaks two of the paths
always leaves a third option: the single point at which the first two paths
overlap happens to be exactly the point that is spanned by a small suspension
bridge.

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
    (Line E1 E2)
    (Dot C3)
    (Dot F3)
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

There is another response to this intrusion, though, that does not make use of
another edge template.

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3))
 (moves (e1 d4 c3))
 (initial_stones 2))
</script>

Why does that work?

This move serves two purposes: it strengthens the left-hand path, forcing white
to block it. But it *also* sets up a ladder-escape that makes the right-hand
path viable again.

White must block in response, which cuts off the left-hand path, leaving the
board in this state:

<script type="application/json">
((dimensions 7x4)
 (rotation   Flat)
 (annotations (
    (Dot F2)
    (Line f2 g2)
    (Line g2 g4)
    (Line g4 d4)
    (Line d4 f2)
    (Bridge e1 f2)))
 (stones ((Black E1) (White D4) (Black C3) (White D2)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))
</script>

Now what? It's not obvious that the right-hand path is viable: after all,
there's a white piece inside that trapezoid. Doesn't that mean that piece isn't
connected?

No! It just means that it can't be connected within that trapezoid. But it can
be connected if we leave the trapezoid borders -- which we will do.

Black bridges into the trapezoid, and play continues.

<script type="application/json">
(
((dimensions 7x4)
 (rotation   Flat)
 (stones (
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

((dimensions 7x4)
 (rotation   Flat)
 (annotations (
   (Bridge E1 F2)
   (Dot E4)
   (Dot G3)
   (Line   G3 G4)
   (Line   G3 F4)
   (Bridge F2 G3)
   (Bridge F2 E4)))
 (stones (
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

((dimensions 7x4)
 (rotation   Flat)
 (annotations ((Star F3)))
 (stones (
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

)
</script>

White is forced to play in the intersection of those two paths, which sets up a
trivial ladder to the left.

<script type="application/json">
(

((dimensions 7x4)
 (rotation   Flat)
 (stones (
   (White F3)
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

((dimensions 7x4)
 (rotation   Flat)
 (stones (
   (Black E3)
   (White F3)
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

((dimensions 7x4)
 (rotation   Flat)
 (stones (
   (White E4)
   (Black E3)
   (White F3)
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

((dimensions 7x4)
 (rotation   Flat)
 (stones (
   (Black D3)
   (White E4)
   (Black E3)
   (White F3)
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

((dimensions 7x4)
 (rotation   Flat)
 (annotations ((Line C3 B4) (Line C3 C4) (Line C3 E3) (Line E3 F2) (Bridge E1 F2)))
 (stones (
   (Black D3)
   (White E4)
   (Black E3)
   (White F3)
   (Black F2)
   (White D2)
   (Black C3)
   (White D4)
   (Black E1)))
 (disabled (A1 B1 C1 D1 G1 A2 B2 A3)))

)

</script>

And that's it.

Why would you ever want to use this alternate intrusion response? I don't know.

# Fifth-row templates

There is one edge template for a single stone on the fifth row.

<script type="application/json">
((dimensions 10x5)
 (rotation   Flat)
 (disabled (A1 B1 C1 D1 E1 I1 J1
             A2 B2 C2 D2       J2
               A3 B3
                A4))
 (stones ((Black G1))))
 </script>

Because it requires ten empty edge points, it's not very likely that this
template will come up if you're playing on an 11x11 board. Its area is so large
that intruding on it is easy, and it doesn't get a catchy name. The shape of the
template is also very large and irregular, so it's hard to visually recognize it
in play.

Still, it's very interesting to study, as it has many template intrusions that
require nontrivial responses. But because it's so involved, the proof for this
template is on [a separate page]({{< ref
"/articles/connectivity/fifth-row-edge-template" >}}).
