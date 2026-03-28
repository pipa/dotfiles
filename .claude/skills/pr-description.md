# PR Description Skill

Generate a polished, markdown-formatted pull request description for the current branch.

## Steps

1. Run the following git commands to gather context:
   - `git log main..HEAD --oneline` — list all commits on this branch
   - `git diff main...HEAD --stat` — files changed summary
   - `git log main..HEAD --format="%B"` — full commit messages

2. Analyse the changes:
   - Identify the type of change: feature, fix, refactor, chore, docs, etc.
   - Group related changes into logical sections
   - Note any breaking changes, migrations, or deployment steps required

3. Output **only** a markdown PR description — no preamble, no explanation around it. The output itself should be valid markdown ready to paste into GitHub.

## Output Format

Use this structure (adapt sections to what's actually relevant — omit sections that don't apply):

```markdown
## Summary

One or two sentences on what this PR does and why.

## Changes

### <Logical Group 1>
- Bullet describing change
- Bullet describing change

### <Logical Group 2>
- Bullet describing change

## Why

Explain the motivation if it isn't obvious from the summary — what problem this solves, what decision was made and why.

## Testing

Checklist of things a reviewer should verify manually or that are covered by automated tests:

- [ ] Item to test
- [ ] Item to test

## Notes

Any caveats, follow-ups, known limitations, or things to watch out for after merge. Omit this section if there's nothing to add.
```

## Rules

- Write in plain, direct prose — no fluff or filler phrases like "This PR aims to..."
- Use past tense for what was done ("Added", "Fixed", "Replaced") not future ("Will add")
- Keep bullets tight — one idea per bullet, no run-ons
- The Testing section should be actionable — specific things to click/verify, not generic ("verify it works")
- Never include the ``` fences in the final output — output raw markdown only
- Do not add a PR title — GitHub has a separate title field
