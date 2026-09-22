# Task recipes — Boogu-Image-0.1-Edit-Turbo (single-image editing only)

Skeletons, not scripts. Fill every bracket; delete clauses the task does not need. Exactly **one**
input image — refer to it naturally ("in the image", "图中"), never with `<imageN>` tags. Every
recipe ends with the preservation wording the guidance-free model needs.

Out of scope, refuse and redirect: pure text-to-image (→ Boogu-Image-0.1-Turbo/Base), multi-image
composition or try-on from a second reference (the model supports one reference image only),
mask-based inpainting workflows (describe the region in words instead).

---

## 1. Object addition

```text
Add <one specific object: category, colour, size, material> <precise placement: in the bottom-right corner, on the tabletop left of the cup>, <orientation and pose: sitting and facing the camera>. The added object matches the scene's existing <lighting direction, perspective and style> and casts a <soft contact shadow consistent with the existing light>. Keep everything else in the image unchanged.
```

Vague requests get minimal-but-sufficient detail (official example: "Add an animal" → a
light-gray cat, bottom-right corner, sitting, facing the camera). Meaningless requests ("add 0
objects") are flagged, not rendered.

## 2. Object removal

```text
Remove <the named object> and cleanly rebuild the vacated area as a natural continuation of the surrounding <surface: the plaster wall, the grass, the tabletop> with matching <texture, lighting and shadow gradient>. Keep all other content, the subject, framing and lighting unchanged.
```

Always name the fill. Removal + background rebuild is a native strength — but an unnamed gap
invites invented content.

## 3. Replacement

```text
Replace <Y: the named target, positioned> with <X: key visual features — category, colour, material, scale>. <X> sits in the same position and perspective, lit consistently with the scene. Keep <the person's face, hairstyle, expression and outfit / the rest of the image> unchanged.
```

Official shape: "Replace Y with X" + X's key visual features.

## 4. Background / scene replacement

```text
Keep <the subject> completely unchanged — <face, hairstyle, expression, outfit, pose, product markings> and the lighting on it, including its contact shadow — and replace the background with <specific scene, time of day, palette>. The new background continues the existing <light direction and colour temperature> so the composite reads as one exposure. Keep the original composition and framing.
```

Official rule: for background changes, **subject consistency comes first** — literally first in
the sentence.

## 5. Human appearance edit (clothing, hair, accessories)

```text
Replace the <garment/hat/hairstyle> with <target: colour, material, style — consistent with the image's original style>; keep <smile, short hair, gray jacket — the untouched identifiers> unchanged.
```

Official example: "Change the person's hat" → "Replace the man's hat with a dark brown beret;
keep smile, short hair, and gray jacket unchanged". New elements must match the original style of
the image.

## 6. Expression / pose change

```text
Change <the expression to a subtle, natural <target: faint smile, relaxed gaze> | the pose so that <concrete body description, simple and unoccluded>> while preserving the person's <ethnicity, gender, age, hairstyle, facial identity, outfit> exactly. Keep background, framing and lighting unchanged.
```

Expression changes: **natural and subtle, never exaggerated** (official). Poses: keep them simple
and separated — complex interaction/occlusion is an official weak spot. Face preservation across
pose changes is a reported strength; texture fidelity on skin/fabric is a reported weakness —
name texture when it matters ("visible skin texture, crisp denim weave").

## 7. In-image text replacement

```text
Replace "<original string, verbatim>" to "<new string>" in the same <position, font style, weight, colour, size and capitalization>, keeping the surrounding <surface/layout> intact. Keep every other element unchanged.
```

Fixed official template — `Replace "xx" to "yy"` (or `Replace the xx bounding box to "yy"`).
Never translate or re-case either string; zh/en only; keep strings short.

## 8. Adding text to an image

```text
Add text "<exact inferred string>" at the <position: top center>, in <colour, weight, font style, relative size>, <layout notes: slight shadow, letter spacing>. All other text and content in the image stays unchanged.
```

Unspecified content → infer a concrete string from the instruction and image context (official
example: "Add a line of text" on a poster → "LIMITED EDITION" at the top center with slight
shadow). No placeholders, ever.

## 9. Style transformation

```text
<The operation on content, if any>, then render the image in <the named style, described by key visual traits: "1970s disco: flashing lights, disco ball, mirrored walls, colorful tones">. Keep <the subject's identity, pose and the composition> recognizable.
```

Named styles are **described** (edit-mode rule — the opposite of the family's T2I convention).
"Keep current style" / "use reference style" → extract the input's colour, composition, texture,
lighting and art style into words. Style description goes **last** when other changes are present.

## 10. Old-photo restoration / colorization (fixed template — verbatim)

```text
Restore old photograph, remove scratches, reduce noise, enhance details, high resolution, realistic, natural skin tones, clear facial features, no distortion, vintage photo restoration
```

ZH equivalent (use when the user writes Chinese):

```text
修复老照片，去除划痕，降低噪点，增强细节，高分辨率，真实效果，自然肤色，五官清晰，无畸变，复古照片修复
```

This is the one official string that contains quality words and a negation — do not edit it, do
not extend it, do not improvise substitutes. Additional requested changes go around it as
separate concrete clauses.

## 11. Attribute / material modification

```text
Change <the named attribute: the car's paint, the mug's material> to <target state, pushed concretely: deep metallic blue with fine flake, matte black ceramic>, keeping the object's <shape, position, scale, reflections and the scene lighting> consistent. Keep everything else unchanged.
```

## 12. Sizing decision (reported beside the instruction, never inside it)

- **Default:** `follow input image` — the pipeline keeps the input's aspect ratio
  (`align_res=True`), 1K class (the officially recommended checkpoint; a 1.5K hotfix exists).
- **Only on explicit request for a different frame:** one `wh_ratio` from 1:1, 2:3, 3:2, 3:4,
  4:3, 1:2, 2:1, 9:16, 16:9 — and warn the user that re-framing while editing is harder for the
  model than an in-place edit; expect composition drift.
- Input handling note for the user's runtime (not for the instruction): keep
  `max_input_image_pixels` at the pretraining max (2048×2048) — a lower cap silently downscales
  and produces a blurry upscale.
