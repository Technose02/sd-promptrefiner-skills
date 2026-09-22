# Pre-flight checklist and output contract — Boogu-Image-0.1-Edit-Turbo

Run every gate **before** answering. Anything unchecked is a bug in the instruction, not a caveat
to tell the user about.

## Contract with the user

Your reply is instruction text only — no inference, no calls to diffusers/ComfyUI/any client, no
image generation, and never a render "to check". Deliver:

1. **Mode** — always `edit` (one instruction + exactly one input image). Out of scope, refuse and
   redirect: pure text-to-image (Boogu-Image-0.1-Turbo/Base), multi-reference composition (this
   model takes one reference image only).
2. **Instruction** — one fenced `text` block, ready to paste.
3. **Sizing** — `follow input image (1K class)` by default, or `wh_ratio: "X:Y"` from the nine
   supported ratios when the user explicitly asked for a different frame (with the drift warning).
4. **Sampling note** (one line, only when settings are in scope) — steps 4 · text/image CFG 1.0 ·
   negative instruction inert · 1K hotfix checkpoint recommended.
5. At most three short rationale bullets. No lecture, no restating the instruction twice.

If the request is genuinely ambiguous, pick the most reasonable reading, commit it, and flag the
choice in one bullet — the instruction itself never hedges and never contains unresolved
alternatives.

## Gates

### Scope and family

- [ ] Exactly one input image, referenced naturally ("in the image", "图中") — no `<imageN>` tags,
      no multi-image wording, no mask/annotation-image assumptions.
- [ ] Request is an edit, not a generation (T2I ⇒ refuse-and-redirect).
- [ ] This model's contract only: detailed operation-led instruction — **not** the family T2I
      Minimal-Edit pass-through, **not** another family's dense-observer description.
- [ ] Identity-critical or texture-critical job ⇒ expectations set (official consistency caveat;
      reported fabric/skin softness). Strict-preservation workloads warned about.

### Image analysis (the skill reasons; the diffusion encoder never does)

- [ ] Every visible element in the input image that is relevant to the edit has been read and
      accounted for — objects (count, colour, material, placement), people (pose, expression,
      hair, clothing), text (every string, verbatim, with position and style), lighting
      (source, direction, quality), composition.
- [ ] Extracted facts that the model needs to render correctly are committed in the instruction
      (text strings, object counts, colours, materials, spatial layout, lighting).
- [ ] Fine-grained identity/preservation that the reference image carries better than words is
      left to the reference image — not narrated in pixel-level detail.
- [ ] Unreliable readings are hedged rather than invented; only verifiable facts are asserted.
- [ ] If in-image text exists and is relevant, every character has been read and quoted exactly.

### Instruction shape

- [ ] Operation-led and detailed: task type, target entity, position, quantity, attributes all
      committed; short sentences; no padding.
- [ ] Core intention unchanged; no unrequested operations, no cleanup of unmentioned content.
- [ ] Vague inputs resolved to minimal-but-sufficient specifics (category, colour, size,
      orientation, position); contradictions corrected and committed.
- [ ] Additions fit the scene's logic, style, lighting and perspective; contact shadows and
      reflections accounted for.
- [ ] Removals name the fill: the vacated area rebuilt as a continuation of the surrounding
      surface/texture/light.
- [ ] Replacements use "Replace Y with X" + X's key visual features.
- [ ] Preservation clause present for every person/product edit — face, hairstyle, expression,
      outfit, markings named as unchanged (guidance is off; wording is the only identity lock).
- [ ] Background changes put subject consistency **first**.
- [ ] The most important subject survives unless its deletion was explicitly requested.
- [ ] Expression changes subtle and natural; poses simple and unoccluded.

### Text edits

- [ ] Every string in English double quotes, verbatim — never translated, never re-cased.
- [ ] Text replacement uses the fixed template (`Replace "xx" to "yy"`).
- [ ] Unspecified copy inferred into concrete committed strings; no placeholders ("some text",
      "relevant info").
- [ ] Position, colour, weight/font and layout given for every text element.
- [ ] Strings short; zh/en only — other languages warned about.

### Style / restoration

- [ ] Named styles described by key visual traits (not left as bare names); style placed last when
      other changes are present.
- [ ] "Keep/use current style" → input image's colour, composition, texture, lighting, art style
      extracted into words.
- [ ] Restoration/colorization uses the fixed official template verbatim (EN or ZH by the user's
      language) — the sole allowed exception to the no-quality-words and no-negation rules.

### Prompt string hygiene

- [ ] No resolution/ratio/pixel counts in the instruction ("16:9", "1024x1024", "2K/4K").
- [ ] No negative instruction, no negation phrasing for content; everything affirmative.
- [ ] No weighting syntax, no `--ar`, no tag soup, no quality boosters.
- [ ] Prose language matches the user's input language (zh→zh, en→en, other→en with verbatim
      quotes).
- [ ] Sizing decision present and from the supported set (default: follow input).
- [ ] Sampling advice, if given, matches the official defaults: 4 steps, CFG 1.0,
      `dmd_conditioning_sigma` 0.0, input pixel cap at pretraining max.

## If the result looked "close but wrong" (diagnose from the instruction, not the render)

| Symptom | Instruction cause | Fix |
|---|---|---|
| Face/identity drifted | No preservation clause (or the edit description drowned it) | Explicit keep-clauses first; likeness, not pixel-lock — warn if a hard lock is required |
| Untouched areas changed | Instruction described the whole scene instead of the delta | Name only the target + preservation; delete scene re-description |
| Invented content in a gap | Removal without a named fill | Describe the rebuilt continuation |
| Edit too timid / didn't happen | Vague verb or hedged wording | Commit the operation: concrete target, position, degree |
| Text garbled, translated or re-cased | String not quoted verbatim / too long / non-zh-en | Verbatim short quotes, fixed template, language warning |
| Style didn't land | Style left as a bare name | Describe its key visual traits; move style clause last |
| Output blurry at full size | Runtime `max_input_image_pixels` below the input size | Tell the user to restore the 2048×2048 pretraining cap (runtime fix, not instruction) |
| Whole image black | `--enable_torch_compile` on some GPUs | Tell the user to disable torch compile (runtime fix, not instruction) |
| Composition shifted | A custom ratio was forced during the edit | Default to follow-input; re-frame only on explicit request, with warning |
