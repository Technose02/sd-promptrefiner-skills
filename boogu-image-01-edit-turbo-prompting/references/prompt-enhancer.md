# Upstream prompt enhancer — provenance and how to mirror it

Boogu ships edit-prompt enhancement as an **instruction reasoner / rewriter**: a general VLM driven
by fixed system prompts, not a dedicated fine-tuned checkpoint. This skill encodes the
image-editing system prompt's rules so the agent can do the rewriting directly — the upstream files
remain the source of truth.

## What upstream provides

| Path | What it is |
|---|---|
| Edit system prompts | `boogu/pipelines/boogu/instruct_reasoner_static_skills.py` → `REWRITE_SYSTEM_PROMPT_4_EDIT_EN` / `_ZH` — **the authoritative edit-instruction contract** distilled into `edit-prompting.md`. The same file holds the image-generation prompts (`REWRITE_SYSTEM_PROMPT_EN/_ZH`) that the T2I variants use; the two task types get **different** prompts selected by `task_type` (`image-editing` vs `image-generation`) — never blend them. |
| Pipeline integration | `inference.py --use_rewrite_text_instruction True`; reuses the Qwen3-VL-8B instruction encoder by default, or a separate `--custom_local_instruction_rewriter_model`, or DashScope remote rewriting (`qwen-vl-max-latest`). |
| Presets | `--rewriter_system_prompt_type default|ppt|custom` — the `ppt` preset chains multi-step rewrites for slide/infographic-style jobs (`static_skills.py`); `custom` accepts a list of per-step prompts. |
| Standalone T2I rewriter | `utils/t2i_external_prompt_rewriter.py` (generation only — belongs to the Turbo/Base contract, not this skill's). |

Notes:

- The rewriter's closing instruction is to output **the rewritten instruction directly** — no
  guiding, explanatory or analytical words. This skill's output contract mirrors that.
- The Boogu team says a "more powerful agentic prompt-enhancement system" will be open-sourced —
  watch the repo; if it lands, re-sync this skill against it.
- Rewriting is optional upstream; the system prompt defines the house style the model was tuned
  around, which is why following it improves results.

## Where the authoritative text lives

```text
https://github.com/boogu-project/Boogu-Image
├── boogu/pipelines/boogu/instruct_reasoner_static_skills.py  # edit ZH/EN system prompts -> edit-prompting.md
├── boogu/pipelines/boogu/static_skills.py                    # ppt preset chains
├── INFERENCE_GUIDE.md                                        # rewriter flags, guidance/CFG gating
├── inference_ti2i_turbo_simple.py                            # authoritative turbo-edit pipeline defaults
└── demo_scripts/demo_ti2i_*reasoning*.sh                     # integrated-rewriter examples
```

Model card: `https://huggingface.co/Boogu/Boogu-Image-0.1-Edit-Turbo` · Project page:
`https://boogu.org/` · Paper: `https://arxiv.org/abs/2607.13125` · ComfyUI docs:
`https://docs.comfy.org/tutorials/image/boogu/boogu-image-0.1`

## Re-syncing this skill (maintainers only)

This is an **authoring-time maintenance procedure**, never part of answering a user: at delivery
time the skill is fully self-contained and offline — no fetches, no rendering, no external
services.

Fetch the authoritative files (plain text):

```bash
curl -sL -o /tmp/boogu_edit_skills.py https://raw.githubusercontent.com/boogu-project/Boogu-Image/main/boogu/pipelines/boogu/instruct_reasoner_static_skills.py
curl -sL -o /tmp/boogu_ti2i_turbo.py  https://raw.githubusercontent.com/boogu-project/Boogu-Image/main/inference_ti2i_turbo_simple.py
```

Then diff `REWRITE_SYSTEM_PROMPT_4_EDIT_EN/_ZH` against `edit-prompting.md` and `recipes.md`, and
the pipeline defaults / model-zoo numbers (steps, CFG, checkpoints, hotfix revisions, reference
count) against `model-facts.md` — stale defaults are the most common way a prompting guide starts
lying. Check the model card news for new hotfixes or the teased multi-reference support; a
capability change like that triggers the extend-or-fork decision in the repo's AGENTS.md, not a
silent update.

## What this skill deliberately does **not** do

- It never invokes the rewriter models, DashScope, diffusers, ComfyUI or any host-project
  inference client, and it never renders an image to validate an instruction.
- It never produces a negative instruction: the DMD path runs without CFG, where
  `--negative_instruction` is inert, and the rewrite contract keeps everything affirmative.
- It never applies the family's T2I Minimal-Edit pass-through to edit requests, and never applies
  other model families' edit contracts (`<imageN>` tags, canvas-mapping tables, ratio-follow JSON
  fields) — this model has one input image and its own official spec.
- It never advises non-official sampling numbers (25–50 steps, CFG 2–5, image-guidance identity
  dials) — those belong to the non-distilled Edit/Base variants.
