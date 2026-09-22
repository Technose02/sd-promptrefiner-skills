# Task recipes — Boogu-Image-0.1-Turbo (T2I only)

Skeletons, not scripts. Every recipe obeys the **Minimal-Edit Principle**: fill the brackets with
what the user actually gave; add only what the frame cannot stand without. Delete unused clauses —
on this model, boilerplate is not neutral, it is a spec violation.

Turbo has no image input. Any request that starts from an existing picture ("edit this", "put X
into this photo", "remove the person from…") is **out of scope** — it belongs to
Boogu-Image-0.1-Edit / Edit-Turbo (a different model and contract). Say so and stop.

---

## 1. Simple subject (the default shape)

```text
<the user's own sentence, tidied>.
```

If the subject is clear, this is the finished prompt. Optionally one style word. Nothing else.

## 2. Photographic portrait / scene

```text
<photography|cinematic photography> style, <subject with the user's own attributes>, <composition: upper-body / medium shot / full-body>, <the setting the user named>, <lighting only if the user named it>.
```

Do not add camera parameters (35mm, f/1.8, bokeh…) unless the user wrote them. Give faces enough
frame share — the FLUX.1 VAE loses detail on small faces.

## 3. Multiple subjects with a fixed count/order

```text
<style>, <N> <subjects> <arrangement: standing side by side / three rows and four columns>, <frame: upper-body composition>, from left to right: the first <subject 1 with one or two distinguishing details>; the second <subject 2 …>; …; the <N>th <subject N …>. <background>, <lighting>.
```

Counts are strict; describe each subject one by one in a fixed order. Keep the group moderate and
poses unambiguous — multi-person interaction and occlusion are official weak spots.

## 4. Poster / product ad / e-commerce main image

```text
<bright, clean | moody | …> <product>-poster, <colour scheme>, <background design fitting the product's style and use scene>, <layout: text-above-image / left-text right-product>. At the top center is the main title "<exact title string>", in <font weight/size/colour, e.g. bold large sans-serif>. Below it the subtitle "<exact subtitle string>" in smaller font. <Middle band: each icon/selling point, left to right, labeled "<string 1>", "<string 2>", …>. Below, centered, <the product with its materials and colours>, <props>. <style tail: gentle and fresh / professional and high-end>.
```

Design scenes are the **detail exception**: layout structure, product position, every text block's
content + position + style, colour scheme and icon meanings must all be explicit. If the user did
not ask for much text, keep the text concise — do not invent a wall of copy.

## 5. Logo

```text
<subject> logo design, <simple modern | badge | hand-drawn …> style, the main element is <the described mark: shapes, colours, materials>, <container: inside a circular badge with a <border description> | free-standing>. Below the mark, in <colour> <sans-serif|serif> font, reads "<exact brand string>", <weight, alignment>. The background is pure white to highlight the logo subject. The overall design is <professional and high-end | playful …>.
```

A **real existing** logo ("the UN logo") is passed through by canonical name — never describe it.

## 6. Infographic / flowchart / diagram (hand-drawn or technical)

```text
<hand-drawn style | flat vector> <topic> <diagram/infographic>, <paper|background>. In the center <main layout element>; <region positions: the sun in the top-left, clouds in the top-right>. <Each flow element in order>: a <colour> arrow going <direction> from <node> to <node> is labeled "<exact label>", … . <Line quality, colour palette, label legibility>.
```

Every node's text, every arrow's direction and every label is written out — placeholders like
"relevant information" are forbidden. This is the one task type that should run long.

## 7. In-image text scene (signage, invitation, menu, card)

```text
<style: real photo | illustration>, <scene>, <surface: a sign hanging above the entrance / the lower part of the card> reads "<exact string>" in <colour, weight, case, font, e.g. medium-brown cursive>. <second surface> reads "<exact string>" in <style>. <the rest of the scene, minimally>.
```

Quote every string exactly, unaltered; ambiguous text becomes concrete; zh/en only; **no text the
user did not ask for**.

## 8. Stylized / fantasy / mythic scene

```text
<the named style, kept as a name only — e.g. ink wash, Ghibli, pixel art>, <scene and subject with the user's own imagery>, <atmosphere the user named>.
```

No style named: myths/legends and fantasy → illustration or painting; cartoons/2D → add "bright
saturated colors"; historical figures and period scenes → realistic photographic style with
real-person texture; poetry → classical Chinese elements, no Western/modern scenery; unspecified
cultural context → default Chinese context.

## 9. Real person / celebrity / known character

```text
<style>, <celebrity Chinese name> (<celebrity English name>), <the situation the user described>, <composition>.
```

Canonical names only — never describe their face, hair or outfit. Expect a world-knowledge gap;
if likeness is critical, set expectations or offer a described generic person instead.

## 10. Abstract or subjectless brief ("fruit destined with Newton")

Resolve to the **minimum** concrete image that answers the abstraction:

```text
<style>, <one concrete subject that embodies the idea: an apple resting on a closed physics tome beside a portrait-framed silhouette>, <the smallest setting that makes it readable>, <one lighting or mood line>.
```

Commit one reading; do not catalogue every possible interpretation, and do not build a whole world
around it.

## 11. Aspect-ratio decision (reported beside the prompt, never inside it)

| User cue | `wh_ratio` |
|---|---|
| nothing stated | `1:1` |
| portrait, phone wallpaper, full-body vertical, 竖版, 手机壁纸 | `9:16` (or `2:3` / `3:4` for less extreme) |
| landscape, desktop, wide scene, 横版, 电脑壁纸 | `16:9` (or `3:2` / `4:3`) |
| poster, 海报 | `2:3` |
| ID photo / 小红书-style card | `3:4` |
| tall standing banner / roll-up | `1:2` |
| panoramic strip | `2:1` |

Supported set only: 1:1, 2:3, 3:2, 3:4, 4:3, 1:2, 2:1, 9:16, 16:9. Resolution stays 1K-class on
Turbo — "2K/4K/8K" wishes are noted to the user, never written into the prompt, and ultra-dense
text at 2K is a Base-variant job.
