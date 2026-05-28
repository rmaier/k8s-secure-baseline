---
name: adr
description: Create an Architecture Decision Record in docs/adr/ using simple markdown
---

You are helping the user create an Architecture Decision Record. Follow these steps exactly:

## 1. Determine the next ADR number

```bash
ls docs/adr/ 2>/dev/null | grep -E '^[0-9]+' | sort | tail -1
```

If the directory is empty or doesn't exist, start at `001`.

## 2. Ask the user four questions (one message, all at once)

- **Title** — short noun phrase, e.g. "Use kubeadm over k3s"
- **Context** — what situation or problem forced this decision?
- **Decision** — what did you decide?
- **Consequences** — what becomes easier, harder, or different as a result?

Do not ask for options considered or alternatives — keep it simple.

## 3. Write the file

Path: `docs/adr/NNN-<kebab-case-title>.md`

Template:

```markdown
# ADR-NNN: <Title>

## Status
Accepted

## Context
<context>

## Decision
<decision>

## Consequences
<consequences>
```

Keep each section to 2–4 sentences max. No bullet lists inside sections — prose only.

## 4. Show the draft to the user and ask for approval

Present the full file content in a code block. Do NOT write the file yet.

## 5. Write and commit after approval

Once the user approves:

1. Create `docs/adr/` if it doesn't exist.
2. Write the file.
3. Commit with:

```
docs(adr): add ADR-NNN <title>
```

No body needed for ADR commits — the document is self-explaining.
