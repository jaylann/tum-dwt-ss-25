#!/usr/bin/env bash
# build-tex.sh ─ Recursive LaTeX build & Git-add pipeline
#
# Usage: ./build-tex.sh [TARGET_DIR]
#        If TARGET_DIR is omitted, the script defaults to the current working dir.

set -euo pipefail

TARGET_ROOT="${1:-$(pwd)}"
echo "🔍 Scanning for *.tex under: ${TARGET_ROOT}"

# ──────────────────────────────────────────────────────────────────────────────
# 1. Compile every .tex file we discover
# ──────────────────────────────────────────────────────────────────────────────
find "${TARGET_ROOT}" -type f -iname '*.tex' -print0 | while IFS= read -r -d '' TEX_FILE
do
  TEX_DIR="$(dirname "${TEX_FILE}")"
  TEX_BASENAME="$(basename "${TEX_FILE}")"

  echo "⚙️  Building ${TEX_FILE}"
  (
    cd "${TEX_DIR}"
    # -pdf              → emit PDF
    # -interaction=nonstopmode → don’t pause on errors
    # -file-line-error  → verbose error context
    # -silent           → suppress chatty output (comment out if you want logs)
    latexmk -pdf -interaction=nonstopmode -file-line-error -silent "${TEX_BASENAME}"
  )
done

# ──────────────────────────────────────────────────────────────────────────────
# 2. Stage every newly minted PDF
# ──────────────────────────────────────────────────────────────────────────────
echo "📑 Staging PDFs in Git"
find "${TARGET_ROOT}" -type f -iname '*.pdf' -print0 | xargs -0 git add

echo "✅ Done – all PDFs are now in Git’s staging area."
