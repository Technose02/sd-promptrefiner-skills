# AGENTS.md

Instructions for AI agents (and humans) working on this repository. Read this before creating,
renaming, editing or re-syncing any skill.

## What this repo is

A collection of **prompt-refiner skills** for image diffusion models, built for the pi agentic
harness. One skill per model, named `<diffusion-model-slug>-prompting`. A skill takes a user request
(words and/or descriptions of reference images) and returns **prompt text only**: one committed,
paste-ready prompt plus the sizing/sampling decisions reported beside it.

## Hard rules (never violate)

1. **Never write to `.pi/`.** It is user-managed local state (symlinks for skill installation) and is
   git-ignored. Renaming a skill directory may leave a stale symlink behind — flag it to the user;
   do not fix it yourself.
2. **Skills never render.** A skill must not generate, edit, upscale or otherwise produce an image,
   and must not validate a prompt by rendering it. No diffusers/ComfyUI/inference-server calls, no
   model downloads, no scripts of any kind inside a skill. Correctness is judged against the skill's
   written checklist.
3. **Skills are self-contained and offline at delivery time.** Everything a skill needs lives in its
   own directory: SKILL.md + `references/*.md`, linked with relative paths. No absolute paths, no
   files outside the skill, no network fetches as part of answering a user. Upstream URLs are allowed
   only as provenance citations and in maintainer-only re-sync procedures (clearly labelled as such).
4. **Web research is an authoring/maintenance activity only.** Use it to gather official docs and
   field reports while writing or re-syncing a skill — never as an instruction inside the skill's
   runtime workflow.
5. **Do not mix model families.** Each skill encodes one model's official prompting contract. Rules,
   defaults and examples from other models (earlier versions included) must not leak in.

## Skill conventions

### Naming

- Slug: model name lowercased, hyphen-separated, **no dots or other punctuation**
  (Qwen-Image-2.1 → `qwen-image-21-prompting`; Krea 2 → `krea-2-prompting`).
- Directory name == frontmatter `name:` == installation symlink name, always.

### Structure

- `SKILL.md` is a **lean router**: frontmatter (name, description with trigger phrases, license,
  compatibility, metadata incl. model + upstream), hard scope, workflow steps, output contract, and a
  table saying which reference file to load when. Keep it short enough to stay in context; push detail
  into `references/`.
- `references/` holds the rulebooks. The proven layout (adapt per model — e.g. drop
  `edit-prompting.md` for a generation-only model):
  - `model-facts.md` — verified facts: identity/lineage, capability table, sampling defaults, native
    sizes, hard "never in the prompt" list, reference-image addressing, runtime/tooling notes, dated
    field reports, sources, "Documented <date>" line.
  - `t2i-prompting.md` / `edit-prompting.md` — distilled official rewriting specs.
  - `recipes.md` — fill-in-the-bracket skeletons per task type.
  - `quality-checklist.md` — pre-flight gates, reply format, failure-mode diagnosis table.
  - `prompt-enhancer.md` — upstream refiner provenance + maintainer-only re-sync procedure.

### Content quality bar

- **Facts are sourced and dated.** Every number (steps, cfg, limits, native sizes) traces to an
  official source listed at the bottom of `model-facts.md`; community findings go in a separate,
  explicitly dated "field reports" section, never mixed into official facts.
- **The output contract is explicit**: one prompt (single paragraph, no ratio/resolution/quality
  boilerplate inside), one sizing decision, at most a few rationale bullets. Prefer one committed
  prompt over a menu of variants.
- **Failure modes get tables.** Symptom → cause in the prompt → fix. Checklists are gates, not
  advice: anything unchecked is a bug to fix before answering.
- Encode the model's **language rules** exactly (prompt prose language vs. rendered in-image text
  language, where applicable).
- Keep the skill's voice: precise, decisive, no hedging in delivered prompts.

## Adding a skill for a new model

1. **Research (web allowed — this is authoring time).** Gather the primary sources: official model
   card (HF/ModelScope), the upstream GitHub repo (clone it; read any shipped prompt-rewriting system
   prompts — they are the authoritative prompting contract), day-0 ComfyUI and diffusers docs, the
   launch blog. Then sweep early community field reports (Reddit/forums) for practical pitfalls.
2. **Distil** into the reference layout above. Copy facts, don't paraphrase numbers. Record every
   source URL and a "Documented <date>" line.
3. **Name and scaffold** per the conventions; write SKILL.md last, as the router.
4. **Verify self-containment**: all links relative and resolvable; `grep` for absolute paths,
   external file references, host-project names and tooling calls; frontmatter `name` == directory.
5. **Update this repo's README** skills table.
6. Tell the user how to install (symlink into `.pi/skills/`) — do not create the symlink yourself.

## Updating / re-syncing an existing skill

- Re-sync **model facts first** (sampling defaults, limits, native sizes) — stale defaults are the
  most common way a prompting guide starts lying. Follow the skill's `prompt-enhancer.md` re-sync
  procedure: diff the upstream system prompts against the distilled rulebooks, then update affected
  sections.
- Keep official facts and dated community field reports in separate sections; re-date both.
- When the model itself is versioned up (e.g. a future Qwen-Image-2.2), decide explicitly: extend the
  skill in place or fork a new `<slug>-prompting` skill. Add the new model to the old skill's
  "do-not-confuse" list either way.

## Repo maintenance: the audit cycle

The repo is maintained by **auditing skills one at a time**, then verifying the collection as a
whole. Run the cycle when a model gets a point release, when users report a skill giving stale
advice, or on a regular sweep (e.g. monthly). One audit = phases 1–3 for **each** skill, then
phase 4 once at the end.

### Phase 1 — Audit each skill separately (never in a batch)

- Take one skill directory at a time. Skills encode different models' contracts; analysing them
  together is how rules leak across model families (hard rule 5).
- Establish the skill's baseline: read `references/model-facts.md`'s "Documented <date>" line and
  source list. Everything found in phase 2 is measured against that date.
- Record findings per skill as you go (what changed upstream, which sections are affected) so the
  apply step and the final report can cite them.

### Phase 2 — Web research per skill (authoring-time activity, hard rules 3–4)

Re-check, in this order:

1. **Upstream contract changes**: the model card (HF/ModelScope), the GitHub repo — especially any
   shipped prompt-rewriting system prompts (the authoritative contract; follow the skill's
   `prompt-enhancer.md` re-sync procedure and diff, don't skim), day-0 ComfyUI and diffusers docs,
   and the launch/blog pages listed in `model-facts.md`'s sources.
2. **New best practices and guides**: official how-to pages, template workflows, and reputable
   third-party guides published since the documented date.
3. **Dos and don'ts / field reports**: community threads (Reddit, forums, issue trackers) for
   practical pitfalls — sampler/cfg/steps findings, failure modes, workarounds. These go into the
   dated "field reports" section only, never into official facts.
4. **Version drift**: has the model itself been versioned up? If so, trigger the extend-or-fork
   decision from the re-sync section instead of a normal update.

Research findings are notes for the maintainer; nothing in this phase adds a runtime web dependency
to a skill.

### Phase 3 — Apply findings to that skill individually

- **Model facts first** (sampling defaults, limits, native sizes, runtime/tooling notes), then the
  distilled rulebooks (`t2i-prompting.md`, `edit-prompting.md`), then `recipes.md` and
  `quality-checklist.md` — only the sections the findings actually touch.
- Keep official facts and community field reports in their separate sections; **re-date both** and
  update the "Documented <date>" line and the source list.
- Remove advice that upstream has since contradicted; don't let stale tips accumulate.
- Re-run the skill-level self-containment checks (relative links resolve, no absolute paths, no
  external file references, frontmatter `name` == directory) before moving to the next skill.

### Phase 4 — Repo-wide consistency check (after all skills are done)

Verify across the whole collection:

- **Naming**: every directory matches `<diffusion-model-slug>-prompting` (lowercase, hyphenated, no
  punctuation); directory name == frontmatter `name:` in every SKILL.md.
- **README**: the skills table lists every skill in the repo, with an accurate one-line coverage
  summary and a working relative link.
- **Structure**: each skill follows the reference layout (adaptations allowed per model, but
  SKILL.md stays the lean router and the output contract stays explicit).
- **Cross-skill coherence**: shared conventions read the same everywhere — output contract shape
  (one prompt + one sizing decision + ≤ a few rationale bullets), "skills never render" wording,
  hard-scope phrasing, checklist-as-gates style, voice (precise, decisive, no hedging in delivered
  prompts).
- **No cross-family bleed**: grep each skill for other models' names/defaults; mentions are allowed
  only in "do-not-confuse" lists.
- **Hygiene**: no host-project names, absolute paths, TODOs or leftover research notes committed;
  `.pi/` untouched and still git-ignored; stale `.pi/skills` symlinks from renames are flagged to the
  user, not fixed in-repo.

Finish with a short report per skill (what was checked, what changed, what was deliberately left
alone) and commit per the conventions below — one `update <skill-name>: …` commit per skill, plus
`docs: …` for README/AGENTS changes.

## Git conventions

- `.pi/` stays git-ignored; never commit it or anything inside it.
- Commit messages: `add <skill-name>`, `update <skill-name>: <what changed>`,
  `rename <old> -> <new>`, `docs: <what changed>`.
