# Boogu-Image-0.1-Edit-Turbo — verified model facts

Everything the prompt writer needs to know about the target model, and nothing else.
Checked against the official model card, the official repo (`INFERENCE_GUIDE.md`,
`inference_ti2i_turbo_simple.py`, `boogu/pipelines/boogu/instruct_reasoner_static_skills.py` — the
shipped edit-instruction rewriter), the official ComfyUI docs and the technical report (links at
the bottom).

## Identity

- **Boogu-Image-0.1-Edit-Turbo**, released **2026-06-30**, weights refreshed by the
  **hotfix-20260708** revisions: `hotfix-1k-20260708` (**officially recommended** — more stable)
  and `hotfix-1k5-20260708`. The hotfix addressed severe image-quality degradation and poor
  performance on removal and other editing tasks — always assume hotfix weights.
- Apache-2.0 research project. Member of the **Boogu-Image-0.1 family**: Base (T2I), Turbo (T2I
  distilled), Edit (full editing model), **Edit-Turbo** (this model). 10B diffusion transformer,
  Qwen3-VL-8B instruction encoder, FLUX.1 VAE.
- **TI2I task**: one instruction + **exactly one input image** → edited output. Edit-Turbo is
  Edit + **Decoupled-DMD distillation** (4 steps, guidance off), shipped in diffusers as
  `BooguImageTurboPipeline` with `use_dmd_student_inference=True`.
- **Single reference image only.** Official: "Only support 1 reference image for now"; the turbo
  edit pipeline "focuses on editing with ONE reference image per sample". Multi-image composition,
  try-on-from-second-image and `<imageN>`-style addressing do **not** exist on this model.

## Task surface (what an edit instruction can ask for)

| Capability | Notes for prompting |
|---|---|
| Object insertion / replacement / removal | Removal rebuilds the background natively; replacement uses "Replace Y with X" + X's key visual features |
| Attribute / material modification | Colour, texture, material changes on named targets |
| Background / scene replacement | Subject-consistency clause comes **first** (official rule) |
| Style transformation / transfer | Named styles get **described** with key visual traits (opposite of the family's T2I rule) |
| In-image text editing | Replace/add/remove characters, **Chinese and English only**; quoted strings never translated, language and capitalization preserved |
| Old-photo restoration / colorization | One official **fixed template** (see edit-prompting.md) — use it verbatim |
| Human edits | Face/identity, hair, clothing, expression (expression changes must stay natural and subtle), pose changes |

## Sampling defaults (official)

| Parameter | Edit-Turbo value | Guidance |
|---|---|---|
| `num_inference_steps` | **4** | DMD-distilled; the 25–50 step schedules belong to Edit/Base — never advise them here |
| `text_guidance_scale` | **1.0** | "DMD path runs without CFG" |
| `image_guidance_scale` | **1.0** | Also off. The identity-lock trick of raising image guidance (1.5–3.0) exists **only on the non-distilled Edit variant**; on Edit-Turbo the prompt wording is the only identity lever |
| `empty_instruction_guidance_scale` | 0.0 | |
| `dmd_conditioning_sigma` | 0.0 | Per the official quickstart |
| `negative_instruction` | — (parameter exists, empty) | Inert while CFG is off. Never write negative prompts; state everything affirmatively |
| `height` / `width` | `None` → **follow the input image** (`align_res=True`, sizes aligned to multiples of 16) | Output keeps the input's aspect by default |
| Input caps | `max_input_image_pixels` 2048×2048, `max_input_image_side_length` 4096 (pretraining maxima) | Larger inputs are resized, aspect preserved. **Field report:** setting the pixel cap *below* the input's size silently produces a small latent upscaled into a blurry image — keep the pretraining max |
| Checkpoints | **1K** (recommended) and 1.5K hotfix revisions | 1K is the official stability recommendation; 2K is Edit/Base territory |

**Consequence for prompts:** guidance-free and instruction-encoded by an MLLM. Natural prose
instructions beat tag soup; there is no CFG dial to compensate for a vague instruction — precision
and explicit preservation wording must do all the work.

## Sizing decision (reported beside the prompt, never inside it)

- **Default: follow the input image** — the pipeline keeps the input's aspect ratio
  (`align_res=True`). Report as `follow input image (1K class)`.
- Only when the user explicitly asks for a different frame (outpaint-style extension, "make it a
  phone wallpaper"), report a `wh_ratio` from the nine supported ratios — **1:1, 2:3, 3:2, 3:4,
  4:3, 1:2, 2:1, 9:16, 16:9** — and warn that changing the canvas while editing is harder for the
  model than an in-place edit.
- **Never** write ratios, resolutions or pixel counts into the instruction ("16:9", "1024x1024",
  "1.5K", "2K", "4K"). "HD/2K/4K" wishes are quality words; note that the restoration template is
  the only place "high resolution" appears, because it is part of the fixed official string.

## Hard "never put these in the instruction" list

- **No** resolution, aspect ratio or pixel counts (see above).
- **No negative instructions and no negation phrasing** for content: name only what should be
  present ("a clean empty tabletop"), never what should be absent ("no clutter"). The single
  exception is the official restoration template, quoted verbatim, which contains "no distortion".
- **No weighting syntax** `(word:1.2)`, no `--ar`, no tag soup, no quality boosters
  ("masterpiece", "best quality", "8K").
- **No `<imageN>` tags or multi-image addressing** — there is exactly one input image; refer to it
  naturally ("in the image", "图中"). Tags from other model families are a foreign contract.
- **No translated or re-cased in-image text**: quoted strings keep their original language and
  capitalization exactly.

## Known limitations (official + dated field reports) — and prompt mitigations

| Limitation | Mitigation in the instruction |
|---|---|
| **Image-to-image consistency "still not stable enough"** for strict preservation of subject, identity, layout or fine details (official) | Always add explicit preservation clauses ("keep face, goatee and smile unchanged"); promise likeness, not pixel-perfect identity, and say so when the user needs a hard lock |
| No image-guidance identity dial on the distilled path (CFG off) | Preservation wording is the only lever — never omit it on people/product edits |
| **Texture quality** — fabrics and skin can come out softer than peers (field report, 2026-07) | When texture matters, name it ("crisp denim weave, visible skin texture"); manage expectations for fabric-heavy restyles |
| **World knowledge gap** (real brands, celebrities, landmarks) | Canonical names only, never describe a real entity's appearance; prefer described generics for branding |
| **Long/dense/small text** can typo, drop characters or drift; **only zh/en** optimized | Keep quoted strings short; commit every string exactly; other scripts → warn |
| **Body structure** in complex poses, occlusion, multi-person interaction | Simple, separated poses; describe the target pose concretely |
| **FLUX.1 VAE**: small faces, small limbs, eyes, tiny text may artifact | Give the edited subject enough frame share; avoid edits that shrink faces |

## Runtime/tooling notes (for advice only — this skill never runs any of it)

- **diffusers/PyTorch**: `inference_turbo.py --pretrained_pipeline_name_or_path
  models/Boogu-Image-0.1-Edit-Turbo --input_image_paths <img> --instruction "…"
  --dmd_conditioning_sigma 0.0` (steps/CFG baked in). Tested env: Python 3.10, CUDA 12.6,
  PyTorch 2.7.1. VRAM: ~24GB comfortable; 12–16GB with offload flags or fp8 checkpoints.
- **Prompt enhancement upstream**: `--use_rewrite_text_instruction True` with task type
  `image-editing`, presets `default` / `ppt` / `custom`, or DashScope remote rewriting. The edit
  system prompts live in `boogu/pipelines/boogu/instruct_reasoner_static_skills.py`
  (`REWRITE_SYSTEM_PROMPT_4_EDIT_EN/_ZH`) — see [prompt-enhancer.md](prompt-enhancer.md).
- **ComfyUI**: native support since 2026-06-17 (Comfy-Org repackage `Comfy-Org/Boogu-Image`;
  `TextEncodeBooguEdit` node takes the instruction, a negative-prompt slot (inert at CFG 1) and
  the optional reference image). The `ComfyUI-Boogu` custom-node repo is legacy — use native nodes.
- **Torch compile caveat**: `--enable_torch_compile` can produce all-black outputs on some
  GPUs/models — if a user reports a black image, suggest disabling it first.
- Accelerators: vLLM-Omni, TeaCache/TaylorSeer caching, NPU via the `npu` branch.

## Field reports (community, dated 2026-09-21 — not official docs)

- Edit-Turbo **preserves faces across pose changes better than several larger peers**, while fabric
  and skin texture quality trails them (r/StableDiffusion, 2026-07).
- Localized edits (colorize, add glasses, change clothing, swap background) are "reliable and
  clean"; removal + background rebuild works from a single plain sentence; instructions that
  **explicitly state what to change *and* what to preserve** are the consistently successful shape
  (RTX 4090 field test, omkamal.github.io — its image-guidance experiments apply to the
  non-distilled **Edit** variant, not to Edit-Turbo's CFG-free path).
- In-image text on the turbo path is only partially reliable for multi-word strings — keep text
  edits short, or point text-critical work to the full Edit/Base variants.

## Sources

- Model card (family zoo incl. Edit-Turbo 4 steps / CFG 1.0, hotfix revisions and their fixes,
  1-reference-image limit, known limitations, quickstart flags):
  <https://huggingface.co/Boogu/Boogu-Image-0.1-Edit-Turbo>
- Official repo: README, `INFERENCE_GUIDE.md` (rewriter flags, guidance gating),
  `inference_ti2i_turbo_simple.py` (**authoritative turbo-edit pipeline defaults**: one reference
  image, no-CFG DMD path, align_res, input caps), `boogu/pipelines/boogu/instruct_reasoner_static_skills.py`
  (**the authoritative edit-instruction rewriting contract**, ZH/EN):
  <https://github.com/boogu-project/Boogu-Image>
- Technical report: <https://arxiv.org/abs/2607.13125> · Project page: <https://boogu.org/>
- ComfyUI docs + changelog (native nodes, `TextEncodeBooguEdit`, templates, repackaged weights):
  <https://docs.comfy.org/tutorials/image/boogu/boogu-image-0.1>, <https://docs.comfy.org/changelog>
- Field reports: <https://www.reddit.com/r/StableDiffusion/comments/1ukewtp/>,
  <https://omkamal.github.io/articles/boogu-image/boogu-image.html>

*Documented 2026-09-21 against the 2026-06-30 release + hotfix-20260708 weights. If the model is
updated (multi-reference support has been teased), re-check the model card and
`instruct_reasoner_static_skills.py`, which are the authoritative prompting contract.*
