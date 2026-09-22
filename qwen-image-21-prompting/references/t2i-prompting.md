# Text-to-image prompts for Qwen-Image-2.1

Use for `t2i` and `t2i-rgba`. Distilled from the official Qwen-Image-2.1 T2I rewriting spec
(`prompt_rewrite/prompts/system_prompt_t2i.txt` in the official repo).

## What a perfect 2.1 T2I prompt is

**One long English paragraph that describes the finished image as if you were looking at it** —
an observer reporting what is in the frame. Not a brief to a renderer, not a note to the user.

- ~20 sentences, ~400–500 words, ~25 words per sentence. A three-word request and a three-hundred-word
  request both become a description of the same size: **a thin brief means you are inventing most of
  the frame, not writing less.**
- **English, always**, whatever language the request arrives in. The only exception is text that will be
  *shown inside* the image, which stays in its own script.
- Present tense, third person, declarative. No "create", no "make sure", no "the AI should", no "you".
- No quality boosters: no "masterpiece", "8K", "highly detailed", "award-winning", "trending on
  artstation".

## The eight steps

### 1 — Split the brief into fixed and open

**Fixed** (survives unchanged): every text string to be shown (copy it **character for character**,
in its own script, including punctuation and spacing), every named object, every count, every stated
colour, every stated position, the aspect ratio if given.

**Open** (you must decide): everything unmentioned. Decide it; do not leave holes.

**Meta-instructions** are not content: "use double quotes", "no hard-edged blocks", "make the text
sharp" — obey them silently, **never echo them** into the description. The description states what is in
the frame, never what must be done.

### 2 — Fix the frame (ratio)

Use the user's ratio if stated. Otherwise `3:2` for anything horizontal, `2:3` for anything vertical —
these are the two defaults. `1:1` for a square badge, icon, album cover, single centred emblem;
`16:9` for a wide cinematic or presentation frame; `9:16` / `1:2` for a phone screen or tall standing
banner. `3:4`, `4:3`, `2:1`, `21:9`, `4:5`, `3:1`, `5:4`, `1:3`, `9:21` exist but only when the subject
or user really calls for them.

The ratio lives **only** in the sizing decision. Never write a ratio, resolution or pixel count into
the description.

### 3 — Write the opening sentence (~20 words)

Name **medium, style, subject, background/palette**, usually orientation too:

```text
The image is a ⟨vertical|wide|square⟩ ⟨style⟩ ⟨photograph · poster · illustration · scene · portrait · infographic · close-up · graphic · page · card · sheet · logo⟩ of ⟨subject⟩, ⟨background and palette⟩.
```

`"This is a …"` or a bare `"A vertical realistic photograph of …"` work equally well. **The medium noun
is the one part that is never omitted.** The style word goes here — realistic, photorealistic,
minimalist, flat-vector, cinematic, watercolour, isometric, editorial, hand-drawn, 3D-rendered, retro —
named once, optionally echoed in the closing sentence.

### 4 — Inventory before writing

Settle two lists first:

- **Every element, with a place in the frame**: upper-left, across the top, on the far right, in the
  lower third, in the centre, in front of, behind, tucked into the corner. You need **8–14 positional
  phrases** (~10 typical) and they must reach the **corners, edges and centre** — not cluster in the middle.
- **Every piece of legible text, in reading order.**

### 5 — Walk the frame

**Region-divided frame** (poster, page, interface, layout, wide multi-element scene) → walk the regions:
1. background and the surface it sits on — **immediately after the opening sentence, not at the end**;
2. the top band (headline, header bar, sky, ceiling);
3. down and across the body: left side, then centre, then right side — one or two sentences per region;
4. the bottom band (footer, foreground, ground plane, base row).

**One subject fills the frame** (portrait, close-up, single object) → walk the subject:
background and how far it falls off → the subject's pose and placement → head and face → body and each
garment or surface → what is held or touching it → whatever is left at the edges. Keep using positional
phrases *inside* the subject ("in the upper-left of the frame", "behind the left shoulder", "along the
lower edge") so the frame stays locatable.

Roughly **a third of your sentences open on the positional phrase itself**. One paragraph, except when
the image is genuinely built from stacked regions (panels, cards, sections, slides) — then one paragraph
per region, each opening with where that region sits.

### 6 — Set every piece of text

Skip if nothing is meant to be read — **a third of images have no legible text, and inventing signage for
them is a mistake.** Otherwise, for each string in reading order: where it sits, what it looks like, what
it says — `a bold black headline across the top reads "SUMMER SALE"`.

- Straight **double quotes**, in its own script: Chinese, Russian, Korean, Japanese, Arabic text stays in
  that script.
- Give weight, colour, case and relative size.
- Describe a line break as a second line; never put a real newline inside the string.
- If a mark is not meant to be read (distant signage, a label behind glass, dense body copy) call it
  **blurred / indistinct / too small to read** rather than inventing letters.
- Charts and tables: axes, tick labels, legend entries, series and cell values are text — write them out.

### 7 — Give the lighting its own sentence

Every image has light in it, and it is always accounted for: **source, direction, quality, and the
shadows and highlights it leaves.** Either a dedicated `"The lighting is …"` sentence after the contents
are placed, or folded into the sentence of the surface the light defines. Never left implied.

### 8 — Close with the whole frame

Exactly one step-back sentence:

```text
The overall composition ⟨is / uses / feels⟩ …
```

`"The composition is …"`, `"The overall design …"`, `"The overall mood …"`, `"The overall palette …"`,
`"The image has …"` are the same move. Cover balance and symmetry, palette, style, mood. **One** such
sentence — no second summary.

## Throughout (voice rules)

- **Hedge what you cannot be certain of.** `"appears to be"`, `"likely"`, `"suggesting"`, and offer a
  pair for genuinely ambiguous things (`"a notebook or a tablet"`, `"wood or dark laminate"`). Do this
  often — it is the natural register here. Be flatly definite **only** about what the user fixed.
- **Name colours with a modifier**, almost never bare: deep navy, muted olive, pale cream, warm
  terracotta, soft dusty rose, blue-grey, off-white, charcoal, brownish-green. Hex codes only if the
  user supplied them.
- **Give the material, not just the noun**: brushed metal, matte plastic, glossy ceramic, coarse linen,
  weathered wood, frosted glass, grain, scuffs, condensation, visible brush strokes, paper fibre.
- **Enumerate; never summarise.** `"several items"` and `"various decorations"` are not descriptions.
  Small counts as words (three, five, twelve); if something is partly hidden, say so and describe the
  visible part.
- **People get their observable surface**: build, posture, where they are looking, expression, hair, skin
  tone, each garment with colour and material. Age is a life stage or a decade (a child, a teenager, a
  young adult, middle-aged, elderly, in her thirties) — **never a number of years**. If a face is turned
  away or cropped out, say that instead of describing it.
- **Objects by class, not brand** — a silver laptop, a mirrorless camera, a compact hatchback — unless the
  user named the brand. Photographic and design vocabulary is welcome: shallow depth of field, bokeh,
  backlit, close-up, negative space, grid, drop shadow.
- **Everything holds together physically**: shadows fall away from the light, reflections match what is in
  front of the surface, scale is consistent between neighbours, surfaces react to what sits on them. If
  the user asked for something impossible, describe it as the image shows it and let the rest of the
  scene stay coherent around it.

## RGBA variant

Wrap the finished description in the documented transparency frame (and keep the rest of the rules):

```text
This is an RGBA image with transparency. <the full observer description>. The image has alpha channel and the background is transparent.
```

For a cut-out subject, the "background" step of the walk becomes the alpha region: describe the subject's
edge quality instead — clean silhouette, soft hair fringe, no halo, no backdrop plane — and do **not**
name a surface, room or gradient behind it. Save/serve as PNG to retain alpha.

## Good / bad contrast

**Bad (typical tag soup):**
```text
cyberpunk noodle stall, night, masterpiece, ultra detailed, 8k, bokeh, --ar 16:9
```

**Good (shape to imitate — short version of the ~450-word target):**
```text
The image is a wide cinematic photograph of a late-night cyberpunk noodle stall squeezed into a tiled Tokyo side street, soaked asphalt reflecting magenta and teal signage under a low, rain-darkened sky. The wet street and its rippled reflections fill the lower third of the frame, leading the eye to the stall: a compact stainless cart with a wooden counter, a canted vinyl awning, and a single sheet of steaming broth poured over a wire strainer at its centre. Across the top, a sagging fabric banner reads "ラーメン" in faded white brush strokes, and to its right a vertical neon sign spells "夜食" in magenta tubing, one letter flickering half-lit. On the left side of the frame, a middle-aged cook in a white undershirt and navy apron lifts a basket of noodles, his face turned toward the pot and away from the camera; a stack of used bowls and a worn cash box sit tucked into the corner beside him. In the lower-right foreground, a young customer in a clear plastic raincoat hunches over a bowl, chopsticks raised, breath visible in the cold. The lighting is hard and mixed — a bare bulb above the cart, neon spill from the right, and pale steam catching both — casting short specular highlights on wet metal and long soft shadows under the awning. The overall palette is deep navy and charcoal punctured by magenta and teal, with heavy bloom in the lights and a shallow depth of field that dissolves the far end of the street into round bokeh.
```
