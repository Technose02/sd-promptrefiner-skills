---
name: qwen-image-21-prompting
description: Writes and refines optimized prompts for Qwen-Image-2.1, the unified text-to-image and instruction-based image-editing model (single reference image, up to 10 reference images, native RGBA/transparent output, native 2K, in-image text rendering, local edits via circles/annotations/masks). Use when the user asks for a Qwen-Image-2.1 prompt, wants a prompt rewritten/refined/"prompt enhanced" for it, needs `<imageN>` multi-reference edit wording, preservation wording for identity or product fidelity, aspect-ratio decisions, or a T2I description expanded to the official dense-paragraph style. Text output only — this skill never runs diffusers, ComfyUI, any inference client, or any image generation/editing, and it never validates a prompt by rendering it.
license: MIT
compatibility: Pure reference skill — no dependencies, no scripts, no tooling. It authors prompt text and never renders or edits an image.
metadata:
  model: Qwen-Image-2.1
  modality: text-prompt-authoring
  upstream: https://github.com/QwenLM/Qwen-Image-2.1
---

# Qwen-Image-2.1 Prompting

Produce paste-ready prompts for **Qwen-Image-2.1**. The deliverable is always **text**:
one prompt string plus one sizing decision.

## Hard scope

- **Never generate or edit an image.** No diffusers, no ComfyUI, no `cargo run --example`, no HTTP to any
  inference server, no model download. Never render to "check" a prompt — correctness is judged against the
  checklist, not against a picture. If the user asks for an actual render, hand them the prompt and stop.
- **Never mix model families.** Qwen-Image-2.1 is not Qwen-Image (20B), not Qwen-Image-Edit-2509/2511, not
  Qwen-Image-2512, not Qwen-Image-2.0, not Boogu/Z-Image. Do not port rules from those models. If the user
  names an older model, say so and refuse to apply this skill's rules.
- 2.1 facts and prompt conventions come from [references/model-facts.md](references/model-facts.md).
  When a user instruction contradicts them, follow the user and note the conflict.

## Workflow

### 1. Classify the request

| Mode | Trigger | Rulebook |
|---|---|---|
| `t2i` | No source image; generate from words | [references/t2i-prompting.md](references/t2i-prompting.md) |
| `t2i-rgba` | Transparent/sticker/logo cut-out from words | t2i + RGBA wrapper (§ below) |
| `edit-1` | Exactly one source image, change something | [references/edit-prompting.md](references/edit-prompting.md) |
| `edit-N` | ≥2 source images (try-on, face swap, compositing, group shot) | edit-prompting + `<imageN>` tag rules |
| `extract` | Cut a subject out of a photo into transparency | edit-prompting + RGBA note |

If unclear, infer from whether an image exists and whether the user wants *this picture changed*
(local edit) or *a new picture of this subject* (scene build). That distinction drives how much you
invent — see step 3.

### 2. Load the right rulebook, then write

Read the matched reference file before composing. Do not write from memory of other image models.

### 3. Scale elaboration to intent (the single most important 2.1 rule)

- **Local edit / attribute change / text edit / quality or style pass / canvas transform** →
  *clarify and constrain*: say precisely what changes, push that change to an unmistakable degree,
  and let everything else stand. Do **not** invent new content.
- **New picture of the same subject / scene swap / multi-reference composition / photo-shoot,
  poster, infographic from a reference** → *construct actively*: design composition, lighting,
  materials and layout to a professional standard.
- `t2i` is always the "construct actively" branch: a three-word brief still becomes a full
  ~400–500 word observer description. A thin brief never buys a thin description.

### 4. Two separate language decisions (edit mode)

Conflating these is the classic failure:

- **(A) Prose language** — the descriptive words outside double quotes follow the **user's
  instruction** language: Chinese in → Chinese out; English in → English out; any other language in →
  English out.
- **(B) Rendered text language** — the words **inside** double quotes (what gets painted into the
  image), in strict priority: exact text/language the user gave → dominant language of text already
  visible in the input image → language of the user's instruction. Never force it to English.
  Quoted text is always **monolingual**: no bilingual pairs, no translation glosses, unless asked.

In `t2i` mode prose is **always English**, whatever language the request arrived in; only the
in-image strings keep their own script.

### 5. Decide sizing outside the prompt

Aspect ratio and resolution are **never** written into the prompt string. Report them as a separate
field (`wh_ratio` for a fixed ratio, or "follow image 1 / the canvas image" for edits). 2K/4K/8K are
quality words, not ratio words. Table of native sizes: [references/model-facts.md](references/model-facts.md).

For multi-reference edits, name the **canvas image** — the one whose framing the output follows — using
the mapping in [references/edit-prompting.md](references/edit-prompting.md#canvas-mapping).

### 6. Self-check before answering

Walk the pre-flight checklist in [references/quality-checklist.md](references/quality-checklist.md) — it
also defines the reply format and the failure-mode table for diagnosing a draft that came back "close but
wrong". Fix everything it flags instead of narrating the caveats.

## Output format

Answer with exactly this block, then at most three short bullets of rationale:

````markdown
**Mode:** `edit-N` (2 reference images, `<image1>` is the canvas)

**Prompt:**

```text
<single-paragraph prompt, ready to paste>
```

**Sizing:** `wh_ratio: 2:3`  *(or: follow `<image1>`)*
**Sampling note:** steps 40 · `true_cfg_scale` 1.0 · no negative prompt
````

- `wh_ratio` and "follow an input image" are **mutually exclusive**.
- The prompt is one continuous paragraph, no line breaks, no bullet lists inside the code block.
- `Sampling note` reflects the official defaults (40 steps, guidance off; a negative prompt is only
  read when `true_cfg_scale > 1`, which doubles per-step cost). Keep it to one line; mention it only
  when the user is choosing settings.
- Add variants only when asked. Prefer one committed prompt over a menu.

## RGBA (transparent output)

2.1's VAE carries four channels, so transparency is generated, not cut out. Wrap the description:

```text
This is an RGBA image with transparency. <your description>. The image has alpha channel and the background is transparent.
```

Recipes, including subject extraction and transparent-layer editing:
[references/recipes.md](references/recipes.md).

## Reference files

| File | Load when |
|---|---|
| [references/model-facts.md](references/model-facts.md) | You need architecture, limits, defaults, native sizes, provenance |
| [references/edit-prompting.md](references/edit-prompting.md) | Any mode with a source image |
| [references/t2i-prompting.md](references/t2i-prompting.md) | Text-to-image (incl. RGBA from words) |
| [references/recipes.md](references/recipes.md) | You want a ready-made shape for a known task type |
| [references/quality-checklist.md](references/quality-checklist.md) | Before every answer — reply format + gate list |
| [references/prompt-enhancer.md](references/prompt-enhancer.md) | The user asks how the official refiner works, or wants upstream provenance |
