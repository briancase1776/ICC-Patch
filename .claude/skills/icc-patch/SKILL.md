---
name: icc-patch
description: >-
  Patch icc-pipes pipes and icc-tee tees into a ring or a mesh over N
  seats, plain or through tees that also go back to the writer, and hand
  every seat a map of the ends it holds. The bay makes nothing but the
  map. What goes down the cables, and who sits where, is the caller's
  business.
---

# icc-patch

A patch is pipes that icc-pipes made and tees that icc-tee made, plugged
into a shape over N seats, and a map. A seat is a number. Which Claude
holds it is agreed outside this skill, like whose desk a cable runs to.

    /tmp/icc-patch-XXXXXXXX/patch    SHAPE N LANES, then one line per end
    /tmp/icc-patch-XXXXXXXX/made     SCRIPTS DIR per pipe and tee, in order

## Operations

    scripts/create SHAPE N [LANES]  make the pipes and tees SHAPE needs
                                    over N seats, LANES lanes each (even,
                                    default 2), print the patch's directory
    scripts/list                    one line per patch: DIR up|down SHAPE N LANES
    scripts/remove DIR              remove the tees, then the pipes, then DIR

create runs the create scripts in `$ICC_PIPES` and `$ICC_TEE`, by default
`../ICC-Pipes` and `../ICC-Tee` beside this repo. remove runs the remove
scripts create used. If a piece is missing, create makes nothing.

## Shapes

    ring      seats i and i+1 share a pipe, i on side 0, i+1 on side 1,
              around the end back to 0
    mesh      every two seats share a pipe, the lower seat on side 0
    tee-ring  seat i writes one end; a tee carries it to seat i+1 and
              back to seat i
    tee-mesh  seat i writes one end; a tee carries it to every seat,
              seat i too

Fewer seats, fewer cables, by the shape alone. A writer with one reader
gets a pipe, not a tee. ring 2 is one pipe. ring 1 is one pipe with seat 0
on both ends. mesh 1 is no pipe. tee-ring 1 is ring 1.

## The map

After the first line, one line per end a seat holds:

    SEAT SIDE DIR PEERS

Seat SEAT holds side SIDE of the pipe at DIR. PEERS is the seats on the
other side, comma separated. Pipes says what a side writes and reads.

- On a pipe two seats share, ring and mesh, what SEAT writes there
  reaches PEERS and what it reads there came from PEERS. Both ways.
- Through a tee, an end goes one way. The writer's end, side 0, sends to
  PEERS and reads nothing. A reader's end, side 1, receives from its one
  PEER and sends nowhere. Tee's SKILL.md says why.

    grep '^3 ' "$x/patch"                          every end seat 3 holds

    x=$(scripts/create mesh 4 6)
    e=$(awk '$1==0 && $2==0 && $4==2 {print $3}' "$x/patch")
    .../icc-frames/scripts/write "$e" 0 < photo.jpg          # seat 0 to 2
    e=$(awk '$1==2 && $2==1 && $4==0 {print $3}' "$x/patch")
    timeout 5 .../icc-frames/scripts/read "$e" 1 > photo.jpg  # seat 2 from 0

## Facts

- A patch is the sum of its parts. Every fact in Pipes' SKILL.md holds
  for every end, and every fact in Tee's for every copy. The bay adds
  nothing to them.
- Through a tee, an outlet nobody reads stalls the others once it fills.
  Read every outlet, or keep the payload inside one. Tee's SKILL.md has
  the numbers.
- A seat may sit in more than one patch. A ring and a mesh over the same
  seats is two patches.
- list says up when every pipe and tee says up. If one is down, the
  patch is down; remove it and create it again.
- Nothing holds a patch open. Its pipes and tees do their own holding.
  Remove one of them by hand and list says down.

## In Claude Code

Every Bash call is a fresh shell. The pipes and tees are their own
processes, as their skills say, so a patch outlives calls. Seats in one
session share the container and its /tmp; sessions do not, so no patch
crosses that line.
