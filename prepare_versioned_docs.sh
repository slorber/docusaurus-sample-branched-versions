#!/usr/bin/env bash

#!/bin/bash

set -euxo pipefail

branches=("v2" "v1")

refs_to_fetch=()

for branch in "${branches[@]}"; do
  branch_ref="refs/heads/${branch}"
  if ! git rev-parse --verify --quiet "${branch_ref}" > /dev/null; then
    refs_to_fetch+=("${branch_ref}:refs/remotes/origin/${branch}")
  fi
done

if [[ "${#refs_to_fetch[@]}" -gt 0 ]]; then
  git fetch --no-tags origin "${refs_to_fetch[@]}"
fi

for branch in "${branches[@]}"; do
  worktree_dir="versioned_docs/version-${branch}"
  rm -rf "${worktree_dir}"
  git worktree add "${worktree_dir}" "origin/${branch}" --detach --force
done

printf '%s\n' "${branches[@]}" | jq -R . | jq -s . | tee versions.json
