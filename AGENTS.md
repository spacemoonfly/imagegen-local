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

## 2026-04-30 Reproduction Notes

The disappearance was reproduced again on 2026-04-30 while working from:

```text
/Users/robiny/3dtankdemo
```

Observed state:

- The previous 2026-04-29 conversation captured `/Users/robiny/.codex/skills/.system/imagegen` as present during an `ls` run at `2026-04-29T15:48:19Z` / `2026-04-29 23:48:19 +0800`.
- That `ls` output showed a very fresh system copy: `.system/imagegen` directory mtime `Apr 29 23:44`; `.system` parent mtime `Apr 29 23:43`; `SKILL.md`, `LICENSE.txt`, `agents`, `assets`, `references`, and `scripts` mtimes `Apr 29 23:43`.
- On the follow-up check, `/Users/robiny/.codex/skills/.system` no longer existed.
- `/Users/robiny/.codex/skills/imagegen-local` still existed and remained clean against `origin/main`.
- The active Codex skill list exposed `imagegen-local`, but did not expose the bundled `imagegen` skill.
- Desktop logs for 2026-04-29 showed `image_generation` in the enabled feature list, so the built-in image-generation capability flag was still present.
- Desktop startup logs repeatedly synchronized bundled plugins, but the bundled marketplace only listed `browser-use`, `computer-use`, and `latex-tectonic`.
- A Desktop log line showed `installed system asset path="/Users/robiny/.codex/skills/chronicle/SKILL.md"`, but no comparable `imagegen` install log line was found in the app logs searched; the stronger `imagegen` evidence came from the conversation/session command output.
- Searches across `~/.codex/log/codex-tui.log` and `~/Library/Logs/com.openai.codex` found no explicit `imagegen` deletion/removal event.

Current assessment:

- This is more likely a Codex Desktop/runtime bundled system-asset injection or marketplace composition bug than a user-level skill bug.
- The absence of an explicit delete log means the exact remover is still unproven.
- The strongest hypothesis is that `.system` skills are ephemeral/generated assets: Codex created or refreshed `.system/imagegen` around `2026-04-29 23:43 +0800`, the skill was visible/usable shortly after, and a later app/runtime refresh removed or failed to preserve the whole `.system` directory.
- A secondary hypothesis is that the current bundled asset source no longer includes `imagegen`, so after `.system` disappeared the runtime could not repopulate it.
- Keeping `imagegen-local` is still the correct mitigation: it survives this failure mode and avoids same-name collisions with a future restored bundled `imagegen`.

Follow-up restart check:

- Before restarting Codex App, `/Users/robiny/.codex/skills/.system` was already missing.
- After restarting Codex App, `/Users/robiny/.codex/skills/.system` was still missing.
- `imagegen-local` stayed present and clean against `origin/main`.
- New Desktop logs around `2026-04-29T16:26:15Z` and `2026-04-29T16:27:12Z` still showed `image_generation` in the enabled feature list.
- The same restart logs wrote the bundled marketplace with only `browser-use`, `computer-use`, and `latex-tectonic`; no `imagegen` plugin/asset appeared in `/Users/robiny/.codex/.tmp/bundled-marketplaces/openai-bundled`.
- The restart therefore supports the secondary hypothesis: once `.system/imagegen` is gone, the current bundled marketplace/runtime path does not restore it.

Related upstream bug report:

- GitHub issue: https://github.com/openai/codex/issues/19265
- The issue matches this local symptom pattern: `.system`/bundled system skills can disappear after Codex App background or ephemeral execution paths.
- Local binary string evidence in `/Applications/Codex.app/Contents/Resources/codex` contains nearby strings for `imagegen/scripts`, `.codex-system-skills.marker`, `create system skills dir`, `write system skill file`, and `remove existing system skills dir`.
- This supports the product-bug assessment: the local mitigation is to keep using the user-level `imagegen-local` pinned copy, while the durable fix belongs in Codex App/system-skill lifecycle handling.

Second restart/reappearance check:

- After another Codex App restart, both skills were visible in the UI: system `Image Gen` and personal `Image Gen`/`imagegen-local`.
- Filesystem confirmed `/Users/robiny/.codex/skills/.system` existed again.
- `.system` contained `.codex-system-skills.marker`, `imagegen`, `openai-docs`, `plugin-creator`, `skill-creator`, and `skill-installer`.
- `.system`, `.system/imagegen`, `.system/imagegen/SKILL.md`, and `.codex-system-skills.marker` all had birth/mtime/ctime `2026-04-30 15:00:23 +0800`.
- Codex processes started at `2026-04-30 15:00:20-15:00:23 +0800`; `codex app-server --analytics-default-enabled` started at `15:00:23`, matching system skill creation.
- Marker contents were `26df52339bf52493`.
- App logs still only showed bundled marketplace plugins `browser-use`, `computer-use`, and `latex-tectonic`, so this `.system` creation appears to come from the Codex app-server built-in system-skill path, not the openai-bundled plugin marketplace.
- A LaunchAgent monitor was installed at `/Users/robiny/Library/LaunchAgents/com.robiny.imagegen-system-monitor.plist` and started successfully. It runs `/Users/robiny/.codex/skills/imagegen-local/scripts/monitor_system_imagegen.sh` every 2 seconds and logs state transitions to `/Users/robiny/.codex/log/imagegen-system-monitor.log`.

Deletion captured by monitor:

- `/Users/robiny/.codex/skills/.system` disappeared again on `2026-04-30`.
- The monitor recorded the transition at `2026-04-30 15:10:24 +0800`.
- The parent `/Users/robiny/.codex/skills` directory had mtime/ctime `2026-04-30 15:10:21 +0800`, so the deletion most likely occurred around `15:10:21`.
- App log context around `2026-04-30T07:10:19Z` showed Codex home/UI refresh activity: `codex-home request`, `Skills/list request cwdsCount=7`, and `skills/list` returned successfully at `07:10:19.961Z`.
- App log context at `2026-04-30T07:10:21.846Z` showed Chronicle starting a background summary: `starting summary session` and `starting codex exec summary session`, with `executable_path=codex`, `cwd="/var/folders/.../T/chronicle/screen_recording"`, `model=gpt-5.4`, `reasoning_effort=medium`.
- The timing matches upstream issue #19265: background/ephemeral Chronicle `codex exec` jobs appear able to run the system-skill cleanup path and remove the shared `.system` directory.
- Local logs did not expose the full `codex exec` argv for this run, so flags such as `--ephemeral`, `--ignore-user-config`, `--ignore-rules`, or `--config skills.bundled.enabled=false` are inferred from the upstream issue, not directly observed in this local log.
- The monitor script was hardened after this capture: future missing-state transitions append recent Codex Desktop log lines for `Skills/list`, Chronicle, `codex exec`, system-skill lifecycle strings, plugin listing, and thread startup, so later recurrences should preserve more immediate context.

Suggested evidence commands for the next recurrence:

```bash
ls -la /Users/robiny/.codex/skills/.system
ls -la /Users/robiny/.codex/skills/imagegen-local
rg -n -i "imagegen|image gen|image_gen|installed system asset|skills/list|bundled_plugins" \
  /Users/robiny/.codex/log/codex-tui.log \
  /Users/robiny/Library/Logs/com.openai.codex
find /Users/robiny/.codex/.tmp/bundled-marketplaces -maxdepth 6 -type f -print | sort
```

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
