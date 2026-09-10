# devops_testdrive - agent guide

This repo is moving its agent configuration from Cursor to Claude Code. Until that
finishes, the Cursor rules are still the source of truth for how to work here, and this
file is the entry point that gets you to them.

## Read the Cursor rules first

Before starting any task, read every file under `.cursor/` and follow it as if it were
written here. Rules live in `.cursor/rules/`, either as `.mdc` files or as subdirectories
of them, and a rule's frontmatter may say it only applies to certain paths. If `.cursor/`
doesn't exist or holds no rules, there are no repo-specific agent instructions yet, and
this file is where they should be added.

Repo-specific guidance will move into this file over time. When you find something the
Cursor rules get wrong for the code as it is now, fix it here rather than in `.cursor/`.
