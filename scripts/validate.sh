#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== DevOps Test Drive: validate (best-effort) =="
echo

have() { command -v "$1" >/dev/null 2>&1; }

if have docker; then
  echo "-- docker: building image (validation tag) --"
  docker build -t devops-testdrive-validate:local .
  echo "docker build: ok"
else
  echo "docker: not found; skipping image build"
fi
echo

kubectl_client_dry_run() {
  kubectl apply --dry-run=client --validate=false -f kubernetes/
}

yaml_parse_kubernetes() {
  local f

  if have ruby; then
    for f in kubernetes/*.yaml; do
      [[ -e "$f" ]] || continue
      ruby -ryaml -e "YAML.load_file('$f')" || return 1
    done
    echo "YAML parse (ruby): ok"
    return 0
  fi

  if have python3 && python3 -c "import yaml" >/dev/null 2>&1; then
    for f in kubernetes/*.yaml; do
      [[ -e "$f" ]] || continue
      python3 -c "import yaml; yaml.safe_load(open('$f')); print('$f: ok')" || return 1
    done
    echo "YAML parse (python/PyYAML): ok"
    return 0
  fi

  echo "YAML parse: skipped (install Ruby, or Python with PyYAML, for offline syntax checks)"
  return 0
}

if have kubectl; then
  echo "-- kubectl: client dry-run apply kubernetes/ --"
  if kubectl_client_dry_run >/dev/null 2>&1; then
    kubectl_client_dry_run
    echo "kubectl dry-run: ok"
  else
    echo "kubectl dry-run failed (common without a reachable cluster for API discovery)."
    echo "Falling back to YAML parse-only check."
    yaml_parse_kubernetes || exit 1
  fi
else
  echo "kubectl: not found; parsing kubernetes/*.yaml for basic YAML validity (best-effort)"
  yaml_parse_kubernetes || exit 1
fi
echo

if have terraform; then
  echo "-- terraform fmt (check) --"
  terraform -chdir=terraform fmt -check -recursive || {
    echo "terraform fmt -check: failed (run 'terraform fmt -recursive' in terraform/ to fix)"
    exit 1
  }
  echo "terraform fmt -check: ok"
else
  echo "terraform: not found; skipping fmt check"
fi
echo

if have yamllint; then
  echo "-- yamllint --"
  yamllint .
  echo "yamllint: ok"
else
  echo "yamllint: not found; skipping"
fi
echo

if have kubeconform; then
  echo "-- kubeconform --"
  kubeconform -strict -ignore-missing-schemas kubernetes/*.yaml || {
    echo "kubeconform found issues; fix them or document why they remain."
  }
  echo "kubeconform: finished (schemas may be missing offline)"
else
  echo "kubeconform: not found; skipping"
fi
echo
echo "Done. Fix failures above or document what you could not run locally."
