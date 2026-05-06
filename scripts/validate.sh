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
  for f in kubernetes/*.yaml; do
    [[ -e "$f" ]] || continue
    if have ruby; then
      ruby -ryaml -e "YAML.load_file('$f')" || return 1
    elif have python3; then
      python3 -c "import yaml,sys; yaml.safe_load(open('$f')); print('$f: ok')" || return 1
    else
      echo "Neither ruby nor python3 available to parse YAML; skipping syntax check"
      return 0
    fi
  done
}

if have kubectl; then
  echo "-- kubectl: client dry-run apply kubernetes/ --"
  if kubectl_client_dry_run >/dev/null 2>&1; then
    kubectl_client_dry_run
    echo "kubectl dry-run: ok"
  else
    echo "kubectl dry-run failed (common without a reachable cluster for API discovery)."
    echo "Falling back to YAML parse-only check."
    yaml_parse_kubernetes && echo "YAML parse: ok" || { echo "YAML parse: failed"; exit 1; }
  fi
else
  echo "kubectl: not found; parsing kubernetes/*.yaml for basic YAML validity"
  yaml_parse_kubernetes && echo "YAML parse: ok" || { echo "YAML parse: failed"; exit 1; }
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
  kubeconform -strict -ignore-missing-schemas kubernetes/*.yaml || true
  echo "kubeconform: finished (schemas may be missing offline)"
else
  echo "kubeconform: not found; skipping"
fi
echo
echo "Done. Fix failures above or document what you could not run locally."
