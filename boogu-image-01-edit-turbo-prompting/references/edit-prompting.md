# Edit instructions for Boogu-Image-0.1-Edit-Turbo

Distilled from the official edit-instruction rewriter shipped in the repo
(`boogu/pipelines/boogu/instruct_reasoner_static_skills.py`, `REWRITE_SYSTEM_PROMPT_4_EDIT_EN/_ZH`).
An input image is **always** present — exactly one. The job is to turn the user's request into a
**precise, detailed, visually achievable professional-level edit instruction**.

> ⚠️ Do not port the family's T2I *Minimal-Edit Principle* here. For editing, the official contract
> asks for **detail**: the instruction stays concise sentence-wise, but every edit-relevant property
> is committed. (Equally, the T2I rule "keep a named style as a name only" is **inverted** for
> editing — see §4.)

## General principles (official)

- **Keep the rewritten instruction detailed**; avoid overly long sentences and unnecessary
  descriptive padding.
- If the user's instruction is **contradictory, vague or unachievable**, prioritize reasonable
  inference and correction, and supplement details where necessary. Resolve, then commit — no
  hedging, no "either/or" left standing.
- **Keep the core intention unchanged**: only enhance clarity, rationality and visual feasibility.
  Never add operations the user did not ask for, never "clean up" unmentioned content.
- **Everything added must fit the input image's scene logic and style** — a described addition
  should read as if it was always plausible in that photo.

## Analyse the input image first (the skill does the reasoning)

Diffusion-model text encoders never "reason" — they work in instruction/description mode. The skill
must do all reasoning about the input image and commit those facts into the instruction.

1. **Read every visible element** from the single reference image: objects (count, identity,
   colour, material, position, relative scale); people (pose, expression, hair, clothing,
   accessories); text (every string, verbatim, with its position, font, colour, language);
   lighting (source, direction, quality, shadows, highlights); composition (layout, framing,
   depth-of-field); rendering medium (photograph, illustration, 3D render, painting).
2. **Separate what the instruction needs** from what the image alone can carry:
   - *Into the instruction:* factual attributes the LLM extracts with confidence — text strings,
     object counts, colours, materials, spatial layout, lighting direction, poses, expressions.
     These are reasoned facts the diffusion encoder would never derive on its own.
   - *Left to the reference image:* fine-grained identity/preservation — facial proportions,
     exact product contours, subtle material texture. The instruction says "keep the person's
     facial identity" or "preserve the product design" without narrating every pixel.
3. **If you cannot read a detail reliably** (a distant face, blurred text, a partially hidden
   object), hedge in the instruction ("appears to be dark leather", "a label too small to read")
   rather than inventing confidently. The one exception: in-image text you cannot read → tell the
   user you need the exact string; do not make it up.

This analysis feeds every task type below — without it, an edit instruction is flying blind.

## 1. Add / delete / replace

- **Clear instruction** (task type + target entity + position + quantity + attributes all present) →
  preserve the original intent, only refine grammar. Do not inflate it.
- **Vague instruction** → supplement with *minimal but sufficient* detail: category, colour, size,
  orientation, position. Canonical official example:
  - "Add an animal" → **"Add a light-gray cat in the bottom-right corner, sitting and facing the camera"**
- **Meaningless instructions** ("add 0 objects") → ignore or flag as invalid; do not render them.
- **Replacement** → the official shape is **"Replace Y with X"** plus a brief description of X's
  key visual features.
- **Removal** → name the target, then say the vacated area is cleanly rebuilt as a continuation of
  the surrounding background (surface, texture, light). Removal + background rebuild is a native
  strength; an unnamed fill is the classic way invented content sneaks in.
- **Missing position** → choose a reasonable area from the composition (near the subject, empty
  space, centre/edges) and state it. Never leave placement open.

## 2. Text editing

- All text content goes in **English double quotes `" "`** — and is **never translated, never
  re-cased**: the original language and capitalization of the string survive exactly.
- **Text replacement always uses the fixed official template:**
  - `Replace "xx" to "yy"`
  - `Replace the xx bounding box to "yy"`
- **Unspecified text content → infer concrete strings** from the instruction and the image context,
  then commit them. Official example: "Add a line of text" (poster) →
  **`Add text "LIMITED EDITION" at the top center with slight shadow`**. Placeholders like
  "some text" or "relevant info" are forbidden.
- Specify **position, colour and layout** for every text element in detail.
- Scope check: zh/en only, and keep strings short — long/dense text is an official weak spot of
  this model.

## 3. Human editing

- **Maintain the person's core visual consistency**: ethnicity, gender, age, hairstyle, expression,
  outfit — everything the edit does not target stays named as staying.
- Modified appearance elements (clothes, hairstyle) must stay **consistent with the original
  style** of the image.
- **Expression changes must be natural and subtle, never exaggerated.**
- **Unless deletion is explicitly asked, the most important subject of the image (person, animal)
  is preserved.** For background-change tasks, state subject consistency **first**.
- Canonical official example:
  - "Change the person's hat" → **"Replace the man's hat with a dark brown beret; keep smile,
    short hair, and gray jacket unchanged"**
- Edit-Turbo runs with guidance off — there is **no image-guidance dial** to protect identity.
  The preservation clause *is* the identity lock. Field reports confirm instructions that state
  both what changes **and** what is preserved ("preserve his face, goatee and smile") are the
  consistently successful shape.

## 4. Style transformation / enhancement

- **A named style gets described** with its key visual traits — the inverse of the T2I rule:
  - "Disco style" → **"1970s disco: flashing lights, disco ball, mirrored walls, colorful tones"**
- **"Use reference style" / "keep current style"** → analyze the input image, extract its main
  features (colour, composition, texture, lighting, art style) and write them into the
  instruction.
- **Colorization / old-photo restoration always uses the fixed official template, verbatim:**
  - EN: `Restore old photograph, remove scratches, reduce noise, enhance details, high resolution, realistic, natural skin tones, clear facial features, no distortion, vintage photo restoration`
  - ZH: `修复老照片，去除划痕，降低噪点，增强细节，高分辨率，真实效果，自然肤色，五官清晰，无畸变，复古照片修复`
- If the request combines style with other changes, **the style description goes at the end**.

## Rationality and logic checks (official)

- Contradictory instructions ("remove all trees but keep all trees") → correct them logically,
  pick the reasonable reading, state it as a decision.
- Missing key information → supplement from the image context (see positions above).

## Language rules

- **Instruction prose follows the user's language**: Chinese in → Chinese out; English in →
  English out (the upstream rewriter ships both system prompts and selects by language). Other
  input languages → write the instruction in English, keeping user-given quoted strings verbatim.
- **Quoted in-image text keeps its own language and capitalization forever** — never translated,
  never "improved".
- Output is the **rewritten instruction only**: no guiding, explanatory or analytical words
  around it.

## Formatting rules

- One instruction, plain prose; short sentences; no line-break theatre, no headings inside.
- No resolution/aspect/pixel text in the instruction — sizing is reported beside it.
- No negation phrasing for content (name what is present, not what is absent); the sole exception
  is the restoration template, which is quoted verbatim as official.
- No weighting syntax, no tag lists, no quality boosters.

## Canonical full-shape example (background replacement)

```text
Keep the person completely unchanged — face, hairstyle, expression, outfit, pose and the lighting on him — and replace the background with a sunny beach at golden hour, the sand and surf continuing the existing light direction and warm tone, his contact shadow preserved. Keep the original composition and framing.
```

Anatomy: **preservation clause first → the operation with committed specifics → physical
coherence of the new region (light, shadow, continuation) → framing lock.**

## Failure modes to check for

| Failure | Symptom in your draft | Fix |
|---|---|---|
| T2I habits leaked | Prompt is a passive observer description, or a Minimal-Edit pass-through of a vague request | Write an operation-led, detailed instruction |
| Under-specified edit | "add an animal", "change the background" left as-is | Minimal-but-sufficient detail: category, colour, size, orientation, position |
| Identity drift risk | Person/product edit with no preservation clause | Add explicit keep-clauses (guidance is off — wording is the only lock) |
| Unnamed fill | "remove the dog" with nothing after it | Say the area is rebuilt as a continuation of the surrounding surface/light |
| Text drift | Quoted string translated, re-cased, summarized, or placeholder copy | Verbatim quotes, fixed replacement template, concrete inferred strings |
| Style left as a name | "in disco style" with no traits | Describe key visual traits; put style last when other changes exist |
| Restoration improvised | Hand-rolled cleanup wording | Use the fixed official template verbatim |
| Foreign contract bleed | `<image1>` tags, wh_ratio JSON fields, negative prompts, steps/CFG advice beyond 4/1.0 | Single image, natural wording, affirmative phrasing, official defaults only |
| Ratio in prose | "make it 16:9 4K" | Move to the sizing decision; warn that canvas changes fight the edit |
