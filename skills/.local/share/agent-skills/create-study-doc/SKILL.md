---
name: create-study-doc
description: >-
  Builds a printable LaTeX study PDF from lecture PDFs, slides, and course notes:
  OCR/read scans, crop figures, pedagogical order, short complete sentences with
  bold exam terms, compact figures, Quick Recall at the end. Use when the user
  asks for study notes, a quiz/exam binder, printable lecture notes, creat-study-doc,
  create-study-doc, or to turn course PDFs into a study document.
---

# Create a printable study document

Turn a folder of lecture PDFs / slides into one **printable LaTeX study PDF**.
Do not summarise the sources into a skim. Capture the points. Rewrite them so they
are easy to learn.

## Hard rules (user, binding)

These beat any earlier voice in the chat:

1. **Simple English.**
2. **Short complete sentences.** One idea per bullet. Important exam names in `\term{}` (bold).
3. Decoding telegram fragments takes more effort than reading a sentence. **Forbidden:** `DCEN: deep, no clean. W cool → 400 A.`
4. Packed five-fact bullets are also forbidden. Merge fragments into a readable sentence; do not pack harder.
5. **Do not omit source points.** Spread them across sentences.
6. **Figures stay small.** Crop chrome. Cap height. Drop duplicates and photo-only slides.
7. Order by **ease of learning**, not the syllabus list.
8. Last pages = **Quick Recall**, printable alone.

## Workflow

Copy and track:

```
- [ ] 1. Inventory sources + write PLAN.md
- [ ] 2. Extract text (OCR + visual read of scans)
- [ ] 3. Crop teaching figures into studyfigs/
- [ ] 4. Choose pedagogical order
- [ ] 5. Write LaTeX (sentences + compact figs + Quick Recall)
- [ ] 6. Compile, then visually check pages
- [ ] 7. Fix leftover huge figures / leftover telegram bullets
```

### 1. Plan file (fights context rot)

Write `STUDY_GUIDE_PLAN.md` next to the notes **before** the long extract.

Put in it: source files, pedagogical order, voice rules, figure folder, what is already in the `.tex`.

**Re-read the plan before every later edit.** Chat memory will rot. The plan is the source of truth for style and coverage. If the user changes voice, update the plan in the same turn.

### 2. Extract the PDFs

Lecture decks are usually **scans or slide-exports**. `pdfplumber` / `pdftotext` often return almost nothing. Do not stop there.

Default pipeline (commands in [reference.md](reference.md)):

1. `pdfinfo` for page count.
2. Rasterise with `pdftoppm -png -r 200`.
3. **Look at the PNGs** with the image Read tool (diagrams, tables, polarity charts). OCR misses arrows and labelled sketches.
4. OCR bulk text with `tesseract`. Concatenate into one `.txt` for search.
5. For a native-text book chapter, try `pdftotext -layout` first; fall back to the scan pipeline if the output is junk.

When two sources disagree on a formula, **teach the book/standard form** and footnote the slide error. Do not silently pick one.

Skip slides that are only a photo with no teaching point.

### 3. Figures

Save crops under `studyfigs/` with short names (`rw_cycle.png`, not `Slide 14 final.png`).

- Crop beige/blue slide chrome, headers, footers, and giant `FIGURE 2.18` labels.
- One teaching diagram per idea. If two figures show the same four steps, keep one.
- In LaTeX, **always** cap size:

```latex
\includegraphics[width=0.46\linewidth,height=0.20\textheight,keepaspectratio]{name.png}
```

Use `width=0.36\linewidth` for side-by-side. Wide landscape plots can sit at 0.46 because they are short. Never `0.90\linewidth` on a slide screenshot.

Caption: one simple-English sentence. `captionsetup{font=footnotesize,skip=2pt}`.

### 4. Pedagogical order

Syllabus list ≠ reading order. Put shared physics first, then the process that only needs that physics, then the ones that add gas / filler / constriction.

Example from MCL135 Quiz 2: heat / \(I^2R\) → resistance welding (no arc) → SMAW idea → GTAW → A-TIG → PAW → spray → GMAW → SAW/FCAW/ESW → Quick Recall.

Say the syllabus on page 1, then tell the reader the learning order.

### 5. Voice in the `.tex`

Each bullet is a **short complete sentence** (two if the why is needed). Bold only exam words.

```latex
\newcommand{\term}[1]{\textbf{#1}}
```

**Good**

> `\term{DCEN}` (also called DCSP) means the electrode is negative, so electrons hit the work: you get a deep, narrow weld, no oxide cleaning, and a cool tungsten that can take high current (a 3.2 mm tip \(\approx\) 400 A).

**Bad (telegram)**

> DCEN = DCSP = electrode negative. Electrons hit the work. Deep, narrow. No clean. 400 A.

**Bad (packed)**

> DCEN/DCSP, electrode −, electrons → work, deep/narrow, no cleaning, W cool so 3.2 mm ≈ 400 A, default for steel TIG/PAW.

How-to-use line on page 1: *Read the sentence; the bold word is what you write in the exam.*

Numbers, named cycles, colour codes, and comparison tables stay in the notes, not only in Quick Recall.

Preamble and boxes: [reference.md](reference.md).

### 6. Quick Recall

Last pages, `\clearpage` before them, printable alone.

- One-line process definitions
- Must-write numbers table
- Compare-the-family table
- A 60-second recitable box

Do **not** make Quick Recall the only place a fact appears.

### 7. Compile and check

```bash
pdflatex -interaction=nonstopmode -halt-on-error Notes.tex
```

Then:

- `grep Overfull Notes.log`
- Rasterise a few pages (`pdftoppm -png -r 110 -f N -l N`) and **Read the PNGs**
- Hunt leftover full-width figures and leftover telegram lists
- Fix, **then** recompile. Never compile in the same parallel tool batch as the `.tex` edits — the PDF will be stale.

## Anti-patterns

- Starting from the syllabus heading order because that is how the PDFs are named
- Trusting `pdfplumber` on a scanned deck
- Dumping uncropped slide screenshots at `0.9\linewidth`
- Keeping two figures that teach the same four steps
- Telegram bullets after a user asked for sentences
- Omitting a source number because it made the bullet long — write another sentence
- Relying on chat memory instead of `STUDY_GUIDE_PLAN.md`
