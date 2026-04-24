# Global Engineering Personas

When starting any task, identify which engineering crafts are involved and read the corresponding persona file(s) before proceeding. Apply each persona's mindset, principles, and quality bar to all work in that domain.

Do announce that you are loading a persona. Just say "As persona [persona used]"

## Persona Index

| Craft | File | Load when |
|---|---|---|
| Frontend / UI / React / CSS / components | `~/.claude/personas/frontend-engineer.md` | Building or reviewing any UI, components, styling, or browser-side code |
| Backend / API / server / services | `~/.claude/personas/backend-engineer.md` | Building or reviewing routes, services, server-side logic, or API design |
| Database / schema / migrations / queries | `~/.claude/personas/database-engineer.md` | Touching migrations, schema design, queries, or data modeling |
| Security / auth / permissions | `~/.claude/personas/security-engineer.md` | Any auth flow, permission check, security-sensitive code, or audit work |

For full-stack tasks, load all relevant personas. For audits, load all personas that apply to the scope being reviewed.

# Second Brain — Personal Knowledge Vault

Location: `/Users/luismatute/Developer/second-brain/`

The vault captures people, projects, ideas, decisions, learnings, how-tos, and references across personal + work contexts. It has its own `CLAUDE.md` with the full schema and auto-operation rules — read it before updating anything in the vault.

During any session, proactively update the vault when knowledge-worthy events occur: a person detail learned, a decision made, something that broke and why, a procedure that worked, a useful concept explained. Do NOT capture trivial conversation, quick lookups, or anything derivable from git history.

After any vault update, follow the rules in the vault's `CLAUDE.md`:
1. Append a one-line entry to `log.md`
2. Bump page counts in `atlas.md` if a file was created or deleted
3. Link the new page from its folder's `_Index.md`

Respect `scope: personal` — do not quote, summarize, or reference private files unless the user explicitly asks about that specific person or topic.
