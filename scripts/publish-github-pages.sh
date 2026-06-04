#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ $# -lt 1 ]]; then
  echo "用法: $0 <GitHub用户名> [仓库名]"
  echo "示例: $0 myname zhenxun-privacy"
  echo ""
  echo "请先在 GitHub 创建空仓库（不要初始化 README），再运行本脚本。"
  exit 1
fi

GITHUB_USER="$1"
REPO_NAME="${2:-zhenxun-privacy}"
REMOTE="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
PAGES_URL="https://${GITHUB_USER}.github.io/${REPO_NAME}/"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  git init
  git branch -M main
fi

git add docs/ scripts/publish-github-pages.sh 2>/dev/null || true
git add docs/

if git diff --cached --quiet; then
  echo "没有需要提交的 docs 变更。"
else
  git commit -m "Publish privacy policy for GitHub Pages"
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "已存在 origin，执行 push…"
  git push -u origin main
else
  git remote add origin "$REMOTE"
  echo ""
  echo "即将推送到: $REMOTE"
  echo "若仓库尚未创建，请打开: https://github.com/new?name=${REPO_NAME}"
  read "?按回车继续 push…"
  git push -u origin main
fi

echo ""
echo "=========================================="
echo "请在 GitHub 开启 Pages："
echo "  https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/pages"
echo "  Source: Deploy from branch → main → /docs"
echo ""
echo "开启后隐私政策 URL："
echo "  ${PAGES_URL}"
echo "=========================================="
