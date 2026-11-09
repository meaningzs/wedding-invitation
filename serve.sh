#!/usr/bin/env bash
# Docker 없이 빌드 후 서빙합니다.
#   PORT=8080 BASE_PATH=/ ./serve.sh
# 환경변수(VITE_*)는 .env 파일 또는 셸 환경변수로 주입하세요.
set -euo pipefail
cd "$(dirname "$0")"

PORT="${PORT:-8080}"
HOST="${HOST:-0.0.0.0}"
BASE_PATH="${BASE_PATH:-/}"

if [ ! -d node_modules ]; then
  npm ci
fi

npm run build -- --base="$BASE_PATH"
exec npx vite preview --host "$HOST" --port "$PORT" --strictPort --base "$BASE_PATH"
