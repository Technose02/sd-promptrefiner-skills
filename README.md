# sd-promptrefiner-skills

A collection of **prompt-refiner skills** for image diffusion models, written for the **pi** agentic
harness (`@earendil-works/pi-coding-agent`). Each skill turns a rough user request —
text and/or reference images — into a **paste-ready, model-specific prompt** plus the sizing and
sampling decisions that go beside it. The collection will grow to cover more diffusion models.

## What these skills do — and never do

- **Do:** author and refine prompt text. Classify the task (text-to-image vs. instruction edit),
  apply the target model's official prompting contract, and return one committed prompt with its
  aspect-ratio/sizing decision.
- **Never:** generate, edit or render an image. No diffusers, no ComfyUI, no inference servers, no
  model downloads — and no "validation by rendering". A prompt is checked against the skill's
  written checklist, not against a picture. Every skill is pure text in, pure text out.
- **Never:** depend on anything at delivery time. A skill is fully **self-contained**: SKILL.md plus
  its `references/` directory, linked relatively, usable offline. Upstream URLs appear only as
  provenance citations for maintainers.

## Naming convention

```
<diffusion-model-slug>-prompting
```

The slug is the model name, lowercased, hyphen-separated, **without punctuation**:

| Model | Skill name |
|---|---|
| Qwen-Image-2.1 | `qwen-image-21-prompting` |
| Krea 2 (future example) | `krea-2-prompting` |

The directory name, the `name:` field in the SKILL.md frontmatter, and any symlink used to install
the skill must all carry exactly this name.

## Skills

| Skill | Model | Covers |
|---|---|---|
| [`qwen-image-21-prompting/`](qwen-image-21-prompting/SKILL.md) | Qwen-Image-2.1 (2026-09) | T2I observer-style descriptions, instruction edits with attribute disentanglement, `<imageN>` multi-reference composition (up to 10), native RGBA/transparency, in-image text and language rules, sizing decisions (`wh_ratio` vs. follow-a-canvas) |
| [`boogu-image-01-turbo-prompting/`](boogu-image-01-turbo-prompting/SKILL.md) | Boogu-Image-0.1-Turbo (2026-06) | T2I-only, 4-step distilled model: the official **Minimal-Edit** rewrite contract (pass clear prompts through, expand only subjectless briefs), exhaustive detail exception for posters/logos/infographics/diagrams, bilingual zh/en in-image text rules, canonical-name handling of real entities, nine supported ratios at 1K, prose-follows-input-language rule, edit requests redirected to the Edit variant |
| [`boogu-image-01-edit-turbo-prompting/`](boogu-image-01-edit-turbo-prompting/SKILL.md) | Boogu-Image-0.1-Edit-Turbo (2026-06, hotfix 2026-07) | Single-image instruction editing, 4-step distilled (CFG off): detailed operation-led instructions (the inverse of the T2I Minimal-Edit rule), preservation wording as the only identity lock, official add/remove/replace + human-edit rules, fixed templates for text replacement and old-photo restoration, styles described in traits, verbatim zh/en quoted text, follow-input sizing with nine ratios on explicit re-frames |

## Skill layout

```
<model-slug>-prompting/
├── SKILL.md            # lean router: scope, workflow, output contract, reference table
└── references/         # the rulebooks, loaded on demand
    ├── model-facts.md          # verified model facts + sources + documented-date
    ├── t2i-prompting.md        # text-to-image rules
    ├── edit-prompting.md       # editing rules (only for models that edit)
    ├── recipes.md              # ready-made prompt skeletons per task type
    ├── quality-checklist.md    # pre-flight gate + reply format + failure diagnosis
    └── prompt-enhancer.md      # upstream refiner provenance + re-sync procedure
```

## Installing into pi

Symlink (or copy) a skill directory into a pi skills location — project-level
`.pi/skills/<skill-name>` or user-level `~/.pi/agent/skills/<skill-name>`:

```bash
ln -s ../../qwen-image-21-prompting .pi/skills/qwen-image-21-prompting
ln -s ../../boogu-image-01-turbo-prompting .pi/skills/boogu-image-01-turbo-prompting
ln -s ../../boogu-image-01-edit-turbo-prompting .pi/skills/boogu-image-01-edit-turbo-prompting
```

`.pi/` is **user-managed local state**: it is git-ignored, and nothing in this repo ever writes to
it. If you rename a skill, re-create the symlink yourself.

Then just ask pi: *"Write me a Qwen-Image-2.1 prompt for …"*, *"Give me a Boogu Turbo prompt
for …"* or *"Refine this Boogu Edit-Turbo instruction: …"* — the skill descriptions trigger them
automatically.

## Maintenance

See [AGENTS.md](AGENTS.md) for the conventions agents (and humans) must follow when adding,
renaming or re-syncing skills in this repo, including the **audit cycle** used to keep skills
current: each skill is audited separately against upstream changes and new community
best-practices/dos-and-don'ts, findings are applied per skill, and a repo-wide consistency check
closes the pass.
