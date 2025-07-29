#!/bin/bash
set -e

#Then you can chain your workflow in sync_subtrees.sh:

./scripts/add_remotes.sh
./scripts/pull_subtrees.sh # if needed
./scripts/commit_all.sh
./scripts/push_subtrees.sh


