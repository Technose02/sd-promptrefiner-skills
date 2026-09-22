# Pre-flight checklist and output contract — Boogu-Image-0.1-Turbo

Run every gate **before** answering. Anything unchecked is a bug in the prompt, not a caveat to
tell the user about.

## Contract with the user

Your reply is prompt text only — no inference, no calls to diffusers/ComfyUI/any client, no image
generation, and never a render "to check". Deliver:

1. **Mode** — always `t2i` (Turbo is generation-only). An edit request is out of scope: say it
   belongs to Boogu-Image-0.1-Edit / Edit-Turbo and stop.
2. **Prompt** — one fenced `text` block, ready to paste.
3. **Sizing** — `wh_ratio: "X:Y"` from the nine supported ratios (default `1:1`), 1K class.
4. **Sampling note** (one line, only when settings are in scope) — steps 4 · CFG 1.0 · negative
   prompt inert on Turbo.
5. At most three short rationale bullets. No lecture, no restating the prompt twice.

If the request is genuinely ambiguous, pick the most reasonable reading, commit it, and flag the
choice in one bullet — the prompt itself never hedges.

## Gates

### Scope and family

- [ ] Request is text-to-image. (Image input ⇒ refuse-and-redirect; this skill never applies
      Edit-variant rules, and never applies other families' dense-expansion contracts.)
- [ ] Ultra-dense-text workload ⇒ user was told Base@2K is the officially recommended tool
      (still deliver the best Turbo prompt if they want Turbo).
- [ ] In-image text requested in a language other than zh/en ⇒ degradation warned about.

### Minimal-Edit (the governing principle)

- [ ] Every added phrase passes the remove-it test (without it, would the picture fail?).
- [ ] A clear short prompt stayed short; at most one style word added.
- [ ] Rewritten length is roughly comparable to the original; a detailed original was only tidied,
      not expanded.
- [ ] No fabricated scenes, props, actions, atmosphere, or camera parameters the user didn't give.
- [ ] Synonyms deduplicated; no adjective piles; short sentences.
- [ ] Layout/diagram/poster exception applied where due: those ARE exhaustively detailed.

### Prompt string

- [ ] No resolution/ratio/pixel counts anywhere in the prompt ("16:9", "1024x1024", "1K/2K/4K/8K").
- [ ] No negation words and no negative prompt; everything stated affirmatively.
- [ ] No empty praise ("stunning", "high-end", "tech feel", "futuristic", "visual impact", "cool");
      quality words limited to "cinematic" / "premium texture" / "refined", used sparingly.
- [ ] No "negative space" / "white space" phrasing (→ "clean composition, clean background").
- [ ] No weighting syntax, no `--ar`, no tag soup, no quality boosters ("masterpiece", "8K").
- [ ] Every visible string quoted exactly, unaltered, with position + colour + font/weight/size;
      ambiguous text made concrete; **no text the user didn't ask for**; no placeholder copy.
- [ ] Real logos/celebrities/known characters: canonical name only, zero appearance description;
      celebrities carry both Chinese and English names.
- [ ] Stated counts/arrangements executed exactly, subjects described one by one in fixed order.
- [ ] Logical relationships (chains, flows, comparisons) preserved with their visual connectors.
- [ ] Style: user's style name kept verbatim and not described; otherwise the semantic default
      applied; realistic subjects not tagged "realistic"; style named exactly once.
- [ ] Language: prose matches the user's input language (zh→zh, en→en, other→en with verbatim
      quoted text); unspecified cultural context defaults to Chinese; classical poetry stays
      classical-Chinese in imagery.
- [ ] Explicit-content requests rewritten safe per the official spec, preserving picture type,
      composition, style, tone and subject count.
- [ ] Sizing decision present and from the supported set; ratio never inside the prompt.

### Known-limitation mitigations (only where the task touches them)

- [ ] Faces/eyes/small limbs/text given enough frame share (FLUX.1 VAE detail loss).
- [ ] Groups kept moderate, poses clear, occlusion minimized (body-structure weak spot).
- [ ] Brand/landmark/celebrity fidelity expectations set (world knowledge gap).

## If the result looked "close but wrong" (diagnose from the prompt, not the render)

| Symptom | Prompt cause | Fix |
|---|---|---|
| Image is busy/invented beyond the brief | Minimal-Edit violated; padding phrases added | Strip everything that passes the remove-it test |
| Style looks generic or doubled up | Style described instead of named, or named twice, or "realistic" added to an everyday subject | One style name, once; drop realism tags for ordinary subjects |
| Text garbled, missing or invented | String not quoted/committed, too dense, or non-zh/en | Commit short exact strings; move ultra-dense jobs to Base@2K; warn on other scripts |
| A negated object appeared | Negation words in the prompt | Remove the word entirely; describe only what should be present |
| Celebrity/brand looks wrong | Appearance described in words, or world-knowledge gap | Canonical name only; set expectations or go generic |
| Hands/limbs/poses broken | Multi-person interaction, occlusion, extreme viewpoint | Fewer people, clearer separated poses, ordinary viewpoint |
| Tiny faces/eyes smeared | Subjects too small in frame (VAE limit) | Closer composition, fewer subjects |
| Wrong aspect/artifacts at edges | Off-contract ratio or pre-hotfix weights | Use one of the nine supported ratios; confirm hotfix-20260625 weights |
| All-black output reported | `--enable_torch_compile` on some GPUs | Tell the user to disable torch compile (runtime issue, not prompt) |
