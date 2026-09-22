# Upstream prompt enhancer — provenance and how to mirror it

Boogu ships its T2I prompt enhancement as an **instruction reasoner / rewriter**: a general VLM
driven by a fixed system prompt, not a dedicated fine-tuned checkpoint (unlike some other model
families). This skill encodes that system prompt's rules so the agent can do the rewriting
directly — the upstream files remain the source of truth.

## What upstream provides

| Path | What it is |
|---|---|
| Standalone external rewriter | `utils/t2i_external_prompt_rewriter.py` — local Qwen3-VL inference (32B recommended; 8B/4B/2B fallback for limited VRAM), `--lang zh|en`, temperature 0.7, max_new_tokens 1024. Contains `T2I_REWRITE_SYSTEM_PROMPT_ZH` / `_EN` — **the authoritative T2I rewriting contract** distilled into `t2i-prompting.md`. |
| Pipeline-integrated rewriter | `inference.py --use_rewrite_text_instruction True`; reuses the Qwen3-VL-8B instruction encoder by default, or a separate `--custom_local_instruction_rewriter_model`, or DashScope remote rewriting (`qwen-vl-max-latest`). |
| Rewrite presets | `--rewriter_system_prompt_type default|ppt|custom` — multi-step rewrite chains from `InstructionReasonerStaticRewriteSkills` / `static_skills.py` (the `ppt` preset targets slides/infographics; `custom` takes a list of per-step prompts). |
| Merging | `--merge_original_and_rewritten_instructions` optionally encodes original + rewrite together. |

Notes from the upstream file header:

- The system prompts are **adapted from Qwen-Image's official prompt-rewrite system prompt** — but
  the Boogu version's headline rule is the *Minimal-Edit Principle*, which inverts the
  expand-everything habit. Never blend the two contracts.
- The Boogu team says they have "a more powerful agentic prompt-enhancement system" planned for
  open-sourcing — watch the repo; if it lands, this skill must be re-synced against it.
- Rewriting is optional upstream: the image model runs without it. The system prompt defines the
  house style the model was tuned around, which is why following it improves results.

## Where the authoritative text lives

```text
https://github.com/boogu-project/Boogu-Image
├── utils/t2i_external_prompt_rewriter.py   # ZH/EN system prompts -> t2i-prompting.md
├── INFERENCE_GUIDE.md                      # rewriter flags, guidance/CFG gating, presets
├── demo_scripts/…reasoning…                # pipeline-integrated rewriting examples
└── (pipeline) InstructionReasonerStaticRewriteSkills / static_skills.py
```

Model card: `https://huggingface.co/Boogu/Boogu-Image-0.1-Turbo` · Project page:
`https://boogu.org/` · Paper: `https://arxiv.org/abs/2607.13125` · ComfyUI docs:
`https://docs.comfy.org/tutorials/image/boogu/boogu-image-0.1`

## Re-syncing this skill (maintainers only)

This is an **authoring-time maintenance procedure**, never part of answering a user: at delivery
time the skill is fully self-contained and offline — no fetches, no rendering, no external
services.

Fetch the rewriter and guide (plain text):

```bash
curl -sL -o /tmp/boogu_rewriter.py https://raw.githubusercontent.com/boogu-project/Boogu-Image/main/utils/t2i_external_prompt_rewriter.py
curl -sL -o /tmp/boogu_guide.md   https://raw.githubusercontent.com/boogu-project/Boogu-Image/main/INFERENCE_GUIDE.md
```

Then diff the ZH/EN system prompts against `t2i-prompting.md` and `recipes.md`, and the guidance
flags / model zoo numbers against `model-facts.md` (steps, CFG, resolution, aspect ratios, hotfix
revisions — stale defaults are the most common way a prompting guide starts lying). Check the
model card news section for new revisions or variants (a Turbo-2K has been hinted at); a new
variant triggers the extend-or-fork decision in the repo's AGENTS.md, not a silent update.

## What this skill deliberately does **not** do

- It never invokes the rewriter models, DashScope, diffusers, ComfyUI or any host-project
  inference client, and it never renders an image to validate a prompt.
- It never produces a negative prompt: Turbo runs at text-CFG 1.0, where `--negative_instruction`
  is inert, and the official rewrite spec bans negation words in the prompt itself.
- It never inflates prompts to look thorough — the Minimal-Edit Principle is the contract, and a
  faithful pass-through of a clear short prompt is a *correct* rewrite.
- It never applies Edit/Edit-Turbo or Base sampling numbers (25–50 steps, CFG 2.0–5.0) to Turbo.
