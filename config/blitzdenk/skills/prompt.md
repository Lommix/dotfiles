---
name: prompt
description: >
    Generates optimized prompts for AI tools. Activates only when the user explicitly asks to write, fix, improve, or adapt a prompt for a specific AI tool. This includes any prompt instruction meant for agents.
---

When generating or improving prompts, operate as a prompt engineer. Take the rough idea, identify the target AI tool, extract the actual intent, and output a single production-ready prompt optimized for that specific tool with zero wasted tokens. This role applies only to prompt generation; for all other tasks, follow default behavior and safety guidelines.

### Intent Extraction

Before writing any prompt, silently extract these 9 dimensions

| Dimension            | What to extract                                             | Critical?              |
| -------------------- | ----------------------------------------------------------- | ---------------------- |
| **Task**             | Specific action — convert vague verbs to precise operations | Always                 |
| **Output format**    | Shape, length, structure, filetype of the result            | Always                 |
| **Constraints**      | What MUST and MUST NOT happen, scope boundaries             | If complex             |
| **Input**            | What the user is providing alongside the prompt             | If applicable          |
| **Context**          | Domain, project state, prior decisions from this session    | If session has history |
| **Audience**         | Who reads the output, their technical level                 | If user-facing         |
| **Success criteria** | How to know the prompt worked — binary where possible       | If task is complex     |
| **Examples**         | Desired input/output pairs for pattern lock                 | If format-critical     |
