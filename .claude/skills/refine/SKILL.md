---
description: Stress-test an idea through structured Bull/Bear/Builder debate with parallel agents and web research
user-invocable: true
---

# Refine — Idea Refinement Through Structured Debate

Take an idea from the user and stress-test it by running parallel agents that argue different perspectives, then synthesize the results into a refined version of the idea.

## Input

The user provides an idea, thesis, or proposal as the argument to this skill. If no argument is given, ask the user for their idea.

## Steps

### 1. Acknowledge and frame the idea

Briefly restate the idea in one sentence to confirm understanding. Do not evaluate it yet.

### 2. Launch three agents in parallel

Use the Agent tool to launch all three simultaneously. Each agent should use WebSearch to ground its arguments in real-world evidence, examples, and data.

**Agent 1 — Bull (Advocate)**
Prompt:
> You are a passionate advocate for the following idea. Your job is to make the strongest possible case FOR it. Find supporting evidence, successful precedents, market data, and compelling arguments. Steel-man this idea — make it as convincing as possible. Be specific, cite real examples, and address obvious objections preemptively.
>
> The idea: {user's idea}
>
> Use WebSearch to find supporting evidence, successful precedents, and market data.
>
> Output format:
> ## Bull Case
> ### Core argument (2-3 sentences)
> ### Supporting evidence (3-5 bullets with specific examples)
> ### Why skeptics are wrong (2-3 bullets addressing likely objections)

**Agent 2 — Bear (Critic)**
Prompt:
> You are a rigorous skeptic analyzing the following idea. Your job is to find every flaw, risk, and reason this could fail. Look for failed precedents, market dynamics that work against it, hidden costs, and logical weaknesses. Be specific and substantive — not dismissive. The goal is to find real problems, not just be contrarian.
>
> The idea: {user's idea}
>
> Use WebSearch to find failed precedents, counterexamples, and data that undermines the idea.
>
> Output format:
> ## Bear Case
> ### Fatal flaws (the 1-2 biggest problems)
> ### Risks and hidden costs (3-5 bullets)
> ### Failed precedents (specific examples of similar ideas that didn't work and why)

**Agent 3 — Builder (Executor)**
Prompt:
> You are a pragmatic builder. Assume the following idea is worth pursuing. Your job is to figure out HOW to make it work. Identify what needs to be true for this to succeed, what the MVP looks like, who the first users are, and what the biggest execution risks are. Be concrete and actionable.
>
> The idea: {user's idea}
>
> Use WebSearch to research existing tools, competitors, and market dynamics relevant to execution.
>
> Output format:
> ## Builder's Playbook
> ### What must be true for this to work (2-3 key assumptions)
> ### MVP scope (what the simplest version looks like)
> ### First users (who wants this most and where to find them)
> ### Execution risks (2-3 things that could derail the build)

### 3. Synthesize

After all three agents return, combine their outputs into a single synthesis. Structure it as:

```
## Idea Refinement: {idea title}

### The Idea
{one-sentence restatement}

---

### Bull Case
{Agent 1 output}

---

### Bear Case
{Agent 2 output}

---

### Builder's Playbook
{Agent 3 output}

---

### Synthesis

**Verdict:** {one-sentence overall assessment — is this worth pursuing, with caveats?}

**Strongest argument for:** {one sentence}

**Strongest argument against:** {one sentence}

**If you proceed, start here:** {one concrete next step from the Builder}

**Key risk to mitigate first:** {the single biggest risk from Bear + Builder}
```

### 4. Offer iteration

After presenting the synthesis, ask the user:
> Want to refine further? You can adjust the idea based on what you've read and I'll run another round.

## Rules

- All three agents MUST run in parallel (single message with three Agent tool calls)
- Each agent must use WebSearch at least once to ground arguments in evidence
- The synthesis must be balanced — do not editorialize or pick a side
- Keep each agent's output concise — quality of argument over quantity of words
- If the idea is too vague to debate meaningfully, ask the user to sharpen it before launching agents
