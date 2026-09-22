# Task recipes (edit + generate)

Skeletons, not scripts. Fill every bracket; delete any clause the task does not need —
unused boilerplate is leakage risk. `<imageN>` tags only when N ≥ 2.

---

## 1. Local attribute change

```text
Change only <the named object/attribute> in <image1|the image> to <target state, pushed unmistakably strong: exact colour, material, form>. Keep <the person's facial identity, hairstyle, pose, the background, the camera angle and the existing lighting> exactly as in the input. Match the input's rendering medium, grain and perspective; the newly altered area continues the surrounding <light/shadow/occlusion> consistently.
```

Local edit — do **not** describe the preserved regions' appearance, and do not add new elements.

## 2. Object addition

```text
Add <one specific object: material, colour, scale> <precise placement: resting on the lower-right of the table, in front of the window>. The added object casts a <soft contact shadow consistent with the existing key light> and its <scale and perspective> match the surrounding scene. Keep everything else in <image1|the image> unchanged.
```

## 3. Object removal (and what to fill)

```text
Remove <the named object> and fill the vacated area with <what is physically there: the continuation of the light grey plaster wall, its existing texture and the shadow gradient falling from the left>. Keep all other content, framing and lighting unchanged.
```

Always name the fill. Leaving it unnamed invites invented content.

## 4. Background / scene replacement

```text
Keep <the subject: person/product> unchanged — identity, edges, scale, lighting on it, and its contact shadow — and replace the background with <specific scene>. Match the new background's <light direction, colour temperature and depth of field> to the subject so the composite reads as one exposure. Keep the original composition and camera framing.
```

## 5. Virtual try-on / outfit swap

```text
Keep the character and pose in <image1> unchanged, put the <garment, colour, material> from <image2> on the character, preserve the original facial features, hair, body shape and pose, the <garment> fits naturally on the body, realistic <fabric> texture, natural clothing folds, keep the original background and original lighting, <style anchor such as high fashion editorial photography>, sharp details.
```

(Shape taken from the official ComfyUI Qwen-Image-2.1 image-edit template.)

## 6. Face swap / identity transfer

```text
Replace the face and head of the person in <image1> with the person from <image2>, preserving the facial identity, hairstyle, hairline, skin tone and any distinguishing marks of <image2> exactly. Keep <image1>'s body, clothing, pose, hands, framing, background and lighting unchanged. Blend the new head into the existing neck and shoulder lighting so the skin tones and shadow directions match.
```

Point at `<image2>` for identity; do **not** narrate the face in words.

## 7. Multi-reference composition (product / person / scene)

```text
Image roles: <image1> is the final canvas — its composition, framing, scale and lighting survive. <image2> supplies <product: preserve its exact shape, colour, material, proportions, markings and count>. <image3> supplies <environment/style>. Place <item from image2> <position>, <contact/shadow/reflection requirement>. Do not add any new text, logos, watermarks or extra products.
```

Declare every role in the first sentence, in upload order. Never compress several images into
"the references".

## 8. Group shot / scene generation from identity references (no canvas)

```text
These <n> characters, taking each one's facial identity, hairstyle, build and outfit from <image1> … <imageN> respectively, <shared action: sit around a campfire in a pine forest at dusk>. Assign each character an explicit position in the frame — <left, centre-left, …> — with correct occlusion and overlapping shoulders, all lit by the same <warm firelight from below-left plus cool ambient dusk from above>. Sizing: `wh_ratio` 3:2.
```

No `ratio_follow` here: there is no canvas.

## 9. In-image text editing / translation

```text
Replace the existing <element: headline, price tag, subtitle> reading "<original string>" with "<new string, in the input image's dominant language>" set in the <same/specified typeface, weight, case and size>, aligned to the same baseline and optical position, on the same <surface/material>, keeping its perspective, lighting, texture and any occlusion by foreground objects intact. Keep every other element of the image unchanged.
```

Translation-only variant: `Translate all visible text in <image1|the image> into <target language>, keeping each text block's position, typography, scale and colour identical, and preserving the layout without overflow or truncation.`

## 10. Poster / infographic / UI page from a reference

```text
Use <image1> as the <canvas|identity source> and lay out a <poster/spec sheet/storyboard> titled "<title>". Sections, in order: a top band with <headline string> in <weight/size relative to the title>; a left column listing <each label and value, quoted>; a right panel showing <the subject from image1> at <scale>; a footer strip reading "<caption>". <grid/margin/alignment system, palette, typographic hierarchy — one accent colour>. All rendered text stays in <decided language>, monolingual.
```

Name **every** string; anything you cannot name must not be added.

## 11. Style transfer

```text
Render the content of <image1> — subject, composition and spatial layout preserved exactly — in the style of <image2>, adopting its <palette, brush/rendering technique, line weight, surface treatment, era>. Keep the identity, pose and relative scale of <the main subject> intact. Do not change the framing or add elements.
```

The **content** image is the canvas, never the style image. Reference-only style transfer is early users'
least dependable 2.1 operation: if the style must land reliably, reinforce `<image2>` with explicit
word-level style descriptors (medium, palette, line weight, rendering technique, era) — described style
transfers more dependably than pointed-at style.

## 12. Quality / restoration / relight (no content change)

```text
Increase the <sharpness/detail/resolution> of <image1|the image> and <optional: re-grade>, pushing <the specific quality: crisp fabric weave and visible skin texture, clean specular edges> to a clearly visible degree, while holding composition, framing, subject identity, colours and lighting direction fixed. Do not add or remove objects, text, logos or watermarks.
```

Push strength explicitly — preservation wording must not mute the effect.

## 13. Pose / viewpoint transform

```text
Rotate the <object/person> in <image1|the image> to <target viewpoint: three-quarter view from the left, facing 45° right>, keeping <identity, clothing, materials, scale, background, lighting rig and camera height> unchanged; the newly visible surfaces continue the object's existing geometry, materials and wear plausibly.
```

## 14. Outpainting / canvas extension

```text
Extend <image1|the image> beyond its current frame as a natural outpainting: continue the <floor, wall, ceiling, foliage, light gradient> outward <on the right side / downward / on all sides>, keeping the existing pixels, subject placement, perspective lines, scale and lighting untouched. Sizing: `wh_ratio` per the extension direction (see edit-prompting.md).
```

Name the operation as **outpainting**, and set the ratio yourself — never `ratio_follow`.

## 15. Transparent output (RGBA)

- From text: `This is an RGBA image with transparency. <description of the subject alone, with edges, materials and internal lighting>. The image has alpha channel and the background is transparent.`
- From an image: `Extract <the subject> from <image1> and output it on a fully transparent background, preserving its exact silhouette, fine edge detail such as hair strands and fabric fuzz, existing lighting, colour and material; the background area becomes transparent.`
- Editing a transparent layer: `Keep the alpha channel and the subject's silhouette of <image1> unchanged; change only <the named part of the subject>.`

Save as PNG; alpha survives only there.

## 16. Iterative refinement chain

Feed the previous output as the next `image_1`, and restate the invariants each time:

```text
Building on the previous result, <the one remaining change>. Everything else from the input image stays unchanged, including <identity/product invariants you are protecting>.
```

One variable per iteration. Two simultaneous changes make a bad result un-attributable.

## 17. Three-view / multi-panel sheet

```text
Produce a <front / side / back> three-view sheet of <the subject from image1, or the described subject>: three equally sized panels arranged <side by side / in a 2×2 grid>, each showing the subject at the same scale, standing on an invisible ground line, identical <lighting direction and colour> in every panel, on a <flat neutral background>. Shared proportions across all views; no text labels unless you can name each label's exact string.
```

Ratio comes from subject shape × panel arrangement (tall standing figure, 1×3 → `1:1`; a car, 1×3 → `3:1`).
