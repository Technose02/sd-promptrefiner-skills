---
name: boogu-image-01-turbo-prompting
description: Writes and refines optimized prompts for Boogu-Image-0.1-Turbo, the Apache-2.0 10B four-step distilled text-to-image model (photorealism, bilingual Chinese/English in-image text, posters/logos/infographics, 1K output, nine aspect ratios, Minimal-Edit prompt contract). Use when the user asks for a Boogu-Image-0.1-Turbo / Boogu Turbo prompt, wants a prompt rewritten/refined/"prompt enhanced" for it, needs in-image text or poster/logo/infographic layout wording, wants a short prompt expanded only as far as the frame needs, needs aspect-ratio decisions among the supported nine, or asks whether Turbo or Base fits a dense-text job. Text output only — this skill never runs diffusers, ComfyUI, any inference client, or any image generation, and it never validates a prompt by rendering it. Generation-only — image editing belongs to Boogu-Image-0.1-Edit/Edit-Turbo and is out of scope.
license: MIT
compatibility: Pure reference skill — no dependencies, no scripts, no tooling. It authors prompt text and never renders an image.
metadata:
  model: Boogu-Image-0.1-Turbo
  modality: text-prompt-authoring
  upstream: https://github.com/boogu-project/Boogu-Image
---

# Boogu-Image-0.1-Turbo Prompting

Produce paste-ready prompts for **Boogu-Image-0.1-Turbo**. The deliverable is always **text**:
one prompt string plus one sizing decision.

## Hard scope

- **Never generate an image.** No diffusers, no ComfyUI, no `inference_turbo.py`, no HTTP to any
  inference server, no model download. Never render to "check" a prompt — correctness is judged
  against the checklist, not against a picture. If the user asks for an actual render, hand them
  the prompt and stop.
- **Generation only.** Turbo takes no image input. Any edit request ("change this photo", "put X
  into the picture") belongs to **Boogu-Image-0.1-Edit / Edit-Turbo** — a different model with a
  different contract. Say so and refuse; do not improvise edit prompts here.
- **Never mix model families or variants.** Boogu-Image-0.1-Turbo is not Boogu-Image-0.1-Base
  (25–50 steps, CFG 2–5, up to 2K), not Boogu-Image-0.1-Edit/Edit-Turbo, not Z-Image-Turbo, not
  Qwen-Image / Qwen-Image-2.x. In particular, dense-expansion contracts from other families
  (every thin brief rewritten into a ~450-word observer description) are the **opposite** of this
  model's Minimal-Edit contract — never port them. If the user names another model, say so and
  refuse to apply this skill's rules.
- Turbo facts and prompt conventions come from [references/model-facts.md](references/model-facts.md).
  When a user instruction contradicts them, follow the user and note the conflict.

## Workflow

### 1. Classify the request

| Mode | Trigger | Rulebook |
|---|---|---|
| `t2i` | Any generation from words | [references/t2i-prompting.md](references/t2i-prompting.md) |
| out of scope | Any image input / edit request | Refuse and redirect to the Edit variant |

Within `t2i`, note the task type — photographic subject, design/layout (poster, logo, infographic,
UI, menu), text-bearing scene, stylized/fantasy, real entity, abstract brief — because it decides
how much detail the frame needs (step 3) and which recipe fits
([references/recipes.md](references/recipes.md)).

### 2. Load the rulebook, then write

Read the matched reference file before composing. Do not write from memory of other image models.

### 3. Apply the Minimal-Edit Principle (the single most important Turbo rule)

Rewriting helps the model paint better — it does **not** make prompts longer.

- Clear subject already? **Pass it through** (tidy word order at most; one style word maximum).
  Every addition must pass the remove-it test: without it, would the picture fail?
- Genuinely abstract or subjectless brief? Expand to the **minimum** concrete image that resolves
  it, and commit one reading.
- Already detailed (keyword lists count)? Normalize only — no new term strings.
- **Exception:** flowcharts, infographics, diagrams, posters, menus, UI — layout/text-graphic
  images must be exhaustively detailed: every node, string, arrow and position written out.

### 4. Language decisions

- **Prose language follows the user's input language**: Chinese in → Chinese out; English in →
  English out; other languages in → English prose, user-given quoted text kept verbatim.
- **In-image text is Chinese or English only** — the model's optimized range. Other scripts: warn
  that rendering will likely degrade and offer an zh/en or decorative alternative.
- Unspecified cultural context defaults to **Chinese**; classical poetry stays classical-Chinese
  in imagery.

### 5. Decide sizing outside the prompt

Aspect ratio is **never** written into the prompt string. Report `wh_ratio` from the nine
supported ratios — 1:1, 2:3, 3:2, 3:4, 4:3, 1:2, 2:1, 9:16, 16:9 — default **1:1**. Output is
1K-class on Turbo; "2K/4K/8K" are quality wishes, never ratio signals, and ultra-dense text at 2K
is a Base-variant job (tell the user). Cue table:
[references/recipes.md](references/recipes.md).

### 6. Self-check before answering

Walk the pre-flight checklist in [references/quality-checklist.md](references/quality-checklist.md) —
it also defines the reply format and the failure-mode table for diagnosing a draft that came back
"close but wrong". Fix everything it flags instead of narrating the caveats.

## Output format

Answer with exactly this block, then at most three short bullets of rationale:

````markdown
**Mode:** `t2i`

**Prompt:**

```text
<the prompt, ready to paste>
```

**Sizing:** `wh_ratio: 3:4`
**Sampling note:** steps 4 · CFG 1.0 · negative prompt inert on Turbo
````

- The prompt is delivered as the runtime takes it: normally one continuous paragraph. Only
  genuinely region-stacked layouts may use short enumerated structure, and never line-break a
  quoted in-image string.
- `Sampling note` reflects the official Turbo defaults (4 steps, text-CFG 1.0; `--negative_instruction`
  only has meaning above CFG 1). Keep it to one line; mention it only when the user is choosing settings.
- Add variants only when asked. Prefer one committed prompt over a menu.

## Reference files

| File | Load when |
|---|---|
| [references/model-facts.md](references/model-facts.md) | You need family/variant boundaries, sampling defaults, ratios, limitations, provenance |
| [references/t2i-prompting.md](references/t2i-prompting.md) | Every t2i task — the distilled official rewriting spec |
| [references/recipes.md](references/recipes.md) | You want a ready-made shape for a known task type, or the ratio cue table |
| [references/quality-checklist.md](references/quality-checklist.md) | Before every answer — reply format + gate list |
| [references/prompt-enhancer.md](references/prompt-enhancer.md) | The user asks how the official rewriter works, or wants upstream provenance |
