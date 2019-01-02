---
title: "Ladders"
weight: 3
---

A **ladder** is a common formation wherein one player repeatedly blocks the other,
forming two straight lines of stones:

<script type="application/json">
((dimensions 7x7)
 (moves (
   G6 D5
   E3 D1
   C4 B5
   C5 B7
   C6 C7
   D6 D7
   E6 E7
   F6 F7
   G7))
  (initial_stones 6))
</script>

The term is [borrowed from Go](https://en.wikipedia.org/wiki/Ladder_(Go)),
although in Hex, the formation actually looks like a ladder. Go "ladders" look
like staircases. This has always bothered me.

Anyway, ladders occur frequently in Hex games -- frequently enough that we'll
give them their own notation convention:

<script type="application/json">
((dimensions 7x7)
 (annotations (
   (Line F6 F7)
   (Line E6 E7)
   (Line D6 D7)
   (Line C7 G7)
   (Line G6 G7)
   (Line C6 G6)
   (Line C6 C7)))
 (stones (
   (Black G6) (White D5)
   (Black E3) (White D1)
   (Black C4) (White B5)
   (Black C5) (White B7)
   (Black C6))))
</script>

In this example black is the **attacker**, and white is the **defender**.

# Ladder basics

If you see a ladder forming, and you don't have an "escape piece," don't play
it.

<script type="application/json">
((dimensions 7x7)
 (moves (
   F1 D5
   E3 D1
   C4 B5
   C5 B7
   C6 C7
   D6 D7
   E6 E7
   F6 F7
   G6 G7))
  (initial_stones 6))
</script>

Blindly playing a ladder through is always better for your opponent than it is
for you. Instead, if you're faced with a situation like the above, be patient.
Take the fight elsewhere on the board, and hope that you'll be able to set up an
**escape** stone that you can use later.

# Ladder escapes

Something something most edge templates work.

# Ladder handling

The defender can change the height of a ladder -- this can be useful for
avoiding a ladder scape.

Changing ladder direction.

Ladder switchbacks are a thing.

This is a woefully incomplete article.
