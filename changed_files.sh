#!/usr/bin/env bash

set -e

# Try to update the index before the diff. The native `git diff-files` command does not do that automatically...
{ git update-index --refresh || :; } > /dev/null 2>&1

git_exclude=""
if [[ "$1" == "true" ]]; then
  git_exclude="--exclude-standard"
fi

git diff-files --diff-filter=ACDMRTUX --name-only
git ls-files --others "$git_exclude"
