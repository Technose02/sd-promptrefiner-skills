# Upstream prompt enhancers — provenance and how to mirror them

Qwen ships **two fine-tuned Qwen3.5-VL 9B prompt-rewriting checkpoints** with Qwen-Image-2.1. This skill
encodes their rules so the agent can do the rewriting directly, but the upstream is the source of truth.

| Task | Checkpoint | Contract it emits |
|---|---|---|
| Text → image | `Qwen/Qwen-Image-2.1-PE-T2I` | `{"rewritten_prompt": "...", "wh_ratio": "3:2"}` |
| Image editing | `Qwen/Qwen-Image-2.1-PE-I2I` | `{"rewritten_prompt": "...", "wh_ratio": "", "ratio_follow": "<image1>"}` |

- Each task has its **own** checkpoint and **own** system prompt; they are not interchangeable and there
  is no merged prompt — the answer contract is part of what each model was trained on.
- The checkpoints are post-trained, so the stock open-source Qwen3.5-VL 9B does **not** reliably emit the
  answer JSON. Do not substitute a base VLM and expect the same output.
- Their production sampling settings differ per task (`presence_penalty` 1.5 for t2i, 0 for edit;
  `temperature` 1.0, `top_p` 0.95, `top_k` 20). Reference detail only — this skill never calls them.
- The Comfy-Org repackage ships both PE checkpoints as optional text encoders
  (`qwen3.5_9b_qwen_image_2.1_pe_t2i` / `_pe_i2i`, int8 convrot). They are optional by design: any
  capable LLM — including the agent using this skill — can produce the same rewrite.
- Source images are downscaled so W·H ≤ 1024×1024 before the rewriter sees them, and images are passed
  **in order**, because the rewrite addresses them as `<image1>`, `<image2>`, … Reordering silently
  re-points every reference.

## Where the authoritative text lives

```text
https://github.com/QwenLM/Qwen-Image-2.1
└── prompt_rewrite/
    ├── prompts/system_prompt_t2i.txt     # the 8-step observer-description spec  -> t2i-prompting.md
    ├── prompts/system_prompt_edit.txt    # the disentanglement + reference rules  -> edit-prompting.md
    ├── pe_core.py                        # task profiles, <imageN> handling, JSON parsing
    └── data/{t2i_example.jsonl,edit_example.jsonl}
```

Model card: `https://huggingface.co/Qwen/Qwen-Image-2.1` · Docs: `https://qwen.ai/blog?id=qwen-image-2.1`
· Diffusers page: `https://huggingface.co/docs/diffusers/main/api/pipelines/qwenimage21`
· ComfyUI: `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`

## Re-syncing this skill (maintainers only)

This is an **authoring-time maintenance procedure**. It is never part of answering a user: at delivery
 time the skill is fully self-contained and offline — no fetches, no rendering, no external services.

Fetch the two system prompts (they are plain text, no rendering tricks needed):

```bash
curl -sL -o /tmp/pe_edit.txt https://raw.githubusercontent.com/QwenLM/Qwen-Image-2.1/main/prompt_rewrite/prompts/system_prompt_edit.txt
curl -sL -o /tmp/pe_t2i.txt https://raw.githubusercontent.com/QwenLM/Qwen-Image-2.1/main/prompt_rewrite/prompts/system_prompt_t2i.txt
```

Then diff their rules against `edit-prompting.md` / `t2i-prompting.md` and update the affected sections.
Model facts (defaults, reference-image cap, RGBA syntax, native sizes) re-sync from the model card and the
Diffusers page — those change with releases, and stale sampling defaults are the most common way a
prompting guide starts lying.

## What this skill deliberately does **not** do

- It never invokes the PE checkpoints, diffusers, ComfyUI or any host-project inference client, and it
  never renders an image to validate a prompt.
- It never produces a negative prompt as the primary quality lever: 2.1 samples **without guidance** by
  default, and a negative prompt is ignored unless `true_cfg_scale > 1`, which doubles per-step work.
- It never rewrites the user's requested content into something "safer" or "better looking" — creative
  and physically impossible intent is preserved, per the upstream spec.
