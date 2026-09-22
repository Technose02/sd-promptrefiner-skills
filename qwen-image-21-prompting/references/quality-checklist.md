# Pre-flight checklist and output contract

Run the relevant block **before** answering. Anything unchecked is a bug in the prompt, not a caveat
to tell the user about.

## Contract with the user

Your reply is prompt text only — no inference, no calls to diffusers/ComfyUI/the project client,
no image generation. Deliver:

1. **Mode** — one of `t2i`, `t2i-rgba`, `edit-1`, `edit-N`, `extract`.
2. **Prompt** — one fenced `text` block, single paragraph, ready to paste.
3. **Sizing** — `wh_ratio: "X:Y"` **or** "follow `<imageN>` (the canvas)", never both.
4. **Sampling note** (one line, only when settings are in scope) — steps 40 · `true_cfg_scale` 1.0 ·
   negative prompt unused unless guidance is switched on.
5. At most three short rationale bullets. No lecture, no restating the prompt twice.

If the request is genuinely ambiguous about *which* region or *which* text the user means, do not ask a
question with an obvious best reading — pick the most reasonable interpretation, commit it, and flag the
choice in one bullet.

## Every mode

- [ ] Correct mode classified (image present ⇒ edit; absent ⇒ t2i).
- [ ] The prompt is one paragraph, no line breaks, no lists, no headings.
- [ ] No resolution, aspect ratio or `2K/4K/8K` text inside the prompt string.
- [ ] Every string that must be **visible in the output** is inside `"double quotes"`, written in full
      (no ellipsis, no "etc.", no "a caption about…").
- [ ] Nothing is quoted that is *not* rendered text (structural language stays unquoted).
- [ ] No weighting syntax `(word:1.2)`, no `--ar`, no negative-prompt blocks, no tag soup.
- [ ] No quality boosters (`masterpiece`, `best quality`, `ultra-detailed`, `8k`, `trending on
      artstation`) — 2.1 encodes with a VLM and treats them as noise.
- [ ] Sizing decision present, with the ratio vocabulary mapped (avatar→1:1, wallpaper→16:9/9:16,
      poster→2:3, ID photo/小红书→3:4, story→9:16, cinematic→21:9, panoramic→2:1, A4→5:7/7:5).
- [ ] Reference order in the prompt matches the order images will be supplied in.
- [ ] Nothing invented that the user did not ask for (no unrequested cleanup, no extra objects).
- [ ] Positive presence used where the user wants absence ("plain seamless backdrop" instead of
      "no clutter") — except a single explicit no-new-text/logo guard when the task invites it.

## Edit modes (`edit-1`, `edit-N`, `extract`)

### Image analysis — skill reasons, diffusion never does

- [ ] Every visible element relevant to the edit has been read from the reference image(s) —
      objects (count, colour, material, position), people (pose, expression, hair, clothing),
      in-image text (every string, verbatim, with position and style), lighting (source,
      direction, quality), composition, rendering medium.
- [ ] LLM-extracted facts that the model needs to render correctly are committed in the prompt
      text (text strings, object counts, colours, materials, spatial layout, lighting direction).
- [ ] Fine-grained identity/preservation is left to the reference image (point at `<imageN>`)
      rather than narrated in pixel-level detail — "facial identity from <image2>" not
      "almond-shaped hazel eyes".
- [ ] Unreliable or ambiguous visible elements are hedged rather than invented ("appears to be
      dark navy", "a label too small to read").
- [ ] Every image has been inspected for in-image text regardless of whether the user mentioned
      it — text present in the input must be addressed in the edit (preserved, changed, or
      explicitly replaced).

### Instruction shape

- [ ] The operation leads the sentence ("Change…", "Replace…", "Remove… and fill…", "Keep… unchanged, add…").
- [ ] Requested change is pushed to a **strong, observable** degree — no "slightly", "a bit", "subtle".
- [ ] One blanket preservation clause exists and names the canvas plus the invariants
      (identity, pose, background, framing, lighting, rendering medium).
- [ ] Preserved elements are named by **type/position/role**, not repainted with appearance detail.
- [ ] Identity is anchored by image tag, not by a verbal description of the face/product.
- [ ] Any newly exposed region is described enough to stay physically coherent.
- [ ] N ≥ 2 ⇒ every image referenced as `<image1>`…`<image10>` only, each with an explicit role,
      none collapsed into a range; N = 1 ⇒ **no** tags, natural wording only.
- [ ] Region hints (circle/paint/mask image) are bound to the target and explicitly excluded from the
      output ("the annotation itself is not visible in the result").
- [ ] In-image text follows decision **(B)**: exact text if user-given → else the input image's
      dominant language → else the instruction's language. Prose follows decision **(A)**.
- [ ] Monolingual quotes; no bilingual pairs or translation glosses; units and proper nouns may stay Latin.
- [ ] Typography of surviving/edited text matched to the input unless the user asked otherwise.
- [ ] Outpainting is named as outpainting, and the ratio was inferred from the extension direction
      instead of `follow <image1>`.
- [ ] Sizing picked per the canvas mapping (style transfer → content image; face swap → body image;
      try-on → person image; compositing → scene image; background swap → subject image).
- [ ] RGBA / extraction task states the transparency requirement and preserves edge detail.

## Generate mode (`t2i`, `t2i-rgba`)

- [ ] Written as an **observer describing the finished frame** — present tense, third person, no
      "create/make sure/the model should", no echoed meta-instructions from the user.
- [ ] Opening sentence (~20 words) names medium + style + subject + background/palette; the medium noun
      ("photograph", "poster", "illustration", "infographic", "logo"…) is never omitted.
- [ ] 8–14 positional phrases, reaching corners, edges and centre, not clustered in the middle.
- [ ] Walk order matches the frame type: background first, then top band → left → centre → right →
      bottom for layouts; background → pose/placement → head → body → held objects → edges for a
      single subject.
- [ ] ~⅓ of sentences open on the positional phrase.
- [ ] Lighting accounted for explicitly (source, direction, quality, shadows/highlights), either its own
      sentence or folded into the surface it defines.
- [ ] Exactly one closing step-back sentence ("The overall composition…"); no second summary.
- [ ] Length ~400–500 words / ~20 sentences for a full scene (shorter for a genuinely quiet subject);
      a thin brief still buys a dense description.
- [ ] Colours carry modifiers; materials named (brushed metal, coarse linen, frosted glass); counts as
      words; no "several items" / "various decorations".
- [ ] People: build, posture, gaze, expression, hair, skin tone, garments with colour+material; age as a
      life stage or decade, never a number; if the face is turned away/cropped, say so.
- [ ] Objects by class, not brand, unless the user named the brand.
- [ ] Physically coherent: shadows away from the light, reflections matching, consistent scale.
- [ ] Ambiguity hedged ("appears to be", "wood or dark laminate") except where the user fixed it.
- [ ] Non-readable incidental text described as blurred/indistinct rather than invented.
- [ ] Prose in English; quoted in-image text in its own script.
- [ ] RGBA wrapper present when transparency was requested, and no background surface described inside it.

## If the result looked "close but wrong" (diagnose from the prompt, not the render)

| Symptom | Prompt cause | Fix |
|---|---|---|
| Untouched areas drifted | Preservation clause absent, or the keep-list was re-described in detail | One blanket clause; strip appearance detail |
| Change too faint | Hedged degree words | State the target property strongly and observably |
| Wrong face / product | Identity narrated in words | Point at `<imageN>` |
| Text garbled or in the wrong language | String not committed, or decision (B) violated | Quote exact characters; re-derive the language |
| Background survived a swap | Canvas image tag wrong / reference order mismatch | Re-check canvas mapping and upload order |
| Composition shifted while editing | Custom size far from the resized input | Follow `image_1`'s aspect; keep the pixel budget close |
| Model invented clutter | Unnamed empty area, or "add some details" | Commit every element, or explicitly describe the plain area |
| Whole image restyled when only a region was wanted | Region not bound to a hint or spatial clause | Name the region and lock "every pixel outside it" |
