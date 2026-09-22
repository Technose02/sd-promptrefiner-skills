---
name: boogu-image-01-edit-turbo-prompting
description: Writes and refines optimized edit instructions for Boogu-Image-0.1-Edit-Turbo, the Apache-2.0 10B four-step distilled instruction-editing model (exactly one input image; object add/remove/replace, background swap, human and product edits with preservation wording, in-image text editing in Chinese/English, style transformation, fixed-template old-photo restoration). Use when the user asks for a Boogu Edit-Turbo prompt, wants an edit instruction rewritten/refined/"prompt enhanced" for it, needs preservation/identity wording that works without CFG, the official text-replacement or restoration templates, style-described-in-traits wording, or the follow-input sizing decision. Text output only — this skill never runs diffusers, ComfyUI, any inference client, or any image generation/editing, and it never validates an instruction by rendering it.
license: MIT
compatibility: Pure reference skill — no dependencies, no scripts, no tooling. It authors instruction text and never renders an image.
metadata:
  model: Boogu-Image-0.1-Edit-Turbo
  modality: text-prompt-authoring
  upstream: https://github.com/boogu-project/Boogu-Image
---

# Boogu-Image-0.1-Edit-Turbo Prompting

Produce paste-ready edit instructions for **Boogu-Image-0.1-Edit-Turbo**. The deliverable is always
**text**: one instruction string plus one sizing decision.

## Hard scope

- **Never generate or edit an image.** No diffusers, no ComfyUI, no `inference_turbo.py`, no HTTP
  to any inference server, no model download. Never render to "check" an instruction — correctness
  is judged against the checklist, not against a picture. If the user asks for an actual render,
  hand them the instruction and stop.
- **Exactly one input image.** The model supports a single reference image (official). Multi-image
  composition, try-on from a second photo and `<imageN>` addressing do not exist here — refuse such
  requests and say why.
- **Editing only.** Pure text-to-image belongs to Boogu-Image-0.1-Turbo / Base — different models,
  different contracts. Refuse and redirect.
- **Never mix model families or variants.** Edit-Turbo is not Boogu-Image-0.1-Edit (25–50 steps,
  CFG 2–5, image-guidance dial), not Base/Turbo (T2I, Minimal-Edit contract — editing here wants
  *detail*, the opposite), not Qwen-Image / Qwen-Image-2.x (`<imageN>` tags, canvas mapping,
  dense-observer style), not Z-Image, not FLUX. Do not port their rules, defaults or examples. If
  the user names another model, say so and refuse to apply this skill's rules.
- Facts and conventions come from [references/model-facts.md](references/model-facts.md). When a
  user instruction contradicts them, follow the user and note the conflict.

## Workflow

### 1. Classify the request

| Mode | Trigger | Rulebook |
|---|---|---|
| `edit` | One input image + a change request | [references/edit-prompting.md](references/edit-prompting.md) |
| out of scope | No image (pure T2I) or ≥2 reference images | Refuse and redirect (see Hard scope) |

Within `edit`, note the task type — add/remove/replace, background swap, human edit, text edit,
style transformation, restoration/colorization, attribute change — each has an official rule and a
recipe ([references/recipes.md](references/recipes.md)).

### 2. Load the rulebook, then write

Read the matched reference file before composing. Do not write from memory of other image models.

### 2a. Analyse the input image — the skill reasons, the diffusion encoder never does

Look at the single reference image and extract every factual attribute the edit needs. The skill
does the reasoning; the diffusion model's text encoder never "reads" an image for factual detail.
- Objects: count, category, colour, material, position, relative scale, pose/orientation.
- People: pose, expression, hair, skin tone, clothing, accessories.
- In-image text: every character, verbatim, with position, font, colour, weight, language.
- Lighting: source, direction, quality (hard/soft), shadows, highlights, colour temperature.
- Composition: layout, framing (close-up/medium/full), depth of field, rendering medium.
- **What goes in the instruction:** facts the LLM extracts reliably — text strings, counts,
  colours, materials, spatial relationships, lighting direction. The diffusion encoder needs
  these in text because it never derives them from the pixels.
- **What stays with the reference image:** fine-grained identity — facial proportions, product
  contours, subtle texture. The instruction says "keep the person's face unchanged" without
  narrating every feature.
- Unreliable readings are hedged, never invented. Unreadable in-image text: tell the user the
  exact string is needed; do not make it up.

### 3. Detailed, operation-led, committed (the governing edit rule)

The official contract wants a **precise, detailed, visually achievable** instruction: task type,
target, position, quantity and attributes all committed; vague inputs resolved to minimal-but-
sufficient specifics; contradictions corrected; nothing unrequested added. Short sentences, no
padding — detail is not the same as length.

### 4. Preservation wording is the identity lock

Edit-Turbo samples with guidance off (text/image CFG 1.0, negative instruction inert). There is no
dial to protect the subject — **explicit keep-clauses are the only lock**: name what stays (face,
hairstyle, expression, outfit, product markings, framing, lighting) in every person/product edit,
first in the sentence for background swaps. Promise likeness, not pixel-perfect identity, and say
so when the user needs a hard preservation guarantee.

### 5. Language decisions

- **Instruction prose follows the user's language**: Chinese in → Chinese out; English in →
  English out; other languages in → English prose with user-given quoted strings verbatim.
- **Quoted in-image text is never translated and never re-cased**; text rendering is optimized for
  Chinese and English only — warn on other scripts.

### 6. Decide sizing outside the instruction

Default: **follow the input image** (the pipeline keeps its aspect, 1K class; the 1K hotfix
checkpoint is the officially recommended one). Only an explicit re-frame request gets a
`wh_ratio` from the nine supported ratios — with a drift warning. Never write ratios,
resolutions or pixel counts into the instruction. Details:
[references/model-facts.md](references/model-facts.md).

### 7. Self-check before answering

Walk the pre-flight checklist in
[references/quality-checklist.md](references/quality-checklist.md) — it also defines the reply
format and the failure-mode table for diagnosing a result that came back "close but wrong". Fix
everything it flags instead of narrating the caveats.

## Output format

Answer with exactly this block, then at most three short bullets of rationale:

````markdown
**Mode:** `edit` (one input image)

**Instruction:**

```text
<single edit instruction, ready to paste>
```

**Sizing:** follow input image (1K class)  *(or: `wh_ratio: 3:4` on explicit re-frame request)*
**Sampling note:** steps 4 · text/image CFG 1.0 · negative instruction inert · 1K hotfix checkpoint
````

- The instruction is one continuous flow of short sentences — no headings, no bullet lists, no
  line breaks inside the block.
- `follow input` and `wh_ratio` are **mutually exclusive**.
- `Sampling note` reflects the official defaults (4 steps, DMD path without CFG; hotfix-20260708
  1K weights recommended). Keep it to one line; mention it only when the user is choosing settings.
- Add variants only when asked. Prefer one committed instruction over a menu.

## Reference files

| File | Load when |
|---|---|
| [references/model-facts.md](references/model-facts.md) | You need variant boundaries, sampling defaults, sizing, limitations, provenance |
| [references/edit-prompting.md](references/edit-prompting.md) | Every edit task — the distilled official rewriting spec |
| [references/recipes.md](references/recipes.md) | You want a ready-made shape for a known task type, or the sizing rules |
| [references/quality-checklist.md](references/quality-checklist.md) | Before every answer — reply format + gate list |
| [references/prompt-enhancer.md](references/prompt-enhancer.md) | The user asks how the official rewriter works, or wants upstream provenance |
