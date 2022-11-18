#!/usr/bin/env bash

set -e
set -o noglob

echo "::group::verify-changed-files"

# Try to update the index before the diff. The native `git diff-files` command does not do that automatically...
{ git update-index --refresh || :; } > /dev/null 2>&1

GIT_EXCLUDE=""
if [[ "$INPUT_EXCLUDE_IGNORED" == "true" ]]; then
  GIT_EXCLUDE="--exclude-standard"
fi

if [[ -n "$INPUT_PATH" ]]; then
  # Split newline delimited patterns into individual arguments
  PATTERN=$(echo "$INPUT_PATH" | tr '\n' '\0' | xargs -0 echo)

  TRACKED_FILES=$(git diff-files --diff-filter=ACDMRTUX --name-only | python3 "$GITHUB_ACTION_PATH/glob/globmatch.py" $PATTERN)
  UNTRACKED_FILES=$(git ls-files --others "$GIT_EXCLUDE" | python3 "$GITHUB_ACTION_PATH/glob/globmatch.py" $PATTERN)
else
  TRACKED_FILES=$(git diff-files --diff-filter=ACDMRTUX --name-only)
  UNTRACKED_FILES=$(git ls-files --others "$GIT_EXCLUDE")
fi

CHANGED_FILES=""

if [[ -n "$TRACKED_FILES" && -n "$UNTRACKED_FILES" ]]; then
  CHANGED_FILES="$TRACKED_FILES"$'\n'"$UNTRACKED_FILES"
elif [[ -n "$TRACKED_FILES" && -z "$UNTRACKED_FILES" ]]; then
  CHANGED_FILES="$TRACKED_FILES"
elif [[ -n "$UNTRACKED_FILES" && -z "$TRACKED_FILES" ]]; then
  CHANGED_FILES="$UNTRACKED_FILES"
fi

if [[ -n "$CHANGED_FILES" ]]; then
  echo "Found uncommited changes"

  CHANGED_FILES=$(echo "$CHANGED_FILES" | LC_ALL=C sort -u)

  if [[ -n "$INPUT_SEPARATOR" ]]; then
    if [[ "$INPUT_SEPARATOR" == '"' ]]; then
      echo "::warning ::Using double quotes as the filename separator can lead to unexpected behavior."
    fi
    CHANGED_FILES=$(echo "$CHANGED_FILES" | sed "s/.*$INPUT_SEPARATOR.*/\"&\"/g" | awk -v d="$INPUT_SEPARATOR" '{s=(NR==1?s:s d)$0}END{print s}')
  fi

  echo "changed-files=$CHANGED_FILES" >> "$GITHUB_OUTPUT"  
else
  echo "No changes found"
fi

echo "::endgroup::"
