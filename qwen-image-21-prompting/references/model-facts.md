# Qwen-Image-2.1 — verified model facts

Everything the prompt writer needs to know about the target model, and nothing else.
Checked against the official model card, the official repo, the upstream Diffusers integration
and the official ComfyUI templates (links at the bottom).

## Identity

- **Qwen-Image-2.1**, released **2026-09-20**. One set of weights does **both** text-to-image
  generation and instruction-based image editing — you do not swap checkpoints between the two.
- Lineage: the original **Qwen-Image** (20B MMDiT + Qwen2.5-VL encoder) → **Qwen-Image-2.0**
  (Feb 2026; first with native 2K, RGBA transparency and 10-reference editing) → **2.1**, which keeps
  the 2.0 task surface but replaces the visual generation side with the smaller component below.
- **7B parameters in the visual generation component**; 32 single-stream DiT (block-causal
  transformer) layers. Prompt **and** condition images are encoded **together** by a Qwen3-VL
  language/vision encoder (the ComfyUI repackage ships it as `qwen3vl_8b`), then the target is denoised
  with a flow-match Euler scheduler.
- Because text and images share one joint encoding, the model reads *which* reference supplies
  *which* content, and **the order you pass images in is the order the model reads them**
  (block-causal attention: later blocks and the target attend to earlier blocks).

## Task surface (what a prompt can ask for)

| Capability | Notes for prompting |
|---|---|
| Text → image | Full scene/page/poster generation, native 2K |
| Instruction edit of one image | "Change the background to a sunset beach" |
| Multiple reference images | **Up to 10** condition images; `image_1` is the edit target/canvas in ComfyUI, the rest are material/style references |
| Localized editing | Describe the object/region to change; the rest is preserved. Regions may be indicated by **circles, painted annotations, or separate mask images** fed as extra references |
| Identity / product fidelity | People and products are preserved across edits unless explicitly targeted |
| Native transparency (RGBA) | The VAE carries **4 channels**: transparent backgrounds are generated and edited directly, and subjects can be extracted from photos |
| Improved typography | Dense small text, complex layouts, portrait lighting and fine texture are the stated focus of this release |

## Sampling defaults (official)

| Parameter | Default | Guidance |
|---|---|---|
| `num_inference_steps` | **40** (Diffusers); ComfyUI template ships at 25; official note says ~40–50 with `euler` | Fewer steps with more advanced samplers |
| `true_cfg_scale` / `cfg` | **1.0 — guidance is off by design** | A `negative_prompt` is **ignored** unless `true_cfg_scale > 1`, and enabling it doubles work per step |
| `negative_prompt` | — | Effectively unused. Do not write prompt text *for* a negative prompt; express unwanted content positively ("plain seamless backdrop", not "no clutter") |
| `output_resolution` / `resolution` | Diffusers `width`/`height` default **2048 x 2048**; ComfyUI edit template: 1024, or 0 = keep each reference image's own size (rounded to 32) | Budget in total pixels, aspect preserved; round to multiples of 32 |
| `use_kv_cache` | true | Prefix KV-cache reuse is an architecture feature; keep the prompt+references **prefix stable** across iteration steps so it can be cached |
| `num_images_per_prompt` | 1 | |

**Consequence for prompts:** guidance-free, instruction-following, language-model-encoded. That means
well-formed natural prose beats tag soup, and quality boosters ("masterpiece", "8K", "highly detailed",
"trending on artstation") are pure noise — the official rewriting spec explicitly bans them.

## Runtime notes (ComfyUI, for the sizing/sampling advice only — this skill never runs it)

- Native support since **ComfyUI 0.37.0**; three official templates: **Text to Image**, **Image Edit**,
  **Remove Background** (the last one is just the RGBA extraction recipe as a workflow). Templates sample
  `euler` + `simple` at **25 steps, cfg 1**, and load the `int8 convrot` repackage from
  `Comfy-Org/Qwen-Image-2.1`.
- T2I uses a Resolution Selector (ratio × megapixel target, 1.0 MP ≈ 1024x1024; ~4.0 MP for a real
  2048x2048). Edit keeps `custom_size` off by default: the output follows `image_1`'s aspect ratio scaled
  to ~`resolution`² (default 1024); with `custom_size` on, stay close to the resized `image_1` size or
  the edit shifts.
- A **Qwen Image 2.1 Cache** node controls the prefix KV cache (`device` auto/gpu/cpu/off, `dtype`
  default/int8/int4 — int4 roughly doubles per-step error). This is why keeping the prompt+reference
  prefix stable across iterations is cheap.
- Reference images are downscaled to ≤ 1024x1024 px before the encoder sees them (matching training);
  pre-resize oversized references — they only slow generation down, they add nothing.
- The model weights are under the **Qwen Research License Agreement** (this skill's text is MIT).

## Early field reports (community, as of 2026-09-21 — not official docs)

- **Stay in the 2K native size class.** Pushing well past the ~2048 training resolution destabilises
  exposure; the recommended size table below is the safe envelope.
- **CFG below 1 is not usable.** cfg 1 (guidance off) is the intended operating point; when in-image text
  needs to be sharper, users report success with a small cfg above 1 plus a quality-focused negative
  prompt — at the documented cost of doubling per-step work. Default advice stays: no negative prompt.
- **Style transfer through a reference image is the least dependable operation**; style described *in
  words* transfers reliably. When a `<imageN>` style reference under-delivers, reinforce (or replace) it
  with explicit textual style descriptors — medium, palette, line weight, rendering technique, era.

## Native output sizes (recommended, 2K class)

```text
1:1    2048 x 2048        3:2    2528 x 1696        9:16   1536 x 2752
4:3    2400 x 1792        2:3    1696 x 2528
3:4    1792 x 2400        16:9   2752 x 1536
```

For ~1 MP drafts halve each side and round to a multiple of 32. In image-edit mode the safest canvas is
**the input image's own aspect ratio** (`ratio_follow`); a custom size that drifts away from the resized
input makes the edit shift.

## Hard "never put these in the prompt" list

- **No** resolution, aspect ratio or pixel counts in the prompt string (`"16:9"`, `"1920x1080"`,
  `"2K"`). They belong in the sizing decision. `"2K"/"4K"/"8K"` in a user request are *quality* wishes,
  never ratio signals.
- **No** negative prompt blocks, no weighting syntax `(word:1.2)`, no `--ar`, no tag-list boilerplate.
- **No** newline-separated sections inside the final prompt string — one paragraph (multi-paragraph is
  allowed only for region-stacked layouts such as multi-panel pages, see t2i reference).

## Reference-image addressing

- Multi-image (N ≥ 2): refer to each input as `<image1>`, `<image2>`, … **exactly** — never "the first
  image", "图1", "image A", "the second one". This tag format is mandatory.
- Single image (N = 1): **do not** use tags; refer to it naturally ("in the image", "the input photo").
- Give every image a role (canvas vs material source vs style source), describe each referenced image
  individually, and never compress several into a range ("images 1–3").
- The ComfyUI loader node exposes `image_1` … `image_16` slots, but the model card's documented limit is
  **10 references**; stay within 10 and keep tags ≤ `<image10>`.
- Upstream examples show the short natural-language form too ("Put the flowers from the first image into
  the second scene"); the `<imageN>` tags are what the official rewriting spec and ComfyUI templates
  standardize on, so prefer tags whenever N ≥ 2.

## Transparent-image prompt shape

```text
This is an RGBA image with transparency. <your description>. The image has alpha channel and the background is transparent.
```

Save as PNG to keep the alpha channel.

## Sources

- Model card + repo (introduction, capabilities, RGBA prompt format, aspect ratios, prompt-rewriting
  models, official system prompts): <https://huggingface.co/Qwen/Qwen-Image-2.1>,
  <https://github.com/QwenLM/Qwen-Image-2.1>
  (`prompt_rewrite/prompts/system_prompt_t2i.txt`, `system_prompt_edit.txt`)
- Diffusers integration (joint Qwen3-VL encoding, block-causal ordering, defaults 40 steps / no
  guidance, `negative_prompt` gating, multiple condition images):
  <https://huggingface.co/docs/diffusers/main/api/pipelines/qwenimage21>, diffusers PR #14804
- ComfyUI Day-0 templates (10 reference images, `<image1>`… addressing, `image_1` as edit target,
  resolution/canvas behaviour, cfg/steps notes, RGBA note):
  <https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1>,
  `Comfy-Org/workflow_templates` → `image_qwen_image_2_1_t2i.json`, `image_qwen_image_2_1_image_edit.json`
- Blog announcement: <https://qwen.ai/blog?id=qwen-image-2.1>
- ComfyUI launch post + runtime detail (templates, weights, cache node, resolution behaviour):
  <https://blog.comfy.org/p/qwen-image-21-in-comfyui-open-weight>; early-user field reports:
  <https://comfyui-wiki.com/en/news/2026-09-21-qwen-image-2-1>

*Documented 2026-09-21 against the 2026-09-20 release. If the model is updated, re-check the model card
and the two `system_prompt_*.txt` files, which are the authoritative prompting contract.*
