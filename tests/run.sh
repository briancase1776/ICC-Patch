#!/bin/sh
# Prove the bay: make each shape, see the map name the cables the shape says
# and no more, push a Frames payload bigger than one lane holds from a seat
# to its peers and read it back whole at every one, plain bytes back the
# other way, remove it, see nothing left.
set -eu
cd "$(dirname "$0")/.."
P=${ICC_PIPES:-../ICC-Pipes}/.claude/skills/icc-pipes/scripts
F=${ICC_FRAMES:-../ICC-Frames}/.claude/skills/icc-frames/scripts
T=${ICC_TEE:-../ICC-Tee}/.claude/skills/icc-tee/scripts
S=.claude/skills/icc-patch/scripts
end() { awk -v s="$1" -v i="$2" -v p="$3" \
  '$1==s && $2==i && ("," $4 ",") ~ ("," p ",") {print $3}' "$x/patch"; }
made() { [ "$(grep -c "$1" "$x/made")" -eq "$2" ]; }
"$S/create" 2>/dev/null && exit 1
"$S/create" star 3 2>/dev/null && exit 1
"$S/create" ring 0 2>/dev/null && exit 1
"$S/create" ring 3 3 2>/dev/null && exit 1
[ -z "$("$S/list")" ]
head -c 150000 /dev/urandom > in
trap 'for x in /tmp/icc-patch-*; do "$S/remove" "$x" 2>/dev/null || :; done; rm -f in out' EXIT
x=$("$S/create" ring 3 6)
"$S/list" | grep -qx "$x up ring 3 6"
made icc-pipes 3; made icc-tee 0
"$F/write" "$(end 2 0 0)" 0 < in
timeout 5 "$F/read" "$(end 0 1 2)" 1 > out; cmp in out
"$F/write" "$(end 0 1 2)" 1 < in
timeout 5 "$F/read" "$(end 2 0 0)" 0 > out; cmp in out
[ -z "$(end 0 0 2)" ]
"$S/remove" "$x"; [ ! -d "$x" ]
x=$("$S/create" ring 2); made icc-pipes 1; "$S/remove" "$x"
x=$("$S/create" ring 1); made icc-pipes 1
printf 'me' > "$(end 0 0 0)/0"; [ "$(timeout 1 cat "$(end 0 1 0)/0")" = me ]
"$S/remove" "$x"
x=$("$S/create" mesh 4); made icc-pipes 6; made icc-tee 0
[ "$(grep -c '^3 ' "$x/patch")" -eq 3 ]
printf 'hi' > "$(end 3 1 1)/1"; [ "$(timeout 1 cat "$(end 1 0 3)/1")" = hi ]
"$S/remove" "$x"
x=$("$S/create" mesh 1); made icc-pipes 0; "$S/remove" "$x"
x=$("$S/create" tee-mesh 3 6)
"$S/list" | grep -qx "$x up tee-mesh 3 6"
made icc-pipes 12; made icc-tee 3
"$F/write" "$(end 1 0 2)" 0 < in
for r in 0 1 2; do timeout 5 "$F/read" "$(end $r 1 1)" 1 > out; cmp in out; done
"$S/remove" "$x"
x=$("$S/create" tee-ring 3)
made icc-pipes 9; made icc-tee 3
printf 'round' > "$(end 1 0 2)/0"
for r in 1 2; do [ "$(timeout 1 cat "$(end $r 1 1)/0")" = round ]; done
[ -z "$(end 0 1 1)" ]
m=$(cut -d' ' -f2 "$x/made")
"$S/remove" "$x"; [ ! -d "$x" ]
for p in $m; do [ ! -e "$p" ]; done
x=$("$S/create" tee-ring 1); made icc-pipes 1; made icc-tee 0; "$S/remove" "$x"
[ -z "$("$S/list")" ]
rm -f in out
trap - EXIT
echo ok
