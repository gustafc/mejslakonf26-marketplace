# mejslakonf26-marketplace

A local Claude Code plugin marketplace containing one demo plugin, `demo-plugin`.

## Contents

```
.claude-plugin/marketplace.json          # marketplace catalog
plugins/demo-plugin/
  .claude-plugin/plugin.json             # plugin manifest
  commands/hello.md                      # /hello: prompt-only command (single markdown file)
  skills/release-notes/SKILL.md          # /release-notes: skill with supporting template
  skills/release-notes/template.md
  bin/collect-commits                    # on the Bash tool's PATH while the plugin is enabled
  hooks/hooks.json                       # PreToolUse hook registration
  scripts/guard-migrations.sh            # blocks edits to committed Flyway migrations
```

## Install

Development loop (no install, current session only):

    claude --plugin-dir ./plugins/demo-plugin

Via the marketplace (as your coworkers would):

    /plugin marketplace add gustafc/mejslakonf26-marketplace
    # or
    /plugin marketplace add git@github.com:gustafc/mejslakonf26-marketplace.git

    /plugin install demo-plugin@mejslakonf26-marketplace

A marketplace added from a local directory loads the plugin in place, so edits apply after
`/reload-plugins` without a version bump.

Useful commands:

    claude plugin validate ./plugins/demo-plugin
    claude plugin details demo-plugin@mejslakonf26-marketplace   # components + token cost

The hook needs `jq`. Without it, the hook warns and allows the edit (fails open).

## Demo notes

- `/hello Alice`: the whole command is a prompt with `$ARGUMENTS`.
- `/release-notes 0.2.0` in the mejslakonf26-todo-app (tag the baseline `v0.1.0` first, and use
  conventional commit messages on the demo branch). Points to show:
  - `!` + backticked command runs `collect-commits` before the model sees the prompt, so the
    commit list and date are deterministic; only grouping and wording are left to the model.
  - `disable-model-invocation: true`: only the user can trigger it, because it writes files.
  - `allowed-tools` pre-approves the tools the skill needs.
  - Include a commit without a conventional prefix to show the "uncertain commits" handling.
- Hook: ask Claude to change a column in `V1__init.sql`. The edit is blocked and Claude is told
  why. It should then propose a new migration instead.

## Limitations worth discussing

- The hook only sees Edit/Write tool calls. A shell command via the Bash tool (`sed -i ...`)
  bypasses it. A Bash matcher could inspect commands, but only heuristically.
- The jq-missing case fails open. Fail-closed is safer but blocks every edit on machines without jq.
- Hooks and `bin/` scripts run with your user's permissions. Installing a plugin means trusting
  its author.
