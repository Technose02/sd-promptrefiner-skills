# Boogu-Image-0.1-Turbo — verified model facts

Everything the prompt writer needs to know about the target model, and nothing else.
Checked against the official model card, the official repo (incl. `INFERENCE_GUIDE.md` and the
shipped prompt rewriter), the official ComfyUI docs and the technical report (links at the bottom).

## Identity

- **Boogu-Image-0.1-Turbo**, released **2026-06-16**; weights refreshed by the **hotfix-20260625**
  revision (fixed per-aspect-ratio visual artifacts and background overfitting artifacts — always
  assume the hotfix weights). Apache-2.0, research project by the Boogu team.
- One member of the **Boogu-Image-0.1 family**: **Base** (T2I foundation, 25–50 steps, CFG 2.0–5.0,
  1K/1.5K/2K), **Turbo** (this model), **Edit** and **Edit-Turbo** (image editing, TI2I). Same 10B
  parameter count across the family; Turbo is Base + **Decoupled-DMD distillation** (shipped in
  ComfyUI as a rank-128 LoRA module on the base pipeline).
- **10B-parameter diffusion transformer**; text/instruction encoding by a **Qwen3-VL-8B** MLLM;
  latent space via the open-source **FLUX.1 VAE**; unified understanding + generation design.
- **Turbo is text-to-image only.** No image input, no reference images, no editing. Editing belongs
  to Boogu-Image-0.1-Edit / Edit-Turbo — different models with a different contract, out of scope
  for this skill.

## Task surface (what a prompt can ask for)

| Capability | Notes for prompting |
|---|---|
| Text → image | Photorealism is Turbo's strength (officially rated above Base for realistic photography) |
| In-image text (zh/en) | Simple text rendering is strong; **dense text is weaker than Base** — official recommendation for ultra-dense layouts is *Base at 2K*, not Turbo |
| Stylization | Named styles (Ghibli, pixel art, ink wash, cyberpunk…) are understood; keep the style name, don't describe it |
| Poster / product / logo design | Supported scenes with dedicated rewrite rules (layout, text placement, colour scheme) |
| Bilingual scope | Text rendering is optimized for **Chinese and English only**; other languages degrade noticeably |

## Sampling defaults (official)

| Parameter | Turbo value | Guidance |
|---|---|---|
| Steps | **4** (3–4 typical) | Distilled — do **not** use the 25–50 step schedules; those are Base/Edit numbers |
| `text_guidance_scale` (CFG) | **1.0 — text CFG disabled by design** | A `--negative_instruction` is only meaningful when CFG > 1, so on Turbo **negative prompts are inert** |
| Resolution | **1K class (1024×1024 budget) only** | 1.5K/2K are Base/Edit capabilities; do not promise them on Turbo |
| Aspect ratios | **1:1, 2:3, 3:2, 3:4, 4:3, 1:2, 2:1, 9:16, 16:9** | The full supported set; anything else is off-contract |
| Quantizations | bf16, fp8 (`-fp8` checkpoints), NVFP4 (community/ComfyUI repackages) | No prompting consequences |

**Consequence for prompts:** MLLM-encoded, instruction-following, guidance-free. Natural prose beats
tag soup, and the official rewriter's *Minimal-Edit Principle* is the contract: a clear short prompt
stays short. This is deliberately **not** a dense-expansion model contract — never inflate prompts
the way other families' refiners do (see the do-not-confuse list in SKILL.md).

## Sizing decision (reported beside the prompt, never inside it)

- One field: `wh_ratio` from the nine supported ratios above, rendered in the 1K pixel budget
  (e.g. 1024×1024, 832×1248-class equivalents — the runtime derives exact pixels; the skill only
  reports the ratio).
- Default when nothing is stated: **1:1**. Portrait subjects → 2:3 or 3:4; landscape scenes → 3:2
  or 4:3; phone wallpaper / full-body vertical → 9:16; wide cinematic / desktop → 16:9; extreme
  vertical banner → 1:2; extreme panoramic → 2:1.
- **Never** write a ratio, resolution or pixel count into the prompt string ("16:9", "1024x1024",
  "1K", "2K", "4K", "8K"). Quality words like "2K/4K/8K" in a user request are quality wishes, not
  ratio signals — and on Turbo they must not be echoed into the prompt at all.

## Hard "never put these in the prompt" list

- **No** resolution, aspect ratio or pixel counts (see above).
- **No negative prompts and no negation words**: the official spec forbids negations in the prompt
  ("no chopsticks" → simply never mention chopsticks), and on Turbo (CFG 1.0) a negative prompt is
  inert anyway. State what is present, affirmatively.
- **No weighting syntax** `(word:1.2)`, no `--ar`, no tag-list boilerplate.
- **No empty praise words**: "tech feel", "premium feel", "futuristic", "high-end", "visual impact",
  "stunning", "cool" — the official rewriter removes them even when the user wrote them. Allowed
  quality-style words: "cinematic", "premium texture", "refined".
- **No "negative space" / "white space"** — generation misreads it as white borders/blank blocks;
  write "clean composition, clean background".
- **No unrequested in-image text** and **no appearance descriptions of real fixed-IP entities**
  (logos, celebrities, known characters): refer to them by canonical name only.

## Known limitations (official, from the model card) — and prompt mitigations

| Limitation | Mitigation in the prompt |
|---|---|
| **World knowledge gap** (real brands, celebrities, landmarks, products) | Refer by canonical name only; never describe the entity's appearance; for non-critical branding prefer a described generic ("a dark brown metallic craft-beer label") over a real brand |
| **Dense/long text, small fonts, complex layouts** can produce typos, missing characters, layout drift | Keep quoted strings short; commit every string exactly; for ultra-dense documents recommend Boogu-Image-0.1-Base at 2K instead |
| **Non zh/en text** not optimized, degrades noticeably | Render in-image text in Chinese or English; other scripts → warn the user |
| **Body structure** in multi-person interaction, occlusion, exaggerated motion, unusual viewpoints | Prefer moderate group sizes, clear non-overlapping poses; describe each person's position and posture explicitly, one by one |
| **FLUX.1 VAE reconstruction loss**: small faces, small limbs, eyes, tiny text may artifact | Give faces/text enough frame share — closer shots, fewer tiny subjects; avoid crowds of small faces |

## Runtime/tooling notes (for advice only — this skill never runs any of it)

- **diffusers/PyTorch**: `inference_turbo.py --pretrained_pipeline_name_or_path models/Boogu-Image-0.1-Turbo --instruction "…" --height 1024 --width 1024` — steps and CFG are baked in (4 / 1.0). Tested env: Python 3.10, CUDA 12.6, PyTorch 2.7.1. VRAM: ~24GB comfortable, 12–16GB with offload flags or fp8.
- **Prompt enhancement upstream**: `--use_rewrite_text_instruction True` (pipeline-integrated
  rewriter, presets `default` / `ppt` / `custom`, or DashScope remote `qwen-vl-max-latest`) or the
  standalone `utils/t2i_external_prompt_rewriter.py` with a local Qwen3-VL (32B recommended,
  8B/4B/2B fallback). See [prompt-enhancer.md](prompt-enhancer.md).
- **ComfyUI**: native support since 2026-06-17 (Comfy-Org repackage `Comfy-Org/Boogu-Image`,
  official T2I template `image_boogu_image_0_1_turbo_t2i`). The `ComfyUI-Boogu` custom-node repo is
  legacy — the project itself says to use native nodes instead.
- **Torch compile caveat**: `--enable_torch_compile` can produce all-black outputs on some
  GPUs/models — if a user reports a black image, suggest disabling it first.
- Accelerators with day-0 support: vLLM-Omni, TeaCache/TaylorSeer caching (see INFERENCE_GUIDE.md);
  NPU via the `npu` branch.

## Third-party notes (not official — dated 2026-09-21)

- Community quantizations (GGUF, MLX bf16 ~6× faster on Apple Silicon, fp8/NVFP4 repackages) exist;
  none change prompting.
- Third-party guides sometimes quote Base's 25–50 steps / CFG 2.0–5.0 for Turbo — **wrong**; the
  official model zoo table is authoritative (Turbo: 4 steps, CFG 1.0).

## Sources

- Model card (family zoo incl. Turbo steps/CFG/resolution, aspect-ratio list, highlights, scenario
  comparison, known limitations, news/hotfix log): <https://huggingface.co/Boogu/Boogu-Image-0.1-Turbo>
- Official repo README + `INFERENCE_GUIDE.md` (guidance flags incl. `--negative_instruction` gating,
  rewriter integration, hardware notes) + `utils/t2i_external_prompt_rewriter.py` (**the authoritative
  T2I rewriting contract**, ZH/EN system prompts): <https://github.com/boogu-project/Boogu-Image>
- Technical report: <https://arxiv.org/abs/2607.13125> · Project page: <https://boogu.org/>
- ComfyUI native workflow docs (Turbo = 4-step distilled, rank-128 LoRA module, template names):
  <https://docs.comfy.org/tutorials/image/boogu/boogu-image-0.1>
- ComfyUI changelog (native node support, `TextEncodeBoogu*` nodes): <https://docs.comfy.org/changelog>
- Third-party overview (quantization formats; treat non-official numbers with care):
  <https://hackernoon.com/boogu-image-01-turbo-brings-fast-4-step-text-to-image-generation>

*Documented 2026-09-21 against the 2026-06-16 release + hotfix-20260625 weights. If the model is
updated (a Turbo-2K variant has been hinted at), re-check the model card model zoo and
`utils/t2i_external_prompt_rewriter.py`, which are the authoritative prompting contract.*
