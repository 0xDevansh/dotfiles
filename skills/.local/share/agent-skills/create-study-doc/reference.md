# create-study-doc — commands, preamble, OCR notes

Read this after SKILL.md when actually extracting or writing the `.tex`.

## Rasterise a lecture PDF

200 dpi for crops and OCR. 110 dpi is enough to visually check a compiled notes PDF.

```bash
PDF="lecture.pdf"
OUT=/tmp/slides
mkdir -p "$OUT"
pdfinfo "$PDF" | grep Pages
pdftoppm -png -r 200 "$PDF" "$OUT/p"
ls "$OUT"
```

Need one page:

```bash
pdftoppm -png -r 200 -f 7 -l 7 "$PDF" "$OUT/p"
```

## OCR

`pdfplumber` and `pdftotext` fail on most slide decks (they are images). After `pdftoppm`:

```bash
mkdir -p /tmp/ocr
for f in /tmp/slides/p-*.png; do
  base=$(basename "$f" .png)
  tesseract "$f" "/tmp/ocr/$base" -l eng
done
cat /tmp/ocr/*.txt > /tmp/ocr/all.txt
```

One page to stdout:

```bash
tesseract /tmp/slides/p-07.png stdout -l eng
```

Native-text PDF first try:

```bash
pdftotext -layout lecture.pdf /tmp/lecture.txt
# If the .txt is empty or garbage, use the scan pipeline.
```

**Look at the PNGs.** OCR garbles subscripts (`I²R` → `12R`), polarity diagrams, and labelled sketches. The image Read tool is the source of truth for figures and for "what is this slide actually teaching?".

## Crop figures

Slide screenshots include beige chrome, headers, and giant figure numbers. Crop to the diagram.

Python (Pillow). Box is `(left, top, right, bottom)` in pixels on the **200 dpi** PNG:

```python
from PIL import Image
im = Image.open("/tmp/slides/p-07.png")
im.crop((80, 140, 1480, 980)).save("studyfigs/rw_cycle.png")
```

Print size first if you need to guess the box:

```python
print(im.size)  # (width, height)
```

Skip the crop if:

- the slide is a photo with no teaching diagram
- another figure already shows the same steps
- the crop would cut axis labels (then either recrop or drop the figure)

Names: `rw_cycle.png`, `paw_keyhole.png`. Short, stable, no spaces.

## LaTeX figure size

Always cap **width and height**:

```latex
\includegraphics[width=0.46\linewidth,height=0.20\textheight,keepaspectratio]{rw_cycle.png}
```

| Case | Width |
|---|---|
| Default teaching diagram | `0.46\linewidth` |
| Side-by-side pair | `0.36\linewidth` each + `\hfill` |
| Tiny inset (heat-balance sketch) | `0.30\linewidth` |

Do not use `0.90\linewidth` on a raster slide. Height cap `0.20\textheight` stops tall 4:3 slides eating the page even at modest width.

## Preamble (copy, then rename)

```latex
\documentclass[10pt,a4paper]{article}
\usepackage[a4paper,left=1.6cm,right=1.6cm,top=1.5cm,bottom=1.6cm]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs,array,tabularx,multirow}
\usepackage{enumitem}
\usepackage{xcolor}
\usepackage{titlesec,fancyhdr,parskip}
\usepackage{tcolorbox}
\tcbuselibrary{skins,breakable}
\usepackage{float,microtype,caption}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\captionsetup{font=footnotesize,skip=2pt,labelfont=bf}
\graphicspath{{studyfigs/}}

\definecolor{ink}{HTML}{1a1a1a}
\definecolor{rulegray}{HTML}{3a3a3a}
\definecolor{keybg}{HTML}{eef3f8}
\definecolor{recallbg}{HTML}{fff8e6}
\definecolor{okbg}{HTML}{eef8ee}

\titleformat{\section}{\large\bfseries\color{ink}}{\thesection}{0.45em}{}[\titlerule]
\titleformat{\subsection}{\normalsize\bfseries\color{ink}}{\thesubsection}{0.35em}{}
\titlespacing*{\section}{0pt}{8pt}{4pt}
\titlespacing*{\subsection}{0pt}{6pt}{2pt}
\setlist[itemize]{leftmargin=1.2em,itemsep=2.0pt,topsep=2.5pt,parsep=0.8pt}

\newtcolorbox{keybox}{
  colback=keybg, colframe=rulegray, boxrule=0.5pt, arc=1pt,
  left=5pt, right=5pt, top=3pt, bottom=3pt, breakable, fontupper=\small}
\newtcolorbox{memobox}{
  colback=recallbg, colframe=rulegray, boxrule=0.6pt, arc=1pt,
  left=5pt, right=5pt, top=3pt, bottom=3pt, breakable, fontupper=\small}
\newtcolorbox{okbox}{
  colback=okbg, colframe=rulegray, boxrule=0.5pt, arc=1pt,
  left=5pt, right=5pt, top=3pt, bottom=3pt, breakable, fontupper=\small}

\newcommand{\term}[1]{\textbf{#1}}
\newcommand{\why}[1]{\textit{#1}}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small COURSE --- Study notes}
\fancyhead[R]{\small topic $\cdot$ topic}
\fancyfoot[C]{\small\thepage}
\renewcommand{\headrulewidth}{0.4pt}
```

`keybox` = how-to-use / must-compare. `memobox` = worked exam number. `okbox` = recitable block.

## Compile loop

```bash
pdflatex -interaction=nonstopmode -halt-on-error Notes.tex
grep -E "Overfull|Error" Notes.log
pdftoppm -png -r 110 -f 1 -l 4 Notes.pdf /tmp/chk/p
```

Read `/tmp/chk/p-01.png` (and a middle page, and Quick Recall). If a figure still dominates the page, drop it or shrink that one include. If a list is still fragments, rewrite those bullets into sentences.

**Do not** `pdflatex` in the same parallel tool batch as the `StrReplace` / Write that changes the `.tex`. The compiler will read the old file.

## PLAN.md skeleton

```markdown
# COURSE quiz N — working plan

Read this before every edit to Notes.tex.

## Files
- Notes: path.tex → path.pdf
- Figures: studyfigs/
- Sources: list every PDF

## Voice
- Short complete sentences. \term{} for exam names.
- No telegram. No packed bullets.
- Do not omit source points.

## Pedagogical order
1. ...
2. ...

## Coverage checklist
- [ ] every named process
- [ ] every formula / number / colour code
- [ ] Quick Recall rewritten after the last chapter
```

## Helper script

`scripts/extract-slides.sh` rasterises + OCRs a PDF into a directory. Run it; then Read the PNGs yourself.
