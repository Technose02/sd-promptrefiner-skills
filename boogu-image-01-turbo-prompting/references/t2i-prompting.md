# Text-to-image prompts for Boogu-Image-0.1-Turbo

Turbo is generation-only. Distilled from the official T2I rewriting spec shipped in the repo
(`utils/t2i_external_prompt_rewriter.py`, `T2I_REWRITE_SYSTEM_PROMPT_EN/_ZH` — itself adapted by the
Boogu team from Qwen-Image's official rewrite prompt, then inverted in one crucial way: restraint).

## The governing principle: Minimal-Edit

> **The goal of rewriting is to help the model paint better, not to make the prompt longer.**

- If the original prompt is already clear with a well-defined subject — even very short ("a cup of
  coffee", "a kingfisher perched on a branch") — **barely change it**: at most add one style word.
  Never fabricate scenes, props, actions or atmosphere the user did not mention.
  **The test: remove the phrase you are about to add — does the picture still hold up? If yes, do
  not add it.**
- Only when the prompt is genuinely too abstract, lacks a subject, or cannot be turned into an image
  ("fruit that is destined with Newton") do a substantive expansion — and then invent the *minimum*
  concrete scene that resolves the abstraction.
- Rewritten length stays **roughly comparable to the original**. If the original is already detailed
  (a long keyword list counts as detailed), only tidy word order and normalize format — do not
  append new strings of terms.
- Short, concise sentences. No over-detailing, no repetition, no adjective piles. For synonymous
  terms ("realistic texture, photographic texture, absolutely real") keep **one**.
- Canonical pass-throughs from the official spec: "Two people drinking coffee." → **"Two people
  drinking coffee."** · "The UN logo." → **"The UN logo."**

**Important exception — layout/text-graphic images** (flowcharts, infographics, architecture
diagrams, posters, menus, UI): these are *exempt* from conciseness. They must be **extremely
detailed** — every node's text, arrow direction, connection relationships, module hierarchy and
layout position written out (see the text and product/ad rules below).

## Language rules

- **The prompt's language matches the user's input language**: English in → English out; Chinese in
  → Chinese out. (This differs from other model families — do not port their always-English rule.)
  Other input languages → write the prose in English, but keep user-given in-image text verbatim.
- **In-image text is Chinese or English only** (the model's optimized range). If the user wants text
  rendered in another language, warn that it will likely degrade, and offer an zh/en equivalent or
  decorative (illegible-by-design) treatment.
- **Unspecified cultural context defaults to Chinese**: when the prompt names no country, region,
  culture, character identity or setting, complete it with a Chinese context; when the user stated
  one, preserve it strictly.
- Classical Chinese poetry prompts → emphasize classical Chinese elements; avoid Western, modern or
  foreign scenery.

## Style rules

1. **User named a style → keep the style name only** (Ghibli, Hayao Miyazaki, pixel art,
   Impressionism, Pop Art, ink wash, cyberpunk…). Do **not** append a description of what the style
   looks like.
2. **No style named → choose from the content's semantics**, per the official defaults:
   - myths/legends, anthropomorphic animals, purely fictional fantasy → illustration or painting;
   - cartoon / illustration / 2D animation → add "bright saturated colors";
   - historical figures, period costume, ancient scenes → **realistic photographic style with
     real-person texture** (not ink-wash/gongbi);
   - posters, UI, infographics → keep design style, never convert to real photography;
   - anything else unclear → realistic.
3. **Everyday realistic subjects need no style word.** For ordinary objects, people, animals,
   landscapes, food: do **not** add "realistic photographic style" — the model defaults to realistic
   anyway. Say it only when the subject is easily misjudged (e.g. a historical figure that might
   come out ink-washed).
4. **Style is named once.** Never add camera/photography parameters the user didn't write (35mm,
   85mm, f/1.8, shallow depth of field, soft focus, cinematic lighting, bokeh) — keep them only if
   already in the original prompt.

## In-image text rules

- Text the user asked for goes in **quotation marks, unaltered**, with its **position** (top-left,
  bottom-right…), colour, style, size and font described around it. For a real existing logo, do
  not describe its text — name the logo (canonical-name rule below).
- **Ambiguous text becomes concrete**: "the invitation has the name and date written on it" →
  commit actual strings ("the lower part of the invitation reads \"Name: Zhang San, Date: July
  2025\""). Never leave "writes relevant information", "several icons", "selling-point copy" as
  placeholders — either write every string out in full or drop the text.
- **Except for text the user explicitly asked for, add no text at all.**
- Dense-text ambition check: Turbo handles simple and moderate text well; for ultra-dense
  documents/tiny fonts/complex multilingual layouts, tell the user Base@2K is the officially
  recommended tool and keep the Turbo prompt's text load modest.

## Faithfulness rules

- **Counts and arrangements are strict.** "seven", "three rows and four columns" → execute exactly,
  and describe each subject **one by one in a fixed order** (left to right, top to bottom), each
  with its own distinguishing detail.
- **Logical relationships survive.** "a food chain on the grassland" → the rewrite contains arrows
  expressing the chain, with each icon and arrow described.
- **No negation words anywhere in the prompt.** "no chopsticks" → the word chopsticks never appears.
  State only what is present. (Turbo runs at CFG 1.0, so a negative prompt cannot help either.)
- Preserve the user's own detail level: heavy expansion of an already-detailed prompt is a
  spec violation, not thoroughness.

## Real entities, celebrities, brands

- Fixed-appearance IP (brand logos, real products, celebrities, anime/film/game characters):
  refer by **canonical name only**; never add or infer appearance details (text, colours, shapes,
  facial features, clothing, logo style). The model's world knowledge is limited — describing a
  real entity's looks produces confident wrongness.
- Celebrity prompts include the celebrity's **Chinese and English names**.
- If faithful brand/celebrity likeness is business-critical, set expectations: this is an official
  known limitation (world knowledge gap), not a prompt defect.

## Safety rule (from the official spec)

If the request involves pornographic or sexually explicit content, the rewrite becomes a safe,
non-explicit scene while preserving as much as possible of the original's picture type, composition,
style, colour tone and subject count; illegal/criminal acts are rewritten into legal professions,
public-service or safety-education framings.

## Voice

- Short declarative sentences; plain, concrete nouns; one style word; committed specifics for
  everything the user fixed.
- No hedging in the delivered prompt, no meta-instructions echoed ("use double quotes", "make the
  text sharp" are obeyed silently, never written into the description).
- No quality boosters ("masterpiece", "8K", "best quality") — MLLM-encoded model, they are noise.
  The allowed quality words are exactly: "cinematic", "premium texture", "refined" — sparingly.

## Good / bad contrast

**Bad (inflated — violates Minimal-Edit):**
```text
A stunning, high-end cup of coffee with premium feel and visual impact, cinematic lighting, 35mm, shallow depth of field, bokeh, masterpiece, 8K, rustic wooden table, morning sunlight streaming through a window, steam swirling artistically, cozy café atmosphere in the background
```
*(user only said "a cup of coffee" — every added phrase fails the remove-it test)*

**Good (spec-shaped):**
```text
A cup of coffee.
```

**Bad (placeholder text):**
```text
Hand-drawn student flyer, with childlike handwriting and several selling points and relevant information about the waffle sale, decorated with some elements, light paper texture background
```

**Good (every string committed, layout exception applied):**
```text
Hand-drawn style student flyer, with childlike handwriting that reads: "We sell waffles: 4 for $5", with small text in the bottom-right noting "benefiting a youth sports fund". The main subject is a brightly colored waffle illustration, decorated with simple elements: stars, hearts, and small flowers. The background has a light paper texture.
```
