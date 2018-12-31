---
title: "Templates"
weight: 5
---

- templates are useful for short-circuiting, and knowing when something is connected
- templates are also useful for short-circuiting and knowing when something is *not* connected
- this page looks really bad because non-rhomboidal boards aren't centered
  properly yet

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

Because it requires ten empty edge points, it's not very likely that this
template will come up if you're playing on an 11x11 board. Its area is so large
that intruding on it is easy, and it doesn't get a catchy name.

Still, it's very interesting to study, as none of the responses to template
intrusions are trivial.

<script type="application/json">
(

((dimensions 10x5)
 (rotation   Flat)
 (disabled (A1 B1 C1 D1 E1 I1 J1
             A2 B2 C2 D2       J2
               A3 B3
                A4))
 (stones ((Black G1))))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line E2 D3)
   (Line F2 E2)
   (Dot F2)
   (Line F2 G1)
   (Line D5 F3)
   (Line D3 D5)
   (Line F3 F2)
   (Line G3 F3)
   (Line G5 G3)
   (Line A5 G5)
   (Line C3 A5)
   (Line D3 C3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line I2 H2)
   (Line I3 I2)
   (Dot H2)
   (Line   D5 G5)
   (Line   F3 D5)
   (Line   G3 F3)
   (Line   G5 G3)
   (Line   H2 G3)
   (Line   J3 I3)
   (Line   J5 J3)
   (Line   G5 J5)
   (Line   I3 G5)
   (Bridge G1 H2)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line F2 G1)
   (Dot G3)
   (Dot D3)
   (Dot F2)
   (Line   H3 G3)
   (Line   H5 H3)
   (Line   E5 H5)
   (Line   G3 E5)
   (Bridge F2 G3)
   (Bridge D3 F2)
   (Line   D5 A5)
   (Line   D3 D5)
   (Line   C3 D3)
   (Line   A5 C3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line G1 G2)
   (Dot H3)
   (Dot E3)
   (Dot G2)
   (Line   I3 H3)
   (Line   I5 I3)
   (Line   F5 I5)
   (Line   H3 F5)
   (Bridge G2 H3)
   (Bridge E3 G2)
   (Line   E5 B5)
   (Line   E3 E5)
   (Line   D3 E3)
   (Line   B5 D3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Bridge G1 H2)
   (Dot I3)
   (Dot F3)
   (Dot H2)
   (Line   J3 I3)
   (Line   J5 J3)
   (Line   G5 J5)
   (Line   I3 G5)
   (Bridge H2 I3)
   (Bridge F3 H2)
   (Line   F5 C5)
   (Line   F3 F5)
   (Line   E3 F3)
   (Line   C5 E3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

)
</script>

You can see that it can reduce to two overlapping triples, or any one of three
large suspension bridges.

Clearly we want to focus on the points in the overlap of the two triple
templates, but it's clear how to respond to an intrusion in one of the points
spanned by the suspension bridges.

That leaves us with these points of interest:

<script type="application/json">
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star G5)
   (Star F5)
   (Star E5)
   (Star D5)
   (Star G3)
   (Star F3) 
   ))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
</script>

Some of them are not as interesting as others: an intrusion to the either of the
rightmost points has an obvious response.

<script type="application/json">
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Dot F3)
   (Line   F5 F3)
   (Line   C5 F5)
   (Line   E3 C5)
   (Line   F3 E3)
   (Bridge G1 F3)))
 (stones (
   (Black G1)
   (White G3)
   (White G5)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
</script>

And an intrusion to the bottom middle can by crossed by a small suspension bridge.

<script type="application/json">
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line G4 G5)
   (Line G4 F5)
   (Line D4 D5)
   (Line D4 C5)
   (Dot F3)
   (Bridge F3 G4)
   (Bridge F3 D4)
   (Bridge G1 F3)))
 (stones (
   (Black G1)
   (White E5)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
</script>

That leaves us with three actually interesting weak points, none of which have
an obvious response.

<script type="application/json">
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star F5)
   (Star D5)
   (Star F3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
</script>

Let's start at the top, shall we?

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star F5)
   (Star D5)
   (Star F3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones ((Black G1) (White F3)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black G1)
   (White F3)
   (Black D4)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Dot E2)
   (Bridge E2 G1)
   (Bridge E2 D4)))
 (stones (
   (Black G1)
   (White F3)
   (Black D4)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
)
</script>

This play creates a strong threat that white must respond to and, as you might
have guessed, sets up a ladder escape that will be used later on. It doesn't
matter where white blocks, and to prove it we'll continue as if every point in
the path were occupied.

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)
   ))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Bridge G1 H2)
   (Dot I3)
   (Dot G4)
   (Line   G4 G5)
   (Line   G4 F5)
   (Line   J5 G5)
   (Line   J3 J5)
   (Line   I3 J3)
   (Line   I3 G5)
   (Bridge H2 G4)
   (Bridge H2 I3)))
 (stones (
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star H3)
   (Star G5)))
 (stones (
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

)

</script>

There are two points where these paths overlap, and white is forced to play in
one of them. It doesn't matter which one: a ladder will form either way, and the
escape is ready.

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White H3)
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black G3)
   (White H3)
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F5)
   (Black G3)
   (White H3)
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black F4)
   (White F5)
   (Black G3)
   (White H3)
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line   G3 H2)
   (Bridge H2 G1)
   (Line F4 G3)
   (Line E5 C5)
   (Line E4 D5)
   (Line D4 C5)
   (Line F4 E5)
   (Line F4 D4)))
 (stones (
   (Black F4)
   (White F5)
   (Black G3)
   (White H3)
   (Black H2)
   (Black G1)
   (White F3)
   (Black D4)
   (White F1)
   (White F2)
   (White E3)
   (White D3)
   (White E2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
)
</script>

Now let's consider the next intrusion:

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star F5)
   (Star D5)
   (Star F3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones ((Black G1) (White D5)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones ((Black G1) (White D5) (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line J3 I3)
   (Line J5 J3)
   (Line G5 J5)
   (Line I3 G5)
   (Dot G4)
   (Dot I3)
   (Bridge H2 G1)
   (Bridge H2 I3)
   (Line   G4 G5)
   (Line   G4 F5)
   (Bridge H2 G4)))
 (stones (
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star G5)
   (Star H3)))
 (stones (
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
)
</script>

White has a choice of how to respond here, but either intrusion has the same
response, so we'll consider them together:

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line F4 F5)
   (Line F4 E5)
   (Dot F3)
   (Line   F3 F4)
   (Bridge G1 F3)
   (Dot G3)
   (Line   G3 F4)
   (Line   H2 G3)
   (Bridge G1 H2)))
 (stones (
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White G2)
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black F2)
   (White G2)
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F3)
   (Black F2)
   (White G2)
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black E3)
   (White F3)
   (Black F2)
   (White G2)
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line E3 G1)
   (Line F4 F5)
   (Line F4 E5)
   (Line E4 F4)
   (Dot E4)
   (Line E3 E4)
   (Dot C4)
   (Line   C4 C5)
   (Line   C4 B5)
   (Bridge E3 C4)))
 (stones (
   (Black E3)
   (White F3)
   (Black F2)
   (White G2)
   (Black F4)
   (White H3)
   (White G5)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

)
</script>

Hang on a minute. What if instead of one of those "forced" responses, white had
intruded on the initial bridge? Since white eventually has to intrude on it as a
forced move, and by that point black gets to ignore the intrusion, what if white
comes out swinging?

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

)
</script>

Well, it turns out it didn't help. White is still forced to defend here, just at
a different point. Black takes back initiative, and the rest of the play
proceeds identically.

<script type="application/json">

(

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White G3)
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black F2)
   (White G3)
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F3)
   (Black F2)
   (White G3)
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black E3)
   (White F3)
   (Black F2)
   (White G3)
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line E3 G1)
   (Line F4 F5)
   (Line F4 E5)
   (Dot E4)
   (Line F4 E4)
   (Dot C4)
   (Line   C4 C5)
   (Line   C4 B5)
   (Bridge E3 C4)
   (Line   E3 E4)))
 (stones (
   (Black E3)
   (White F3)
   (Black F2)
   (White G3)
   (Black F4)
   (White G5)
   (White H3)
   (Black H1)
   (White G2)
   (Black G1)
   (White D5)
   (Black H2)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
)
</script>

Alright. That leaves us with one final intrusion point, and we'll be done
proving that this template is valid.

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Star F5)
   (Star D5)
   (Star F3)))
 (stones ((Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Dot F3)
   (Line   F3 E4)
   (Bridge G1 F3)))
 (stones (
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations ((Line F2 G1) (Dot F2) (Bridge E4 F2)))
 (stones (
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations ((Star F2) (Star F3)))
 (stones (
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))
 
)
</script>

Once again, white has a choice of how to respond. They can take the high road:

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (annotations ((Star F2) (Star F3)))
 (stones (
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F2)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black G2)
   (White F2)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F3)
   (Black G2)
   (White F2)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black G3)
   (White F3)
   (Black G2)
   (White F2)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line G3 G1)
   (Dot F4)
   (Dot H4)
   (Line   H4 H5)
   (Line   H4 G5)
   (Bridge G3 H4)
   (Line   E4 E5)
   (Line   E4 D5)
   (Line   F4 E4)
   (Line   G3 F4)))
 (stones (
   (Black G3)
   (White F3)
   (Black G2)
   (White F2)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

)
</script>

Or the more interesting, but no more effective low road:

<script type="application/json">
(
((dimensions 10x5)
 (rotation   Flat)
 (annotations ((Star F2) (Star F3)))
 (stones (
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Line E4 E3)
   (Line E4 E5)
   (Line E4 D5)
   (Dot E3)
   (Line   E2 E3)
   (Line   E2 D3)
   (Bridge G1 E2)
   (Dot D3)
   (Line D5 D3)
   (Line A5 D5)
   (Line C3 A5)
   (Line D3 C3)))
 (stones (
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White D5)
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black E5)
   (White D5)
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (White E3)
   (Black E5)
   (White D5)
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (stones (
   (Black D3)
   (White E3)
   (Black E5)
   (White D5)
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

((dimensions 10x5)
 (rotation   Flat)
 (annotations (
   (Bridge E2 G1)
   (Line   D3 E2)
   (Line   E4 E5)
   (Line   D4 E4)
   (Dot D4)
   (Line D3 D4)
   (Dot B4)
   (Line   B4 B5)
   (Line   B4 A5)
   (Bridge D3 B4)))
 (stones (
   (Black D3)
   (White E3)
   (Black E5)
   (White D5)
   (Black E2)
   (White F3)
   (Black E4)
   (White F5)
   (Black G1)))
 (disabled (A1 B1 C1 D1 E1 I1 J1 A2 B2 C2 D2 J2 A3 B3 A4)))

)
</script>

And that's it. You now know how to respond to every single intrusion into the
single-stone fifth row ladder template.
