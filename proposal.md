# Proposal: a many-to-many fitting

A fitting that takes N inlets and M outlets, so that everything written
into any inlet arrives on every outlet, in one order that every outlet
agrees on. Working name ICC-Manifold, after the plumbing part; ICC-Bus
would do. Its own repo, beside Pipes, Tee and Merge.

This is not a new capability. It is running in every mesh ICC-Patch has
ever made. It has no owner, no name, no documentation and, until
2026-09-13, no test.

## What was found

ICC-Patch's create assembles it by hand, three lines in the middle of a
shape:

    pipe; b=$p
    merge "$b" 0 $ins
    tee   "$b" 0 $outs

A pipe, with a merge strapped to one end and a tee to the other. Three
of the eight shapes build it, and two more build half of it for the
parent's collect and broadcast.

Three things follow from nobody owning it.

**The guarantee is stated by a layer with no standing to state it.** The
useful property of a mesh is that every seat reads the same bytes in the
same order. The only place that is written down is ICC-Patch's own
SKILL.md:

> the tee puts each chunk on every outlet before it reads the next, as
> Tee says, so nothing written after them can come before them at any
> seat

ICC-Patch's own CLAUDE.md forbids exactly this:

> Do not duplicate their documentation. A fact about lanes is Pipes';
> about copies, Tee's and Merge's; about payloads, Frames'. If one of
> them is missing a fact, that is a change there, not a paragraph here.

The fact is about neither copy on its own. It is about the pair, and the
pair is nobody's.

**The middle pipe is reachable.** `b` is an ordinary ICC-Pipes pipe in
/tmp, with its own directory, its own lanes and its own hold. It is
named in the patch's `made` file. Anything that can read the map can
open it, hold it, or remove it, and the patch says `down` afterwards
with no account of why.

**Teardown order leaked upward.** ICC-Patch's remove carries this:

> Reverse is only the right order because create appends a fitting after
> the pipes it is attached to; move a fitting earlier in create and this
> walk pulls a pipe out from under a live copier.

That is the bay holding a fitting's assembly order. A fitting owns its
own teardown.

## What the fitting is

Inlets, outlets, and one pipe between them that nothing outside ever
sees.

    create DST... SIDE SRC...      inlets, outlets, lanes
    list
    remove DIR

It degenerates at both edges, which is why the two existing repos cover
them and nothing covers the middle: one outlet and it is a merge, one
inlet and it is a tee. Those stay as they are. Neither is wrong; neither
can speak for the pair.

## How it is built

By running Pipes', Merge's and Tee's create scripts. Nothing else.

    b=$("$P/create" "$lanes")
    m=$("$M/create" "$b" "$side" "$ins")
    t=$("$T/create" "$b" "$side" "$outs")

No new copier machinery. Merge's `cat` per inlet lane and Tee's `tee(1)`
per lane already carry every trap, every fd ordering rule and every
signal-race fix those two repos earned. Writing them again here would be
the same mistake one layer down.

A rejected alternative, recorded so it is not proposed again: join the
copiers through an anonymous kernel pipe, so there is no middle pipe on
disk at all. It works -- three `cat`s and one `tee(1)` in a shell
pipeline, both outlets identical, all four copiers still identifiable by
argv. It is rejected because Merge needs a DST path and Tee needs a SRC
path, so taking it means writing our own copiers. The middle pipe costs
one process and about 115 KB. That is the cheaper of the two.

## What it must state, and what certifies each part

MEASURED 2026-09-13, through the real scripts, two inlets writing 200
lines each into one manifold, 1600 bytes compared at each of two
outlets: identical.

    a001a002b001b002b003b004b005b006b007b008b009b010...

- **One order at every outlet.** Everything crosses the middle pipe
  before the tee fans it, so every outlet receives that pipe's byte
  order. Measured above.
- **Why it holds**, which is the part worth writing down: Tee's SKILL.md
  already names the precondition, *"holds while the tee is the only
  writer on that outlet lane. Put a second writer on it and both streams
  are torn, in pieces neither one chose."* The middle pipe is what makes
  the single tee the only writer. It is not an implementation detail. It
  is the guarantee.
- **A writer's own bytes come back**, if its inlet and one of the
  outlets belong to the same party. This is what a mesh seat sees.
- **Between inlets nothing holds.** Merge's SKILL.md: *"a copier writes
  whatever one read of its inlet lane returned, and where that falls
  against another inlet's is not promised."* Two parties writing a
  Frames payload at once tear both. The manifold inherits this and must
  say so rather than let it be found.
- **One stalled outlet stalls every inlet**, once the lanes fill.
- **An inlet that is also an outlet** is refused, as Tee refuses DST as
  SRC.

UNVERIFIED, stated rather than buried. The negative case -- that without
the middle pipe two readers can disagree -- rests on Tee's contract
above, not on a measurement. It was observed once in a raw `tee(1)`
harness (two writers, divergence at byte 1368 of 3000) and then did NOT
reproduce through ICC-Tee in eight attempts on this box, including with
writes well past PIPE_BUF. It is a race, and its not firing on demand is
the reason it is dangerous rather than a reason to doubt it. What would
settle it: a run on a loaded box with more inlets, or a deliberate delay
injected between a tee's two outlet writes. Until then the design rests
on Tee's stated precondition, which is enough to build on and not enough
to call measured.

## The test suite

The point of the repo. Each pins one line above:

1. Identical byte order at every outlet, N inlets writing at once.
2. A Frames payload in one inlet, read whole at every outlet.
3. A writer's own bytes returning when it holds an inlet and an outlet.
4. Concurrent Frames writes tearing, as Merge says -- so the caveat is
   demonstrated, not just claimed.
5. A stalled outlet stalling the inlets.
6. An inlet that is also an outlet, refused.
7. Teardown with copiers live, and nothing left behind.
8. The negative case, run and reported honestly whether or not it fires.

## What it changes in ICC-Patch

`busof` goes, and with it the only place the bay makes a pipe it then
hides inside a fitting. `mesh`, `mesh-p` and `mesh-p-ro` each become one
manifold. The parent's collect on `ring-p`, `ring-p-ro` and
`star-p-ro` becomes a manifold with one outlet; the broadcast on
`ring-p`, a manifold with one inlet. `made` names one piece where it
named three. Remove's comment about reverse order can go, because the
order it protects moves inside the fitting. The SKILL.md paragraph
quoted at the top moves out, to the repo allowed to say it.

## What it is not

- **A router.** No inlet chooses an outlet. Everything goes everywhere.
  A partition is ICC-Switch's question, and its README argues it is a
  party's job anyway.
- **A framer.** It copies lanes. What the bytes mean is Frames', and
  above.
- **A queue.** Nothing is kept. Everything Pipes says about a full lane
  holds.
- **A replacement for Tee or Merge.** They are correct as they stand and
  this is built out of them.

## The bar

ICC-Switch holds a name open and states the test for opening it:

> Something has to want a partition that a party cannot do for itself,
> and there has to be a second caller for it.

That test is for building something new. This is not new, which is the
whole argument: it exists, it is in use, it carries a guarantee other
work depends on, and it is unowned. The cost of leaving it where it is
has already been paid once, in a week of auditing ICC and Moot over a
wire that nothing defined.

Second caller, stated honestly: within ICC-Patch there are three uses
(the mesh middle, the parent's collect, the parent's broadcast). Outside
it, Moot is the candidate and this proposal does not claim to know. If
one caller in one repo is not enough, that is a fair ruling, and the
answer is then a revision to Tee and Merge that lets one of them state
the pair's guarantee -- which neither can, since neither is the pair.

## Open

- The name.
- Whether the parent's collect and broadcast should use it, or stay as a
  bare merge and a bare tee with their pipes made by the bay.
- Who creates the repo. This session's scope is `icc-patch`.

## Where this came from

Raised 2026-09-13 while correcting the shapes in ICC-Patch, after a
previous assistant built the composite inline rather than as a fitting,
and the shapes were re-cut around it. The finding is the assembly, not
the shapes.

