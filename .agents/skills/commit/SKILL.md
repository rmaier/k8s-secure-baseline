---
name: commit
description: Stage changes and commit using Conventional Commits format with a why-focused body
---

You are helping the user create a well-formed git commit. Follow these steps exactly:

## 1. Inspect the working tree

Run these in parallel:
- `git status` — identify staged and unstaged changes
- `git diff --cached` — inspect what is staged
- `git diff` — inspect unstaged changes
- `git log --oneline -5` — learn the recent commit style for this repo

## 2. Determine what to stage

If nothing is staged, ask the user which files to stage (list the changed files). Do not run `git add -A` or `git add .` — add specific files only.

## 3. Draft the commit message using this exact template

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

**Rules:**
- `type` must be one of: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`, `style`
- `scope` is optional but encouraged; omit the parentheses if scope is absent
- `subject`: imperative mood, ≤ 72 chars, no trailing period
- `body`: explain *why* this change is needed, not *what* changed — the diff shows the what. One short paragraph is enough.

## 4. Show the draft to the user

Present the full proposed commit message in a code block and ask for approval or edits. Do NOT commit yet.

## 5. Commit after approval

Once the user approves, stage any files they confirmed and run:

```bash
git commit -m "$(cat <<'EOF'
<approved message here>
EOF
)"
```

Verify with `git status` after committing.

## Conventional Commits type reference

| Type | When to use |
|------|-------------|
| `feat` | New feature visible to users |
| `fix` | Bug fix |
| `refactor` | Code change with no behavior change |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `chore` | Tooling, deps, config (no prod code) |
| `build` | Build system or dependency changes |
| `ci` | CI/CD pipeline changes |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace, linting (no logic) |

For breaking changes, append `!` after the type/scope: `feat!: ...` and add a `BREAKING CHANGE:` footer.
