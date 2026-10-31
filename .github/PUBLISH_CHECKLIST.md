# Publish checklist — agent-mac-awake

Report from the `github-launch` skill. Status is `pass`, `fail`, or `skip`. This file does not block `git push`.

| Item | Status | Note |
| --- | --- | --- |
| Intake recorded (kind, audience, languages, owner) | pass | CLI. Audience: people running long Cursor or Grok Bot jobs on a Mac. Languages: Bash, no package manifest. Owner: loomlab-ai. LICENSE copyright holder LofiSu, kept. |
| Secrets scan | pass | No private keys, tokens, or tracked env/pem files. |
| Personal data scan | pass | No phone, employer, or private email. Sample plist uses /Users/REPLACE_ME, rewritten on install. |
| Dead demos removed or kept on purpose | pass | No stock framework README or dead private demo. Clone URLs now use github.com/loomlab-ai/agent-mac-awake. |
| License headers match LICENSE, or none required | pass | No SPDX headers. bin/agent-awake MIT line matches LICENSE. |
| `.gitignore` covers secrets and build output | pass | Added .DS_Store, *.pem, *.key, .env, .env.*, and !.env.example. |
| Large binaries reviewed | pass | No tracked file at or above 1 MB. |
| LICENSE present; SPDX matches the README | pass | Existing MIT kept. SPDX MIT matches both READMEs. Copyright (c) 2026 LofiSu. |
| `README.md` and `README.zh-CN.md` share structure and facts | pass | Same headings, commands, flags, and label com.lofisu.agent-awake. |
| No double-brace uppercase placeholders left in published files | pass | Placeholder scan of README, LICENSE, docs, and this checklist is clean. |
| About description is 160 characters or fewer | pass | agent-mac-awake keeps a Mac awake during long Cursor and Grok Bot runs. Thin caffeinate wrapper plus an optional LaunchAgent. (125). gh repo edit returned 403, so the About field was not set. |
| 5–10 topics | pass | macos, caffeinate, cursor, ai-agent, keep-awake, launchd, macbook. gh repo edit returned 403, so topics were not set. |
| CI workflow matches the stack | pass | shellcheck.yml left unchanged. It lints bin/ and scripts/. No second workflow. |
| Pages decision recorded; the agent did not enable Pages | pass | docs/index.html, docs/.nojekyll. Not enabled. Settings → Pages → Deploy from a branch → /docs. |
| Homepage URL recorded; set only after the site loads | pass | Unset. After the site loads: gh repo edit --homepage https://loomlab-ai.github.io/agent-mac-awake/ |
| Visibility left private for the coordinator | pass | Not changed. After merge: gh repo edit --visibility public |
| Push | pass | Branch cursor/github-launch-packaging-9a1d. Secret scan passed. |
