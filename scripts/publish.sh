#!/usr/bin/env bash
# Build the Jupyter Book and sync the static output into the
# fun-in-space.com Astro site at ~/dev/fun-in-space-site/public/sc-course/.
#
# Usage:
#   ./scripts/publish.sh
#
# After this runs, cd to ~/dev/fun-in-space-site, commit, and push.
# Netlify will redeploy the combined site automatically.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_DIR="${SC_COURSE_SITE_DIR:-$HOME/dev/fun-in-space-site}"
DEST_DIR="$SITE_DIR/public/sc-course"

cd "$REPO_ROOT"

if [[ ! -d "$SITE_DIR" ]]; then
  echo "Error: $SITE_DIR not found." >&2
  echo "Set SC_COURSE_SITE_DIR if your Astro site lives elsewhere." >&2
  exit 1
fi

echo "==> Building Jupyter Book at $REPO_ROOT"
jupyter-book build . --all

echo "==> Syncing _build/html/ -> $DEST_DIR"
mkdir -p "$DEST_DIR"
rsync -av --delete "_build/html/" "$DEST_DIR/"

echo "==> Done."
echo
echo "Next steps:"
echo "  cd $SITE_DIR"
echo "  git add public/sc-course"
echo "  git commit -m 'Update sc-course: <short description>'"
echo "  git push"
echo
echo "Netlify will redeploy fun-in-space.com automatically."
