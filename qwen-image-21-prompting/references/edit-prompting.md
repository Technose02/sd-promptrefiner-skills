# Editing rules — Qwen-Image-2.1

Distilled from the official Qwen-Image-2.1 prompt-rewriting spec for editing
(`prompt_rewrite/prompts/system_prompt_edit.txt` in the upstream repo) and the official
Diffusers / ComfyUI editing examples. An input image is **always** present in this mode — the job is to
clarify and constrain an edit, never to invent a picture from nothing.

## The governing principle: attribute disentanglement at full strength

> **Edit exactly the attribute(s) the user named, push each to a strong and unmistakable degree, and
> hold everything else at input fidelity.**

Both halves matter, and the two failure modes are symmetric:

- **Leakage** — touching what the user did not name: a sharpen that re-grades colour, an upscale that
  reframes, a style change that drifts a face, an outfit swap that drops an accessory, a background
  change that "helpfully" cleans up something unmentioned.
- **Under-editing** — an output a viewer could mistake for the unedited input, because the requested
  change was applied faintly.

**Preservation locks content, never edit strength.** Recognisability is bought by naming what stays
fixed, not by holding the effect back. Write "make the headlights twice as bright and clearly
glowing, everything else unchanged", not "slightly brighten the headlights".

## How much to build: intent-branched

- User wants ***this picture changed*** (local object/attribute/background edit, in-image text or UI
  edit, quality/style pass, viewpoint or canvas transform) → **clarify and constrain**: say exactly what
  changes, and let everything else stand.
- User wants ***a new picture of this subject*** (subject placed in a new scene, compositing across
  images, a photo-shoot / poster / infographic built from a reference) → **construct actively**: design
  the scene, lighting, composition and layout to a professional standard.
- Scale the elaboration to what was asked: a plain placement stays restrained; a styled shoot or a
  publication-grade poster gets built out fully.

## Anchor on the image; decide the rest

**Anchor what you read.** Every spatial, tonal and contextual claim must come from what is visibly
there. If you are unsure a detail exists, leave it out — a preserved element described at a higher
level of abstraction is always safer than an invented specific.

**Split the work: the LLM reasons, the diffusion stage renders.** Diffusion-model text encoders
never "reason" — they follow instructions. So:
- **Into the prompt (LLM's job):** concrete observable facts that the agent extracts by looking:
  text strings (quoted verbatim), object counts and placement, colours, materials, lighting
  direction, poses, expressions, spatial layout. These help the model place, light and relate
  objects correctly.
- **Carried by the reference image (diffusion's job):** fine-grained identity and preservation
  that the pixel signal serves better than words — facial proportions, exact product markings,
  subtle material texture, the input's rendering medium. The prompt says "keep the person's
  facial identity from <image2>" but does not try to narrate every contour.
- When in doubt about which side a fact belongs on, ask: *"Can the LLM extract and commit this
  with high confidence, and does the model need it in text to render correctly?"* If yes →
  write it. If the reference image already carries it adequately and a textual duplicate would
  risk contradiction or drift → point at the image.

**Say what stays, without repainting it.** Name untargeted content by type, position and role rather
than by appearance, and prefer **one blanket preservation clause** over walking the frame. A preservation
description reads to the model as a *generation* instruction: the more concretely you describe something
you meant to keep, the more likely it drifts. Describe appearance concretely only for what you are
actually changing, or when it is the only way to disambiguate between two similar objects.

**Identity is the hardest invariant.** A person's facial identity and the personal accessories that make
them recognisable; a product's exact design, markings and count; and the input's rendering medium
(photograph, anime, illustration, sketch, 3D render, painting) all survive every edit unless the user
explicitly targets them. **When identity comes from a reference image, point at that image
(`<image2>`) rather than describing features in words** — verbal descriptions make the model regenerate
and degrade the likeness.

**Resolve ambiguity, then commit.** Turn vague intent, imprecise spatial reference and unparameterised
style words ("make it more professional", "a bit older", "cinematic") into concrete, observable
properties; translate abstract quality language into the visual properties it implies. Where the
instruction offers alternatives or contradicts itself, pick the most reasonable reading and state it as
a decision — no hedging, no unresolved either/or in the output. Keep the user's own action verb, spatial
relations and described state intact, and treat anything they asked to preserve as absolute. Preserve
creative or physically impossible intent rather than "correcting" it.

**Only what was asked.** Do not add operations the user did not request, and do not clean up
unmentioned defects, overlays or clutter however prominent they look. When an edit removes, moves or
reveals something, **say enough about the newly exposed region** that the result stays physically
coherent (what is behind it, how it continues, how light falls on it).

**Text in the image is literal.** Whenever readable text will appear in the output, commit to the exact
characters — every element, quoted, nothing summarised or abbreviated. **Text you cannot commit to
should not be added at all.** Match the typography and language the input establishes unless the user
asks otherwise. When the operation extends the canvas outward, name it as **outpainting** explicitly.

**Write it as an instruction.** Lead with the operation, not a description of the finished picture, and
write from the perspective of someone holding only the input image(s).
Good openers: `Change …`, `Replace …`, `Remove … and fill …`, `Keep … unchanged, add …`,
`Translate …`, `Extend …`.

## Two separate language decisions (never conflate them)

**(A) Language of the prompt's descriptive prose** — everything *outside* double quotes, i.e. what you
write for the model:

- instruction in Chinese → prose in Chinese
- instruction in English → prose in English
- instruction in **any other language** (Japanese, Korean, French, Spanish, Thai, …) → prose in **English**

**(B) Language of the text rendered *into* the image** — the content *inside* double quotes, decided in
strict priority order:

1. The user gave the exact text, or named a target language for it → render exactly that.
2. Otherwise, the input image already contains text → use the **dominant language of the image's
   existing text**, even when the instruction is in a different language.
3. Otherwise (image has no text, user named no language) → use **the language of the user's
   instruction**, including Japanese, Korean, Thai, Arabic, French. Do not force it to English.

*Worked example:* the image is mostly Thai, the instruction is in English and asks to add/redesign a
title without giving the words or a language → the quoted (rendered) text must be **Thai**, while the
surrounding prose stays **English** (decision A).

Reinforcements on (B):

- All rendered text is **monolingual** — no mixed Chinese-and-English inside one quoted string, and no
  bilingual pairs unless the user explicitly asks for one.
- **Genre never overrides input language.** A "spec sheet / technical document / storyboard /
  cinematic data-page" look is achieved through layout and typography, not by switching labels to
  English. Every header, label and caption stays in the decided language; standardised units and
  user-given proper nouns may remain Latin.
- Run a **language purge last**: re-scan every double-quoted string and remove translation glosses,
  parentheticals and mixed-script leftovers.

## Multi-image reference rules

For N ≥ 2 the rewritten instruction **must** address each input as `<image1>`, `<image2>`, … This
tagging format is mandatory and non-negotiable.

- Do **not** use natural-language references: "the first image", "image A", "图1", "第一张图".
- For N = 1, do **not** use tags — refer to the image naturally ("in the image", "图片中").
- Up to **10** reference images. Order is contractual: the encoder reads blocks in the order you pass
  them, and `image_1` is the edit target in the official ComfyUI workflow.
- **State each image's role explicitly**: which one is the canvas whose composition and untargeted
  content survive, and which supply material to transfer, and what is taken from each. For scene
  generation with no canvas (a group photo, 合影), all images serve as identity sources.
- Describe every referenced image individually — never collapse several into a range or a group
  ("images 1-3", "the reference photos") to avoid one-by-one description.
- Keep the reference order identical to the upload order; a mismatch silently swaps roles.

## <a id="canvas-mapping"></a>Canvas mapping (which image the output follows)

| Edit type | Canvas — the image whose composition/framing survives |
|---|---|
| Compositing: transfer a subject into a scene ("put X into Y", "把A P到B中") | the **target scene** image |
| Face / head swap | the **body** image |
| Clothing swap / try-on | the **person** image |
| Style transfer ("paint it in X's style") | the **content** image, *not* the style reference |
| Background replacement | the **foreground subject** image |
| Local object replacement | the image being edited |
| Scene generation with no canvas (合影, "let them have dinner together") | **none** — you must choose a ratio |

## Sizing decision (reported beside the prompt, never inside it)

Two mutually exclusive fields, exactly as the official refiner emits them:

- `wh_ratio`: `"16:9"`, `"1:1"`, … → then `ratio_follow` is empty
- `ratio_follow`: `"<imageN>"` → then `wh_ratio` is empty

**Step 1 — did the user specify a size or ratio?** Exact pixels (`1920x1080` → reduce to `16:9`),
explicit ratios (`4:3`), or descriptive terms:

| Cues | `wh_ratio` |
|---|---|
| square, avatar, profile picture, album cover, 头像, 正方形 | `1:1` |
| landscape, desktop wallpaper, widescreen, video thumbnail, PPT/slide, 横版, 电脑壁纸 | `16:9` |
| portrait, phone wallpaper, Instagram story/Reels, short-video cover, 竖版, 手机壁纸 | `9:16` |
| iPhone full-screen | `18:39` · Android full-screen | `9:20` |
| ultrawide, 带鱼屏 | `7:3` · cinematic / 宽银幕 / cinemascope | `21:9` |
| poster, 海报 | `2:3` · ID/passport photo, 小红书 | `3:4` |
| tablet / iPad screen | `4:3` · panoramic / 全景图 | `2:1` |
| business card | `9:5` · A4 portrait | `5:7`, A4 landscape | `7:5` |

**`2K` / `4K` / `8K` are quality descriptors, not ratio indicators** — never let them set the ratio;
output stays at the 2K class regardless.

**Step 2 — nothing specified:**

- **Single image, ordinary edit** → `ratio_follow = "<image1>"` (follow the input's resolution).
- **Single-image scene generation** (input used only as an identity reference: "拍一套写真",
  "cosplay 成 X", "穿越到古代") → **do not** follow the input ratio; the output is a new composition.
  Portrait/写真 → `2:3`; full-body scene / outdoor activity → `3:4`; landscape-oriented scene → `3:2`;
  no orientation hint → follow `<image1>`.
- **Multi-image** → `ratio_follow = "<canvas image tag>"` from the mapping table above.
- **Scene generation with no canvas** → pick `wh_ratio`: group photo/合影 `3:2` · portrait/写真 `2:3` ·
  poster `2:3` · desktop wallpaper `16:9` · phone wallpaper `9:16` · otherwise follow the **last** input
  image.
- **Outpainting (扩图)** → never simply follow the input ratio; outpainting changes proportions by
  definition. Estimate ~30–50 % extra space per direction: right/left only → wider (1:1 → `3:2`;
  3:4 → `1:1` or `4:3`); both sides → `16:9` or `2:1` from 1:1; up/down only → taller (1:1 → `2:3`;
  16:9 → `4:3` or `1:1`); both → `9:16` from 1:1; **all sides → keep the original ratio**.
- **Panorama** → standard/360° `2:1`, ultra-wide `3:1`, otherwise the user's ratio.
- **Three-view / multi-panel grids** → derive from subject shape × panel arrangement: a standing person
  in 1×3 → `1:1` (do **not** over-widen to `3:1`, which squashes portrait panels); a car in 1×3 → `3:1`
  or `9:2`; 2×2 or 3×3 of square content → `1:1`.

## Prompt-string formatting rules

- **One continuous paragraph** — no line breaks, no headings, no bullet lists inside the prompt.
- Visible, readable text in **double quotes**; descriptive/structural language that never appears as
  rendered text is **not** quoted.
- **Never** put resolution, aspect ratio or pixel counts in the text (`"2:3"`, `"1920x1080"`, `"2K"`) —
  those live in the sizing fields.
- Write strings out in full — no ellipsis, no truncation, no "etc.".
- **State requirements affirmatively** — `keep the background and input identical` rather than
  `forbid changing the background`. Standard preservation phrasing (`keep X unchanged`) is correct.
  A single explicit guard against the model's known temptations (no new text, no logos, no watermarks)
  is acceptable when the task is prone to it, but do not turn the prompt into a list of prohibitions.
- Precise and decisive: no hedging, no unresolved alternatives, no vague degree words left unquantified.
- Proper nouns and domain terms keep their original language, inside English double quotes.

## Thinking order before you answer

1. What the image(s) actually contain — **including a complete reading of every text string present**.
2. What the user is asking for, and which attributes that names.
3. What must therefore stay fixed.
4. The output size decision (`wh_ratio` vs `ratio_follow`).
5. The composed directive.

Final gate: every visible element is either the target of the edit or covered by what stays fixed ·
the requested change is unmistakable · nothing outside the target was touched · every quoted string
obeys language decision (B).

## Canonical official example (two-image try-on)

```text
Keep the character and pose in <image1> unchanged, put this light blue denim shirt from <image2> on the character, preserve the original facial features, hair, body shape and pose, the denim shirt fits naturally on body, realistic denim fabric texture, natural clothing folds, keep the original background and original lighting, high fashion editorial photography, sharp details
```

Read its anatomy: **canvas + what survives → the operation, with the source tagged → identity clauses →
physical plausibility of the transferred item → blanket preservation → style/quality tail.**

## Failure modes to check for

| Failure | Symptom in your draft | Fix |
|---|---|---|
| Leakage | You described, "improved" or removed something the user never mentioned | Delete it; one blanket preservation clause instead |
| Under-editing | "slightly", "subtle", "a bit" | Push to a strong, observable degree and keep preservation intact |
| Repainting the keep-list | Three sentences about the background you meant to preserve | Name by type/position/role only |
| Verbal identity | "her almond-shaped hazel eyes…" for a face that exists in `<image2>` | Point at the tag |
| Unnamed fill | "remove the lamp" | Say what replaces it |
| Committed-text drift | "add a caption about the offer" | Quote the exact string, or add no text |
| Tag violation | "the first picture", or `<image1>` in a single-image edit | Tags iff N ≥ 2 |
| Ratio in prose | "in 16:9, 4K" | Move to the sizing decision |
| Bilingual quotes | `"夏日特惠 / SUMMER SALE"` | One language per string, per decision (B) |
| Style won't take | Style lives only in a `<imageN>` reference | Reinforce with word-level style descriptors (medium, palette, line weight, era) |
| Unrequested cleanup | "tidy the cluttered desk" wasn't asked | Leave the clutter exactly as is |
