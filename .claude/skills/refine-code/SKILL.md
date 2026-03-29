---
description: Stress-test a technical/coding idea by spinning up engineering persona agents that debate from different perspectives
user-invocable: true
---

# Refine Code — Technical Idea Refinement Through Engineering Debate

Take a technical/coding idea from the user and stress-test it by spinning up engineering agents with relevant personas. The agents adapt to the nature of the idea — different tasks get different experts.

## Input

The user provides a technical idea, architecture proposal, or implementation approach as the argument to this skill. If no argument is given, ask the user for their idea.

## Steps

### 1. Route: Analyze the idea and pick agents

Before launching any agents, analyze the idea to determine:

1. **Which engineering domains are involved?** (frontend, backend, database, security)
2. **How many agents to spin up?** (2-4, based on complexity and breadth)
3. **Should any domain get two agents with different twists?**

Use these routing rules:

| Idea type | Agents |
|---|---|
| Frontend-only (UI, components, styling) | FE #1 (architecture), FE #2 (performance/UX twist), Security (XSS/client-side risks) |
| Backend-only (API, services, logic) | BE #1 (design/architecture), BE #2 (reliability/scaling twist), Security (auth/validation) |
| Database-only (schema, migrations, queries) | DB #1 (schema design), DB #2 (migration safety/performance twist), Security (data exposure) |
| Full-stack feature | Backend, Frontend, Database, Security — one each |
| Infrastructure/DevOps | BE (service impact), Security (attack surface), DB (data implications if relevant) |
| Security-focused | Security #1 (offensive — find the holes), Security #2 (defensive — design the fix), BE or FE (implementation feasibility) |

If the idea doesn't fit neatly, use your judgment — pick 2-4 agents that cover the most important perspectives. Announce your routing decision briefly before launching.

### 2. Read the relevant persona files

Before constructing agent prompts, read the persona files for each domain you're using:
- Frontend: `~/.claude/personas/frontend-engineer.md`
- Backend: `~/.claude/personas/backend-engineer.md`
- Database: `~/.claude/personas/database-engineer.md`
- Security: `~/.claude/personas/security-engineer.md`

### 3. Launch agents in parallel

Use the Agent tool to launch all selected agents simultaneously. Each agent's prompt must include:

1. The full content of its persona file (from step 2)
2. Its specific role in this debate
3. The user's idea
4. Instructions to explore the codebase for relevant context

**Agent prompt template:**

> {Full persona file content}
>
> ---
>
> ## Your Role in This Debate
>
> You are evaluating the following technical idea from the perspective described above. {Role-specific twist if applicable.}
>
> **The idea:** {user's idea}
>
> ## Instructions
>
> 1. First, explore the codebase to understand the current state of relevant code. Use Glob, Grep, and Read to find related files, patterns, and existing implementations.
> 2. Then, evaluate the idea through your engineering lens. Be specific — reference actual files, patterns, and code you found.
> 3. Provide your assessment in this format:
>
> ### {Your Persona} Assessment
> **Verdict:** {thumbs up / thumbs down / conditional} — one-sentence summary
>
> **What works well about this idea** (2-3 bullets)
>
> **Concerns from my perspective** (2-4 bullets, referencing specific code/patterns where relevant)
>
> **Suggestions** (2-3 concrete, actionable recommendations)
>
> **Codebase context** (relevant files/patterns you found that inform this assessment)

For agents with a **twist**, append the twist to the role description. Examples:
- Performance twist: "Focus specifically on performance implications — bundle size, query costs, render cycles, scalability bottlenecks."
- Migration safety twist: "Focus specifically on migration risks — data integrity, rollback strategy, zero-downtime deployment."
- UX twist: "Focus specifically on user experience implications — accessibility, responsiveness, interaction patterns, error states."
- Reliability twist: "Focus specifically on failure modes — what happens when things go wrong, error handling, recovery, observability."
- Offensive security twist: "Think like an attacker. How would you exploit this? What attack chains does this enable or expose?"
- Defensive security twist: "Design the security controls. What validation, authentication, authorization, and monitoring does this need?"

### 4. Synthesize

After all agents return, combine their outputs into a single synthesis:

```
## Technical Review: {idea title}

### The Idea
{one-sentence restatement}

### Routing
{which agents were selected and why}

---

{Each agent's assessment, separated by ---}

---

### Synthesis

**Overall verdict:** {go / no-go / go with changes}

**Consensus points:** (things all agents agreed on)

**Key tensions:** (where agents disagreed — these are the interesting decisions)

**Recommended approach:** {concrete next steps that address the major concerns}

**Biggest risk:** {the single most important thing to get right}
```

### 5. Offer iteration

After presenting the synthesis, ask the user:
> Want to refine the approach? Adjust your idea based on the feedback and I'll run another round — or ask me to dive deeper into any specific concern.

## Rules

- All agents MUST run in parallel (single message with multiple Agent tool calls)
- Each agent MUST explore the actual codebase — assessments should reference real files and patterns, not generic advice
- Each agent MUST receive the full persona file content in its prompt
- The routing decision must be announced before launching agents
- Keep each agent's output focused and concise — specific critique over generic advice
- If the idea is too vague to evaluate technically, ask the user to sharpen it before launching agents
- Minimum 2 agents, maximum 4 agents per round
- Security perspective should be included in almost every round — only skip if the idea is purely cosmetic/styling
