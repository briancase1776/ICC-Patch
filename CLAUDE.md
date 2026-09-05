# ICC-Patch

A Claude Code skill that patches ICC-Pipes pipes and ICC-Tee tees into a
shape. That is the whole project.

Think of a patch bay. A box of cables and fittings, a row of seats, and a
plan on paper: seat 0 to seat 1, seat 1 to seat 2, and so on around. The
bay pushes the plugs in and hands each seat the plan. It has no idea what
goes down the cables. This skill is the bay. Nothing more.

## Where this sits

    what the bytes mean                someone else's, above this
    slice, carry, reassemble           ICC-Frames, beside this: it works
                                       any end the bay hands out
    plug pipes and tees into a shape   this project
    copy one pipe onto others          ICC-Tee, below this
    the lane itself                    ICC-Pipes, below this

Pipes does not know what is plugged into it. Tee copies lanes. Frames does
not know what the bytes are. The bay knows none of that: it runs their
create scripts, in a shape, and writes down which end went to which seat.

## What this is

- A **patch**: the pipes and tees one shape needs over N seats, made by
  their own skills, and a **map** saying which end each seat holds and
  which seats are on the other side of it.
- The shapes are ring and mesh, each plain or through tees that also go
  back to the writer. Four shapes. Fewer seats means fewer cables, by the
  shape alone: a writer with one reader gets a pipe, not a tee.
- The skill covers creating, listing, and removing patches. Using one is
  reading the map and holding the ends it names. Nothing else.

## What this is not

Out of scope. Do not build, stub, or "leave room for" any of these:

- **The wire.** Making, holding, or removing a pipe. That is Pipes. The
  bay runs Pipes' scripts; it never copies or reimplements them.
- **The fitting.** Copying lanes. That is Tee. Same rule.
- **Fan-in.** Merging what many seats write onto one end is a fitting,
  and belongs in a fitting's skill beside Tee. Here a reader holds one
  end per writer.
- **The payload.** Slicing, counts, frames. That is Frames.
- **The content.** What the bytes mean. Formats, protocols, envelopes.
- **Who sits where.** Which Claude is seat 3, how it learns that, how it
  finds the map. Discovery, registries, naming.
- **What a seat does.** Sending, waiting, polling, forwarding around a
  ring, hop counts, tokens, turn taking. A seat holds ends; what it does
  with them is its business.
- **New shapes on demand.** A shape is a few lines in create. Shape
  files, graph input, a wiring language. No.
- Anything Pipes and Tee list as out of scope for themselves: routing,
  persistence, replay, liveness, auth, retries, queues, other transports,
  config, plugins, options.

If a request touches any of the above, stop and say it is out of scope.
Before adding anything, ask: is this a cable, a fitting, what goes through
them, or the bay that plugs them together in a shape and writes down where
each plug went? Only the last one belongs here.

## Depends on ICC-Pipes and ICC-Tee, proven through ICC-Frames

The bay makes nothing but the map. create runs Pipes' and Tee's create
scripts from sibling checkouts, `$ICC_PIPES` and `$ICC_TEE`, by default
`../ICC-Pipes` and `../ICC-Tee` beside this repo, and remove runs their
remove scripts. Tests push a Frames payload through what the bay made,
from another sibling. Do not vendor any of them into this repo.

Do not duplicate their documentation. A fact about lanes is Pipes'; about
copies, Tee's; about payloads, Frames'. If one of them is missing a fact,
that is a change there, not a paragraph here.

## Testing

A test harness is allowed **only to prove the bay works**: make each
shape, see the map name the cables the shape says and no more, push a
Frames payload bigger than one lane holds from a seat to its peers and
read it back whole at every one, plain bytes back the other way, remove
it, see nothing left. The harness must not grow into a client, protocol,
or example app. If a test needs more than a few lines of setup, the bay
is too complicated, not the test.

## Rules

- **KISS.** One way to do each thing. Prefer the OS primitive over a
  library. Prefer a shell script over a program. Prefer no dependency
  over one.
- **Small.** If a file is getting long, you are adding scope, not
  features.
- **No speculative work.** Build what is asked, not what might be asked
  later.
- **No abstraction until there are two real callers.**
- **Facts, not recipes.** SKILL.md says what the map means. It does not
  tell a seat when to write, how to wait, or what to do with what it
  reads.
- **The shape decides the cables.** Nothing else does. No knob picks a
  tee over a pipe; the reader count does.
- **Never look at the bytes.** No script here reads a lane.

## Layout

```
.claude/skills/icc-patch/SKILL.md     the skill definition Claude Code loads
.claude/skills/icc-patch/scripts/     create, list, remove. One script each.
tests/                                the minimal harness described above
```

Do not add directories without a reason that fits the scope above.
