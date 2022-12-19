# Verify Changed Files

![License: MIT][shield-license-mit]
[![CI][shield-ci]][workflow-ci]
[![Ubuntu][shield-platform-ubuntu]][job-runs-on]
[![macOS][shield-platform-macos]][job-runs-on]
[![Windows][shield-platform-windows]][job-runs-on]

A GitHub Action to verify file changes that occur during workflow execution.

## Features

- Lists all files that changed during a workflow execution
- Fast execution
- Scales to large repositories
- Supports all platforms (Linux, macOS, Windows)
- Does not use external dependencies

## Usage

### Detect changes to all files

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v3.1.0

  - name: Change Files
    run: |
      echo "test" > test/new.txt
      echo "test" > unstaged.txt

  - name: Get Changed Files
    id: verify-changes
    uses: zyactions/verify-changed-files@v1

  - name: Run only if one of the files has changed
    if: steps.verify-changes.outputs.changed-files != ''
    run: |
      echo "Changed Files:"
      echo "${{ steps.verify-changes.outputs.changed-files }}"

  - name: Run only if 'unstaged.txt' has changed
    if: contains(steps.verify-changes.outputs.changed-files, 'unstaged.txt')
    run: |
      echo "Detected changes to 'unstaged.txt'"
```

### Detect changes to specific files

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v3.1.0
    # ...
  - name: Get Changed Files
    id: stage1
    uses: zyactions/verify-changed-files@v1
    with:
      return-pipe: true

  - name: Filter Results
    id: stage2
    uses: zyactions/glob@v1
    with:
      pattern: |
        test/*
        unstaged.txt
      pipe: ${{ steps.stage1.outputs.pipe }}

  - name: Print
    run: |
      echo "Changed Files:"
      echo "${{ steps.stage2.outputs.matches }}"
```

## Inputs

### `exclude-ignored`

Configures the action to exclude `.gitignore` ignored files for added files detection. This option is enabled by default.

### `return-pipe`

Enable this option to return a shell (bash) command in the `pipe` output that can be used for piping.

The output command must be `eval`ed to return the results. It can also be passed to other actions that support a `pipe` input.

> **Note**: The `changed-files` output will not be populated if this option is enabled.

## Outputs

### `changed-files`

This output contains all files detected by the action, separated by the configured `separator`. Contains the empty string if no changes were detected.

> **Note**: This output is only available if the `return-pipe` option is not enabled.

### `pipe`

A shell (bash) command which can be used for piping.
      
> **Note**: This output is only available if the `return-pipe` option is enabled.

## Dependencies

### Actions

This action does not use external GitHub Actions dependencies.

## Versioning

Versions follow the [semantic versioning scheme][semver].

## License

Verify Changed Files Action is licensed under the MIT license.

[glob-cheat-sheet]: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#filter-pattern-cheat-sheet
[job-runs-on]: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idruns-on
[semver]: https://semver.org
[shield-license-mit]: https://img.shields.io/badge/License-MIT-blue.svg
[shield-ci]: https://github.com/zyactions/verify-changed-files/actions/workflows/ci.yml/badge.svg
[shield-platform-ubuntu]: https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu\&logoColor=white
[shield-platform-macos]: https://img.shields.io/badge/macOS-53C633?logo=apple\&logoColor=white
[shield-platform-windows]: https://img.shields.io/badge/Windows-0078D6?logo=windows\&logoColor=white
[workflow-ci]: https://github.com/zyactions/verify-changed-files/actions/workflows/ci.yml
