#!/usr/bin/env bash
# Rasterise a lecture PDF and OCR every page.
# Usage: extract-slides.sh lecture.pdf [outdir]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: extract-slides.sh lecture.pdf [outdir]" >&2
  exit 1
fi

PDF=$1
OUT=${2:-/tmp/slide_extract}
DPI=${DPI:-200}

if [[ ! -f "$PDF" ]]; then
  echo "No such file: $PDF" >&2
  exit 1
fi

mkdir -p "$OUT/pages" "$OUT/ocr"
echo "Pages:"
pdfinfo "$PDF" | grep Pages || true

pdftoppm -png -r "$DPI" "$PDF" "$OUT/pages/p"

shopt -s nullglob
pages=("$OUT/pages"/p*.png)
if [[ ${#pages[@]} -eq 0 ]]; then
  echo "pdftoppm produced no PNGs" >&2
  exit 1
fi

for f in "${pages[@]}"; do
  base=$(basename "$f" .png)
  tesseract "$f" "$OUT/ocr/$base" -l eng >/dev/null
done

cat "$OUT/ocr"/*.txt > "$OUT/all.txt"
echo "Wrote ${#pages[@]} pages to $OUT/pages/"
echo "OCR: $OUT/all.txt"
echo "Open the PNGs — OCR misses diagrams."
