---
name: omo-model-profile
description: >
  Configure the Oh My OpenAgent (OMO) model selection for opencode by choosing one
  of two profiles — Optimal (best cost/benefit) or Max Performance (strongest models,
  cost ignored). Asks the user which profile they want, then writes the matching agent
  and category model map into the user-level OMO config. Use when the user wants to
  switch OMO models, pick a cost tier, or set up cheap-vs-max model profiles.
---

# Configure Oh My OpenAgent model profile

## Goal

Set the model for every OMO agent and category by applying one of two pre-defined
profiles, then verify the result. You ask the user exactly one question, then write
the config.

The two profiles map to the tiers from the model-selection reference:

- **Optimal** — the cost/benefit sweet spot. Cheapest model that still does the job,
  except the 5 quality-critical rows (Sisyphus, Hephaestus, Oracle, Momus, `ultrabrain`)
  which keep a stronger model. This is the "cheap profile with maximum performance" pick.
- **Max Performance** — the strongest documented model for every role, cost ignored.
  Claude-heavy (Opus 4.8 / Sonnet 4.6) plus GPT-5.5 at high effort. Pick this when
  performance matters more than spend.

## Constraints

- Provider is **OpenRouter only** (the sole key in `~/.local/share/opencode/auth.json`).
  Every slug below is already `openrouter/`-prefixed. Do not change the prefix.
- Config file: `~/.config/opencode/oh-my-openagent.json` (user-level, all projects).
- `variant` is a sibling key of `model` in the same object — keep it exactly as written.
- Do not invent slugs. Use the tables below verbatim.

## Step 1 — Ask the user (one question only)

Ask the user this single question and wait for the answer:

> Which OMO model profile should I apply?
>
> 1. **Optimal** — best cost/benefit. Cheap models everywhere except the 5
>    quality-critical roles. Recommended default.
> 2. **Max Performance** — strongest model for every role, cost ignored
>    (Claude Opus/Sonnet + GPT-5.5 high-effort).

Do not proceed until the user picks 1 or 2.

## Step 2 — Back up the current config

Before overwriting, make a timestamped backup:

```bash
cp ~/.config/opencode/oh-my-openagent.json \
   ~/.config/opencode/oh-my-openagent.json.bak.$(date +%Y%m%d%H%M%S) 2>/dev/null || true
```

## Step 3 — Write the chosen profile

Overwrite `~/.config/opencode/oh-my-openagent.json` with the JSON for the chosen
profile below. Keep the `$schema` line. Write the file exactly — agent and category
keys, model slugs, and any `variant` keys must match.

### Profile A — Optimal

```json
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",
  "agents": {
    "sisyphus": { "model": "openrouter/anthropic/claude-sonnet-4.6" },
    "hephaestus": { "model": "openrouter/openai/gpt-5.5", "variant": "medium" },
    "prometheus": { "model": "openrouter/z-ai/glm-5.1" },
    "atlas": { "model": "openrouter/moonshotai/kimi-k2.7-code" },
    "oracle": { "model": "openrouter/openai/gpt-5.5", "variant": "medium" },
    "librarian": { "model": "openrouter/qwen/qwen3.5-plus-02-15" },
    "explore": { "model": "openrouter/qwen/qwen3.5-plus-02-15" },
    "multimodal-looker": { "model": "openrouter/google/gemini-3-flash-preview" },
    "metis": { "model": "openrouter/z-ai/glm-5.1" },
    "momus": { "model": "openrouter/openai/gpt-5.5", "variant": "high" },
    "sisyphus-junior": { "model": "openrouter/moonshotai/kimi-k2.7-code" }
  },
  "categories": {
    "visual-engineering": { "model": "openrouter/google/gemini-3-flash-preview" },
    "artistry": { "model": "openrouter/google/gemini-3-flash-preview" },
    "ultrabrain": { "model": "openrouter/openai/gpt-5.5", "variant": "high" },
    "deep": { "model": "openrouter/deepseek/deepseek-v4-pro" },
    "quick": { "model": "openrouter/qwen/qwen3.5-plus-02-15" },
    "unspecified-high": { "model": "openrouter/moonshotai/kimi-k2.7-code" },
    "unspecified-low": { "model": "openrouter/moonshotai/kimi-k2.7-code" },
    "writing": { "model": "openrouter/moonshotai/kimi-k2.5" }
  }
}
```

### Profile B — Max Performance

```json
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",
  "agents": {
    "sisyphus": { "model": "openrouter/anthropic/claude-opus-4.8" },
    "hephaestus": { "model": "openrouter/openai/gpt-5.5", "variant": "medium" },
    "prometheus": { "model": "openrouter/anthropic/claude-opus-4.8" },
    "atlas": { "model": "openrouter/anthropic/claude-sonnet-4.6" },
    "oracle": { "model": "openrouter/openai/gpt-5.5", "variant": "high" },
    "librarian": { "model": "openrouter/openai/gpt-5.4-mini" },
    "explore": { "model": "openrouter/x-ai/grok-code-fast-1" },
    "multimodal-looker": { "model": "openrouter/google/gemini-3.1-pro-preview" },
    "metis": { "model": "openrouter/anthropic/claude-sonnet-4.6" },
    "momus": { "model": "openrouter/openai/gpt-5.5", "variant": "xhigh" },
    "sisyphus-junior": { "model": "openrouter/anthropic/claude-sonnet-4.6" }
  },
  "categories": {
    "visual-engineering": { "model": "openrouter/google/gemini-3.1-pro-preview", "variant": "high" },
    "artistry": { "model": "openrouter/google/gemini-3.1-pro-preview", "variant": "high" },
    "ultrabrain": { "model": "openrouter/openai/gpt-5.5", "variant": "xhigh" },
    "deep": { "model": "openrouter/openai/gpt-5.5", "variant": "medium" },
    "quick": { "model": "openrouter/openai/gpt-5.4-mini" },
    "unspecified-high": { "model": "openrouter/anthropic/claude-opus-4.8", "variant": "max" },
    "unspecified-low": { "model": "openrouter/anthropic/claude-sonnet-4.6" },
    "writing": { "model": "openrouter/moonshotai/kimi-k2.5" }
  }
}
```

## Step 4 — Known caveats (tell the user)

- **Opus 4.8 override.** OMO's hardcoded fallback chains default to Opus **4.7** for
  budget stability. The explicit `agents.<name>.model` entries above are what activate
  Opus 4.8 — do not remove them.
- **Librarian (Max Performance only).** The reference lists "GPT-5.4-mini-fast" as the
  ideal here, but its exact OpenRouter slug is unverified. The config above falls back
  to the verified `openrouter/openai/gpt-5.4-mini`. To use the faster variant if it
  exists, run `opencode models | grep -i '5.4-mini'` and, only if a `-fast` slug is
  listed, replace the librarian slug with it.
- **Prompt caching** can cut effective cost 60–80% on repeated context (Kimi/Claude
  families); not reflected in the tier pricing.

## Step 5 — Verify

Confirm every agent/category resolved to the intended model instead of silently falling
through to a chain default:

```bash
bunx oh-my-opencode doctor
```

If `doctor` reports a key fell through to a default (especially `sisyphus`), report the
mismatch to the user — the running OMO build may not accept that override key.

## Step 6 — Report

Tell the user: which profile was applied, the backup file path, and the result of
`doctor`. Do not restart any agents or take further action unless asked.
