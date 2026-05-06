# DevOps — Test Drive Assignment

You are inheriting a **small deployment repository** for a hypothetical **Nginx-based static site**. The codebase is meant to resemble something a team might ship quickly and refine later: plausible structure, gaps, and tradeoffs that matter in production.

This exercise is **open-book**. You may use AI assistants, search, documentation, and any tools you would normally use at work. We are evaluating how you **prioritize, validate, and explain** your work, not whether you can recall syntax from memory.

---

## What exists in this repo

| Area | Contents |
|------|----------|
| **Application** | A minimal static site under `app/` (`index.html`, `healthz.html`). There is no application server or build toolchain beyond what you add. |
| **Container image** | A starter `Dockerfile` and `.dockerignore` you should review. |
| **Kubernetes** | Manifests under `kubernetes/` for a web Deployment, Service, Ingress, and a **secondary** CronJob. The web workload is the **primary** focus; the CronJob is optional depth. |
| **Terraform** | AWS-focused configuration for **ECR** and an **IAM role for GitHub Actions (OIDC)** related to image publishing. It is **not** a full platform. |
| **CI/CD** | A GitHub Actions workflow under `.github/workflows/deploy.yaml` to review. |
| **Local validation** | A simple `scripts/validate.sh` (and `make validate`) that runs checks **when tools are available**; it is not exhaustive. |
| **Handoff notes** | `CANDIDATE_NOTES.md` — **complete this file** before your review session (brief sections are fine). |

---

## What does *not* exist (and you are not required to build all of it)

- Real cloud credentials or a live Kubernetes cluster.
- A Helm chart, full observability stack, or multi-environment pipeline design implemented end-to-end—unless you choose to sketch or partial-implement pieces and document the rest.
- “Perfect” production-grade defaults everywhere; the repo is **supposed** to leave meaningful work on the table.

---

## Your mission

Within the time allotted for the Test Drive, make the **safest, highest-value** improvements you can. Typical expectations include:

1. **Dockerfile** — Review and improve the image build for this static site (scope, tags, layers, what belongs in the image, health/readiness story as appropriate).
2. **Kubernetes** — Review and improve the manifests for the **web deployment** first; treat the CronJob as secondary unless you have time.
3. **Terraform** — Review the ECR and GitHub OIDC IAM pieces from security, operability, and maintainability angles (`terraform fmt`, reasoning about policies, tags, lifecycle, etc.).
4. **CI/CD** — Review and improve the workflow **or**, if time runs short, document a **better** deployment design (branching, tagging, environments, secrets vs OIDC, rollout/rollback, gates).
5. **Documentation** — Please **fill in `CANDIDATE_NOTES.md` as part of your handoff** (assumptions, tradeoffs, validation, **how you used AI**). It is acceptable for sections to be brief.

You may **not** complete every optional improvement. **Prioritization** is part of the assessment.

---

## What we care about

- **Prioritization** — What you tackle first and what you explicitly defer, with reasoning.
- **Safety** — Blast radius, secrets handling, branch/tag policies, least privilege, and CI behavior.
- **Correctness** — Kubernetes wiring (labels, selectors, ports, Ingress backends), image contents, and whether changes behave as intended.
- **Production-readiness** — Probes, resources, rollout strategy, image immutability, drift, and operational footguns—even if you only partially implement fixes.
- **Communication** — Clear notes for reviewers: intent, tradeoffs, and known gaps.
- **Validation** — What you ran (`docker build`, dry-runs, fmt/validate, linters, etc.) and what you could not run.
- **Responsible AI usage** — What you asked AI to do, what you accepted vs rejected, and how you **verified** AI-suggested changes.

---

## What we do *not* expect

- A perfect, production-grade platform delivered in one sitting.
- Real AWS accounts, ECR repositories, or clusters wired up for this exercise.
- A successful deploy to an actual environment (unless you happen to have a safe sandbox and choose to use it—**not required**).
- Completion of every optional file, CronJob hardening, or workflow feature.

---

## Suggested workflow

1. Skim the repo and **triage** issues (objective bugs vs judgment calls).
2. Improve **Docker + core Kubernetes + notes** before spending deep time on edge cases.
3. Run `make validate` or `./scripts/validate.sh` if you have Docker / kubectl / Terraform locally; note gaps when tools are missing. If `kubectl` cannot reach a cluster (API discovery), the script falls back to a basic YAML parse of `kubernetes/` instead of failing outright.
4. For Terraform, `terraform fmt` is reasonable without credentials; `terraform validate` often needs `terraform init` and provider configuration—document what you could and could not run.

---

## Final demo / handoff expectations

When you walk through your work with the team, be prepared to cover:

1. **Highest-priority issues** you found (security, reliability, CI/CD footguns).
2. **Changes you made** (or designs you documented if you did not implement).
3. **Assumptions** (environments, cluster Ingress controllers, registry layout, etc.).
4. **What you validated** (commands, dry-runs, reviews) and what remains unverified.
5. **What is incomplete or still risky** — honesty matters more than pretending it is done.
6. **How the deployment flow would work** end-to-end in a real org (build → tag → push → deploy → rollback concepts).
7. **How AI was used and reviewed** — required detail lives in `CANDIDATE_NOTES.md`.

Good luck—we are looking forward to how you **think**, not just what files you touch.
