# imagegen-local

`imagegen-local` is a user-scoped pinned copy of the Codex Image Gen skill.
It is intended as a stable fallback when the bundled Codex system skill at
`~/.codex/skills/.system/imagegen` is unavailable, temporarily missing from the
Codex App skill library, or being refreshed by the Codex runtime.

## Why This Exists

The bundled `imagegen` skill can be managed by Codex App as a system asset. In
one observed environment, it disappeared from the skill library after app/runtime
restarts and later reappeared after a restart or system asset refresh.

This repository preserves a local, user-installable copy named `imagegen-local`.
The separate name is deliberate: it avoids same-name conflicts with the bundled
`imagegen` skill when both are present.

## What It Provides

- The full Image Gen skill instructions in `SKILL.md`.
- Prompting references under `references/`.
- Fallback CLI helper scripts under `scripts/`.
- Local transparent-background post-processing through
  `scripts/remove_chroma_key.py`.
- `AGENTS.md` with operational notes for future Codex agents.
- `PINNED_COPY.md` documenting the original source and pinning reason.

The built-in Codex `image_gen` tool is still the preferred path when the runtime
exposes it. This skill stabilizes the instruction bundle and local helpers; it
does not force the built-in image generation tool to appear in every session.

## Install As A Codex Skill

Clone this repository into your Codex skills directory:

```bash
mkdir -p ~/.codex/skills
git clone git@github.com:spacemoonfly/imagegen-local.git ~/.codex/skills/imagegen-local
```

If you prefer HTTPS:

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/spacemoonfly/imagegen-local.git ~/.codex/skills/imagegen-local
```

Restart Codex App after installing so the skill list is refreshed.

## Verify Installation

```bash
ls -la ~/.codex/skills/imagegen-local
sed -n '1,20p' ~/.codex/skills/imagegen-local/SKILL.md
python3 -m py_compile \
  ~/.codex/skills/imagegen-local/scripts/remove_chroma_key.py \
  ~/.codex/skills/imagegen-local/scripts/image_gen.py
```

The frontmatter should show:

```yaml
name: "imagegen-local"
```

## Usage Notes

Ask Codex to use `imagegen-local` when the bundled Image Gen skill is missing or
unstable. For normal image generation, the skill should still prefer the built-in
`image_gen` tool when available. CLI fallback requires `OPENAI_API_KEY` and is
only for explicit CLI/API/model-path use cases or confirmed true transparency
fallbacks.

## Maintenance

When the upstream bundled `.system/imagegen` skill changes and you want to refresh
this copy, copy the upstream files, then preserve the local skill name and local
helper paths.

Recommended local refresh outline:

```bash
SRC=~/.codex/skills/.system/imagegen
DST=~/.codex/skills/imagegen-local
rsync -a --delete --exclude='.SKILL.md.swp' "$SRC"/ "$DST"/
```

After refreshing, re-apply these local adjustments:

- `SKILL.md` frontmatter name must remain `imagegen-local`.
- Helper references should point to `~/.codex/skills/imagegen-local/...`, not
  `~/.codex/skills/.system/imagegen/...`.
- Keep this `README.md`, `AGENTS.md`, and `PINNED_COPY.md` unless intentionally
  rewriting the project docs.

Then verify:

```bash
rg -n "skills/\.system/imagegen|\.system/imagegen" ~/.codex/skills/imagegen-local
python3 -m py_compile \
  ~/.codex/skills/imagegen-local/scripts/remove_chroma_key.py \
  ~/.codex/skills/imagegen-local/scripts/image_gen.py
```

Only source-history documents such as `AGENTS.md` and `PINNED_COPY.md` should
normally mention `.system/imagegen`.
