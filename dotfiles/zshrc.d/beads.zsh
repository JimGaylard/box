# Beads task system — one DB since 2026-09-04, reached through the hub workspace.
# bd resolves its workspace from $PWD; pinning it here makes `bd` work from any directory
# and stops a bare `bd` from planting an embedded DB in whatever repo it was run in.
export BEADS_DIR="$HOME/workspace/tasks-beads/.beads"
