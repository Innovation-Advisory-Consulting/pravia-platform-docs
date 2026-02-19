# Husky Internal Files

## Overview
This directory contains Husky's internal configuration and hook templates. These files are managed by Husky and should not be modified manually.

## Contents

### husky.sh
Base script for hook execution (deprecated in Husky v10).

### Hook Templates
Available Git hooks that can be configured:
- applypatch-msg
- commit-msg
- post-applypatch
- post-checkout
- post-commit
- post-merge
- post-rewrite
- pre-applypatch
- pre-auto-gc
- pre-merge-commit
- pre-push
- pre-rebase
- prepare-commit-msg

**Note:** Only `pre-commit` is currently active. See parent directory documentation for details.
