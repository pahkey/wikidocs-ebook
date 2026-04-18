#!/usr/bin/env bash

set -euo pipefail

print_usage() {
  cat <<'EOF'
사용법:
  scripts/commit-and-push.sh
  scripts/commit-and-push.sh "커밋 메시지"

설명:
  변경사항을 모두 스테이징한 뒤 커밋하고 push합니다.
  커밋 메시지를 인자로 주지 않으면 실행 중에 입력받습니다.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_usage
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Git 저장소 안에서 실행해야 합니다." >&2
  exit 1
fi

message="${*:-}"

if [[ -z "$message" ]]; then
  read -r -p "커밋 메시지를 입력하세요: " message
fi

if [[ "$message" =~ ^[[:space:]]*$ ]]; then
  echo "커밋 메시지가 비어 있습니다." >&2
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "커밋할 변경사항이 없습니다."
  exit 0
fi

git commit -m "$message"

if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git push
else
  branch="$(git branch --show-current)"
  git push -u origin "$branch"
fi
