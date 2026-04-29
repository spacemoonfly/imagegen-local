# AGENTS.md - imagegen-local

## Purpose

This directory is a user-scoped pinned copy of the bundled Codex Image Gen skill.
It exists because the bundled system skill at:

```text
/Users/robiny/.codex/skills/.system/imagegen
```

has been observed to disappear from the Codex App skill library after app/runtime restarts, then reappear after a later restart or system asset refresh. Keeping this local copy gives future Codex sessions a stable skill entry that is not tied to the `.system` asset injection path.

## What Changed

Created on 2026-04-29 from the currently available bundled system skill.

Source:

```text
/Users/robiny/.codex/skills/.system/imagegen
```

Pinned copy:

```text
/Users/robiny/.codex/skills/imagegen-local
```

Changes made during pinning:

- Copied the complete bundled Image Gen skill directory.
- Excluded the transient Vim swap file `.SKILL.md.swp`.
- Renamed the skill frontmatter from `imagegen` to `imagegen-local` to avoid duplicate-name conflicts with the bundled system skill when both are visible.
- Updated transparent-background helper references from `.system/imagegen` to `imagegen-local`.
- Added `PINNED_COPY.md` to record the source and reason for the copy.
- Verified both bundled Python helper scripts compile with `python3 -m py_compile`.

## Expected Behavior

Future agents should prefer this skill when the user explicitly mentions `imagegen-local`, or when the bundled `imagegen` skill is missing from the Codex App skill library.

The built-in `image_gen` tool remains the preferred generation path when available. This local skill mostly stabilizes the instruction bundle and fallback scripts; it does not by itself guarantee that the built-in image generation tool is exposed in every runtime session.

## Why Not Copy As `imagegen`

Do not rename this directory or skill back to `imagegen` unless the user explicitly asks and understands the tradeoff.

Reason: if both the bundled `.system/imagegen` skill and a user-level `imagegen` skill exist, Codex may need to de-duplicate or choose between same-name entries. That could make diagnosis harder and may create exactly the kind of intermittent visibility behavior we are trying to avoid.

## If Image Gen Disappears Again

Check these paths first:

```bash
ls -la /Users/robiny/.codex/skills/.system/imagegen
ls -la /Users/robiny/.codex/skills/imagegen-local
sed -n '1,20p' /Users/robiny/.codex/skills/imagegen-local/SKILL.md
```

Search recent Codex logs for skill discovery and system asset refresh evidence:

```bash
rg -n "skills/list|skills cache|installed system asset|imagegen|Image Gen|\.system" \
  /Users/robiny/.codex/log/codex-tui.log \
  /Users/robiny/Library/Logs/com.openai.codex/2026/04/29/*.log
```

Useful interpretation:

- If `.system/imagegen` is missing but `imagegen-local` exists, this points to Codex App/runtime system asset injection or skill-list caching rather than project code.
- If both exist but only one appears in the UI, suspect skill discovery, cache, duplicate filtering, or UI list state.
- If `imagegen-local` is missing too, investigate local filesystem cleanup, accidental deletion, or a broader `~/.codex/skills` issue.

## Maintenance Notes

When the bundled system `imagegen` skill is updated upstream and appears stable, this local copy can be refreshed manually by copying from `.system/imagegen` again, preserving the `imagegen-local` name and local helper paths.

Recommended refresh pattern:

```bash
SRC=/Users/robiny/.codex/skills/.system/imagegen
DST=/Users/robiny/.codex/skills/imagegen-local
rsync -a --delete --exclude='.SKILL.md.swp' "$SRC"/ "$DST"/
# Re-apply local naming and path adjustments after copying.
```

After refresh, verify:

```bash
rg -n "skills/\.system/imagegen|\.system/imagegen" /Users/robiny/.codex/skills/imagegen-local
python3 -m py_compile \
  /Users/robiny/.codex/skills/imagegen-local/scripts/remove_chroma_key.py \
  /Users/robiny/.codex/skills/imagegen-local/scripts/image_gen.py
```

Only `PINNED_COPY.md` and this `AGENTS.md` should normally mention `.system/imagegen` as historical/source context.
