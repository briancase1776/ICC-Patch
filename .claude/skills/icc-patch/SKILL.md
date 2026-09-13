---
name: icc-patch
description: >-
  Patch icc-pipes pipes, icc-tee tees and icc-merge merges into a star,
  a ring or a mesh over N seats, with the parent in a place in it or
  only reading it, and hand every seat a map of the ends it holds. The
  bay makes nothing but the map. What goes down the cables, and who
  sits where, is the caller's business.
---

# icc-patch

A patch is pipes that icc-pipes made, tees that icc-tee made and merges
that icc-merge made, plugged into a shape over N seats, and a map. A seat
is a number. Which Claude holds it is agreed outside this skill, like
whose desk a cable runs to. The parent is seat p.

    /tmp/icc-patch-XXXXXXXX/patch    SHAPE N LANES, then one line per end
    /tmp/icc-patch-XXXXXXXX/made     SCRIPTS DIR per pipe and fitting, in order

## Operations

    scripts/create SHAPE N [LANES]  make the pipes and fittings SHAPE needs
                                    over N seats, LANES lanes each (even,
                                    default 2), print the patch's directory
    scripts/list                    one line per patch: DIR up|down SHAPE N LANES
    scripts/remove DIR              remove the fittings, then the pipes,
                                    then DIR

create runs the create scripts in `$ICC_PIPES`, `$ICC_TEE` and
`$ICC_MERGE`, by default `../ICC-Pipes`, `../ICC-Tee` and `../ICC-Merge`
beside this repo. remove runs the remove scripts create used. If a piece
is missing, create makes nothing.

## Shapes

Three shapes, and three ways the parent can stand to one.

    bare     the seats and nothing else
    -p       p is in on it: it reads what the shape carries, and writes
             into it
    -p-ro    the same shape, and p only reads. It writes nowhere

A suffix means the same thing on every shape it is spelled on. Handing p
what the seats say means copying a lane, and a lane is copied by a tee,
so a parented ring's hops are tees where a bare ring's are pipes. The
fitting is the shape, not an expense. A star has no bare form, since a
star is nothing between the seats and every cable in one is p's. That
leaves eight.

    star-p     seat i shares a pipe with p, i on side 0, p on side 1.
               Nothing joins the seats to each other
    star-p-ro  nothing joins the seats. Every seat writes one end into a
               merge, and p reads what comes out of it
    ring       seat i shares a pipe with seat i+1, i on side 0, i+1 on
               side 1, around the end back to 0
    ring-p     ring, and each hop is a tee: one outlet to the next seat,
               one to a merge that p reads. p writes one end, and a tee
               hands it to a read end of its own at every seat, so a
               seat holds three ends: its write end, a read end from the
               seat before it, and a read end from p
    ring-p-ro  the same hops and the same merge, and no tee from p, so a
               seat holds two ends and p holds one
    mesh       a merge and a tee in the middle. Every seat writes one
               end into the merge; the tee hands what comes out to every
               seat's read end, the writer's too
    mesh-p     the same mesh, with p on it like any other seat
    mesh-p-ro  the same mesh among the seats, and the middle tee hands p
               an outlet of its own. p is on no inlet of the merge

N counts seats other than p. Fewer seats means fewer cables and never
fewer fittings: a mesh is a merge and a tee over one seat as over forty,
and a parented ring has a tee at every hop and a merge at p however few
hops there are. Only a bare ring comes out smaller, having no fitting to
keep: ring 2 is the one pipe seats 0 and 1 share, since the hop out and
the hop back are the same two ways of it, and ring 1 is one pipe with
seat 0 on both ends, what it writes on one side coming back on the
other.

## The map

After the first line, one line per end a seat holds:

    SEAT SIDE DIR PEERS

Seat SEAT holds side SIDE of the pipe at DIR. PEERS is the seats on the
other side, comma separated. Pipes says what a side writes and reads. A
seat can hold more than one end on a side — on a -p-ro it holds its
place in the shape and a write end to p besides — so an end is named by
its DIR, not by its seat and side.

- A DIR on two seats' lines is a pipe those two share: what each writes
  there reaches the other and what it reads there came from the other,
  both ways. On a star-p every end is one of these, so p holds one end
  per seat and knows which seat it is talking to. ring 1 is the one
  shape where both lines are the same seat's: seat 0 holds both sides.
- A seat is in its own PEERS on a mesh of three or more, because the
  merge and the tee reach every seat, the writer included. Filtering
  PEERS for the others means taking your own number out.
- A DIR on one line only is through a fitting, and goes one way. A write
  end, side 0, sends to PEERS and reads nothing. A read end, side 1,
  receives from PEERS and sends nowhere. Tee's and Merge's SKILL.md say
  why. No pipe the map names has two writers on it, in any shape, so the
  line is the whole of it: two names, both ways; one name, one way. A
  merge's outlet has one writer per inlet, and the map names it nowhere.
- A -p-ro gives p one read end and no other, and the merge behind it
  does not say which seat wrote. A parent that must know who is talking
  wants star-p, where every seat has an end of its own.

    grep '^3 ' "$x/patch"                          every end seat 3 holds

    x=$(scripts/create mesh 4 6)
    e=$(awk '$1==0 && $2==0 {print $3}' "$x/patch")  # seat 0's write end
    .../icc-frames/scripts/write "$e" 0 < photo.jpg
    e=$(awk '$1==2 && $2==1 {print $3}' "$x/patch")  # seat 2's read end
    timeout 5 .../icc-frames/scripts/read "$e" 1 > photo.jpg

## Facts

- A patch is the sum of its parts. Every fact in Pipes' SKILL.md holds
  for every end, and every fact in Tee's and Merge's for every copy. The
  bay adds nothing to them.
- On a read end with more than one PEER, nothing says which one a byte
  came from, and two writing at once interleave, as Pipes, Tee and Merge
  say. Whose turn it is, is agreed above this skill.
- Where writes meet is the merge: the one in the middle of a mesh, the
  one p reads on a parented ring or a star-p-ro. Two seats writing at
  once interleave there, as Merge says, and nowhere else do two writers
  share a pipe. star-p and a bare ring have no fittings and nothing to
  meet at.
- On a mesh the tee hands a writer its own words back, so a seat can see
  its own go past the merge: the tee puts each chunk on every outlet
  before it reads the next, as Tee says, so nothing written after them
  can come before them at any seat. On a parented ring nothing a seat
  writes comes back to that seat, and nothing p writes comes back to p,
  so there is no such moment — except over one seat, where the hop tee
  goes round to the only seat there is. ring 1 is the other place a
  seat hears itself: it holds both ends of one pipe. On a mesh-p-ro p
  never hears its own, having written nothing.
- Whose turn it is, and whatever the seats leave in DIR to agree it, is
  theirs; remove takes DIR whole.
- Through fittings, a seat that never reads stalls every writer once its
  end fills. Read every end, or keep the payload inside one. How much
  that is, is how many pipes lie between a write end and a read end,
  which only the bay knows: a star-p or a bare ring one, a star-p-ro or
  a parented ring's hop two, a mesh three, and a seat's word on round a
  parented ring to p three. What one pipe holds is Pipes'
  fact, and Tee's and Merge's SKILL.md say what a fitting adds. It is
  not one number: measured on a mesh, 208K, 224K and 256K each went both
  ways on different runs.
- A seat may sit in more than one patch. A ring and a mesh over the same
  seats is two patches.
- list says up when every pipe and fitting says up. If one is down, the
  patch is down; remove it and create it again.
- Nothing holds a patch open. Its pipes and fittings do their own
  holding. Remove one of them by hand and list says down.
- The scripts are bash, not sh. Run one by its path and let its first
  line pick the interpreter; `sh scripts/create` overrides it.

## In Claude Code

Every Bash call is a fresh shell. The pipes and fittings are their own
processes, as their skills say, so a patch outlives calls. Seats in one
session share the container and its /tmp; sessions do not, so no patch
crosses that line.
