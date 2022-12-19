#!/usr/bin/env bash

set -e

cmd="'$GITHUB_ACTION_PATH/changed_files.sh'"

if [[ "$INPUT_EXCLUDE_IGNORED" == "true" ]]; then
  cmd+=" true"
fi

if [[ "$INPUT_RETURN_PIPE" != "true" ]]; then
  result=$(eval "$cmd")

  eof=$(openssl rand -hex 16)
  echo "changed-files<<$eof" >> $GITHUB_OUTPUT
  echo "$result" >> $GITHUB_OUTPUT
  echo "$eof" >> $GITHUB_OUTPUT
  exit 0
fi

echo "pipe=$cmd" >> "$GITHUB_OUTPUT"
