---
name: matlab-publication-diagrams
description: Create publication-ready (paper-ready) diagrams in MATLAB with a bundled vector drawing library (pdlib) - flowcharts, algorithm/methodology diagrams, process flow diagrams (PFD) and P&ID-style schematics with equipment symbols (hydrocyclones, mills, pumps, tanks, thickeners, screens, instruments), plant layouts drawn to scale, system/software/project architecture diagrams, and neural-network / machine-learning diagrams (MLP neurons, layer-block architectures, CNN tensors, surrogate-optimization loops). Use this skill whenever the user wants a diagram, schematic, figure or "esquema" made in MATLAB or Octave for a paper, journal, thesis, report or poster - even if they only say "diagrama de flujo", "diagrama del proceso", "figura para el paper", "arquitectura del proyecto", "dibuja la red neuronal" or name a journal - and whenever they need vector PDF/EPS/SVG output at exact column width. Not for data plots (line/bar/scatter charts of data), which plain MATLAB plotting handles.
---

# MATLAB publication-ready diagrams

This skill produces diagrams that can go straight into a journal. They are exact
column width, have real font sizes, embed vector text, use a colour-blind-safe
palette with consistent colour meaning, and contain no overlapping labels. The
work is done by **pdlib**, a small MATLAB/Octave library in `scripts/pdlib/`,
plus a render-inspect-fix loop.

The key idea behind pdlib is that **1 data unit = 1 cm on paper**. Positions,
sizes and gaps are in centimetres, and font sizes and line widths in points,
exactly as printed. There is no "scale the figure down later" step, which is
the step that ruins most MATLAB diagrams (7 pt text becomes 4 pt, lines turn
into hairlines).

## Setup

```matlab
addpath('<skill>/scripts/pdlib');  pd_setup();   % once per session
```

When delivering to the user, copy `scripts/pdlib/` next to their script, or
tell them where to put it. They run the `.m` file in MATLAB R2019b or newer;
Octave 7+ also works.

## Workflow

Follow these steps in order. Step 5 is what separates a clean figure from a
merely plausible one, so do not skip it.

### 1. Pin down the target
Establish these before drawing. Ask only if the answer changes the drawing a
lot and cannot be inferred:

- **Venue.** Pick the style preset: `pd_style('ieee'|'elsevier'|'springer'|'acs'|'mdpi'|'thesis'|'slides')`.
  If the venue is unknown, use `'elsevier'`; its sizes are a safe middle ground.
- **Width.** `'single'`, `'mid'` (1.5 column) or `'double'`. Complex process
  and architecture diagrams almost always need `'double'`. Height is free,
  up to about 23 cm.
- **Label language.** Write labels in the paper's language, not necessarily
  the chat's language.
- **Grayscale.** If the figure must survive grayscale printing, use
  `pd_style(p, 'Palette','gray')` and rely on line styles.
- **Output formats.** Default to PDF (vector) + PNG (600 dpi). Add EPS, SVG or
  TIFF if the journal asks.

### 2. Read the recipe for the diagram type
Open `references/diagram-recipes.md` and read the section you need:
flowchart, PFD/P&ID, plant layout, architecture, or ML/neural network. Each
section gives conventions reviewers expect (ISO 5807 shapes, ISA tags, stream
numbering, lane layouts, NN notation) and the pdlib calls that implement them.
`examples/` has a complete, tested script for each type. Start from the
closest one instead of a blank file.

### 3. Plan the layout on a grid before coding
Decide columns and rows as vectors (`cx = [2.2 6.4 10.6]`, `row = 9 - (0:5)*1.4`)
and place every node by its centre. Size nodes to their text with
`'W','auto'` or `pd_textwidth(label, fontSize)`.

Spacing that reads well at print size:
- 0.4–0.6 cm between node edges
- at least 0.5 cm of visible line for every arrow
- 0.3 cm group padding

Flow runs left→right or top→bottom. Main path first, side branches to one
side, feedback loops on the outside. While designing, `pd_figure(..., 'Grid',true)`
draws a labelled 1 cm grid (it is removed automatically on export).

### 4. Write the script
Use this skeleton so every script is readable and re-runnable:

```matlab
S = pd_style('elsevier');
[fig, ax] = pd_figure('double', 9, S);       % width preset or cm, height cm
% --- nodes / equipment (store handles in named variables) ---
a = pd_node(3, 7, {'Two-line','label'}, 'Role','process');
e = pd_equipment('cyclone', 9, 6, 'Scale',0.7, 'Label','Hydrocyclone');
% --- connections (by side or named port) ---
pd_connect(a, e, 'To','feed', 'Type','pipe');
% --- groups LAST (they auto-send themselves to the back) ---
pd_group({a, e}, 'Title','Classification');
% --- finish ---
pd_trim(fig);                 % remove empty margins (keeps width)
pd_check(fig);                % automated QA report
pd_export(fig, 'fig_name', 'Formats', {'pdf','png'});
```

`references/api.md` documents every function and option. The most useful
patterns are these:

- **Named ports** keep process diagrams correct: `pd_connect(cyc, mill, 'From','underflow', 'To','feed')`.
- **Routing.** `'Route'` can be `'hv'`, `'vh'`, `'hvh'` or `'vhv'`, with
  `'MidAbs'` to fix the middle leg. Use `'Via'` waypoints to go *around*
  equipment. Auto-routing only knows the two end points, so any line that
  would cross a symbol needs `Via`. Label long vertical legs with
  `'LabelRotation',90`.
- **Fan-in from many sources.** Draw one wide "bus" node and connect each
  source straight down with `'ToOffset'`. Don't fan several lines into one
  small box.
- **Semantic roles, not ad-hoc colours.** Choose from `process`, `model`,
  `optim`, `data`, `io`, `decision`, `output`, `neutral`. Give the same concept
  the same role in every figure of the paper.
- **Math.** `'tex'` (the default) handles `x_{k}`, `R^2`, `\alpha`,
  `\leq` and `\rightarrow`. For bold symbols write `\bf{x}\rm`: `\bf`
  switches bold on until `\rm` resets it. `'tex'` does **not** handle `\hat`, `\frac`,
  `\mathbf` or `\dot`. For those, pass `'Interpreter','latex'` with
  `$...$` text (MATLAB only; Octave previews show them raw).

### 5. Render, inspect, fix — repeat until clean
Always render and look at the result yourself before delivering:

```bash
bash <skill>/scripts/render_octave.sh my_figure.m     # headless Octave; installs it if missing
```

Then open the PNG with the image viewer and read `pd_check`'s report.
`pd_check` catches:
- fonts below the journal minimum
- text clipped at the canvas edge
- overlapping labels
- connectors or group frames crossing text
- hairlines thinner than 0.3 pt
- more than 6 hues

It does **not** catch text colliding with symbols (only lines and frames),
arrows that pass through equipment, misleading flow direction, or plain
ugliness. Only looking at the image finds those.

Fix and re-render until `pd_check` prints `OK` **and** the image looks
right. Two or three iterations is normal.

Octave-only artefacts to ignore in previews: uneven letter spacing ("Loaddata")
and uneven multi-line leading. These are Octave's font rasteriser; MATLAB
output is correctly kerned. Judge layout and collisions, not kerning.

### 6. Deliver
Give the user:
1. the `.m` script (self-contained, commented by section)
2. the exported PDF and PNG
3. one line on how to run it (`addpath` to pdlib)

Mention anything to verify against their journal's current author guide:
widths and minimum font sizes change. Keep the explanation short; the figure
speaks for itself.

## Design rules (and why)

- **No title inside the figure.** The caption goes in the manuscript. Panel
  letters `(a)`, `(b)` are bold, at the top-left.
- **Minimum 7 pt text (6 pt absolute) at final size.** Reviewers and
  production editors reject smaller. Keep node text uniform across the
  figure: one size for nodes, one smaller size for edge labels.
- **Colour encodes meaning, never decoration.** At most about 6 hues. The
  Okabe-Ito palette stays distinguishable for colour-blind readers. Line
  *styles* (solid pipe / dashed signal / dotted optional) must carry the
  meaning on their own, so the figure survives grayscale.
- **Orthogonal lines, few crossings, arrowheads only where direction matters.**
  Crossings and diagonals make readers work. A line that ends *inside* a
  symbol reads as a mistake.
- **Units and symbols match the manuscript.** Write `P_{80}`, `Q (m^3/h)` and
  the same variable names as the equations, so the figure and text read as
  one.
- **Vector output.** PDF/EPS/SVG keep text as text, and journals re-typeset
  or zoom it. Use raster (PNG/TIFF) only when explicitly requested, and then
  at 600 dpi or more for line art.

## Bundled files

- `scripts/pdlib/`: the library. Entry points: `pd_style`, `pd_figure`,
  `pd_node`, `pd_connect`, `pd_equipment`, `pd_group`, `pd_nn`, `pd_layers`,
  `pd_box3d`, `pd_icon`, `pd_legend`, `pd_tag`, `pd_text`, `pd_scalebar`,
  `pd_north`, `pd_trim`, `pd_check`, `pd_export`.
- `scripts/render_octave.sh`: headless render for previews and QA.
- `references/api.md`: every function, option and equipment port.
- `references/diagram-recipes.md`: conventions and recipes per diagram type.
  Read the relevant section in step 2.
- `references/journal-specs.md`: widths, fonts, formats and resolutions by
  publisher.
- `examples/`: `ex_flowchart.m`, `ex_process_pfd.m`, `ex_plant_layout.m`,
  `ex_architecture.m`, `ex_neural_network.m`, `ex_ml_optimization.m`. All
  are tested and pass `pd_check`.
