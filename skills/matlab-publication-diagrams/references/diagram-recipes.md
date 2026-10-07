# Diagram recipes

Conventions reviewers expect for each diagram type, and how to build them with pdlib.
Read only the section you need.

## Contents
1. Flowcharts and algorithm / methodology diagrams
2. Process flow diagrams (PFD) and P&ID-style schematics
3. Mineral-processing circuits (grinding, classification, leaching)
4. Plant layouts (plan view, to scale)
5. System / project / software architecture
6. Machine-learning and neural-network diagrams
7. Multi-panel figures
8. Troubleshooting layout problems

---

## 1. Flowcharts and algorithm / methodology diagrams

**Shape conventions (ISO 5807).** Use them consistently. Reviewers read
shapes before text.

| Meaning | `'Shape'` | Typical `'Role'` |
|---|---|---|
| Start / end | `terminal` | `''` (white) or `output` |
| Process step | `rounded` (default) or `process` | `process`, `model`, `optim` |
| Decision (yes/no) | `decision` | `decision` |
| Input / output data | `io` | `data` or `io` |
| Stored data, database | `database` | `data` |
| Document, report | `document` | `neutral` |
| Sub-routine / predefined process | `predefined` | any |
| Preparation / initialisation | `hexagon` | `neutral` |
| Many models (ensemble, k-fold) | `stack` | `model` |
| Annotation | `note` | `neutral` |

**Recipe**
- One main column; place rows with `row = top - (0:n-1)*1.3..1.5`.
- Decision branches: `pd_connect(dec, next, 'Label','Yes', 'LabelPos','start')`.
  Put *Yes* on the main path (down) and *No* to the side (`'From','E'`).
- Loops back to an earlier step: `'From','N','To','E'` from a side-branch
  node, or `'From','W','To','W'` with `'Detour'` for a loop on the left.
  `'Type','feedback'` (dashed) marks iterations.
- Keep labels to 1–3 short lines. Put pseudo-code detail in the paper's
  algorithm box, not in the flowchart.
- Iterative algorithms (GA, PSO, Bayesian optimisation, gradient descent):
  initialise → evaluate → select/update → converged? → loop back.
  Label the loop with the index update (`k \leftarrow k+1`).

Template: `examples/ex_flowchart.m`, `examples/ex_ml_optimization.m`.

## 2. Process flow diagrams (PFD) and P&ID-style schematics

**Conventions**
- Main flow runs left → right, and gravity flows go downward. Recycle streams
  return along the bottom or top of the drawing, never through equipment.
- **Line types** (define them in a legend with `pd_legend`):
  - process / slurry streams: `'Type','pipe'` (thick solid)
  - utility / reagent / water: `'Type','data'` (thin solid)
  - instrument / control signals: `'Type','signal'` (dashed)
  - optional or intermittent: `'Type','optional'` (dotted)
- **Stream numbers**: `pd_tag(x, y, '3')` (diamond) next to each numbered
  stream. Number them in flow order. They key the stream table in the paper.
- **Equipment labels**: a name ("Hydrocyclone") or tag ("CY-201") below the
  symbol. Use tag plus name only if the paper refers to tags.
- **Instruments (ISA-5.1)**: `pd_equipment('instrument', x, y, 'Tag',{'PIT','201'})`.
  - `'Variant'`: `'field'` (plain circle), `'panel'` (horizontal bar),
    `'dcs'` (circle in square), `'plc'` (diamond in square).
  - Connect the tapping point to the bubble with a `signal` line and no arrow.
  - Connect bubble to bubble (transmitter → controller → valve) with `signal`
    arrows.

| First letter (measured variable) | Succeeding letters (function) |
|---|---|
| F flow, P pressure, L level, D density, T temperature, W weight, S speed, A analysis (e.g. PSI particle size), J power | I indicate, T transmit, C control, R record, A alarm, V valve, E element, Y compute/relay |

Examples: FIT (flow indicating transmitter), DIT (density), PIC (pressure
indicating controller), LIC (level control), AIT (analyser such as PSI or
grade), JI (power).

**Routing around equipment.** Auto-routing only knows the end points. When a
line would pass through a symbol, give waypoints:

```matlab
fp = thk.ports.feed;   % ports are plain [x y] you can compute with
pd_connect(tank, thk, 'From','out', 'To','feed', 'Type','pipe', ...
           'Via', [11.0 yOut; 11.0 fp(2)+0.55; fp(1) fp(2)+0.55]);
```

**Aligning ports.** To get straight drops, compute positions from ports. For
example, place a conveyor so that its tail is under a bin outlet:
`xConv = bin.x + 0.95*scale`.

**Equipment catalogue and ports**: see `pd_equipment` in `api.md`. Symbols
scale (`'Scale'`), rotate (`'Rotate'`) and mirror (`'Flip'`). Use `'Flip',true`
for a cyclone fed from the right, and `'Rotate',-15` for an inclined conveyor.
After a transform the port directions update automatically. Use `'LabelDX'` /
`'LabelDY'` to move a label off a pipe that leaves the bottom port.

Template: `examples/ex_process_pfd.m`.

## 3. Mineral-processing circuits (grinding, classification, leaching)

Standard topology details that domain reviewers check:

- **Closed grinding circuit with hydrocyclones**
  - mill discharge → sump (pump box) → cyclone feed pump → cyclone feed
  - cyclone **underflow** (coarse) → returns to the mill feed; this is the
    circulating load
  - cyclone **overflow** (fine) → next stage (flotation, leaching/CIL,
    thickener)
  - water additions go to the sump and the mill feed (`'Type','data'`)
- **Draw the recirculation clearly.** Route it under the equipment row, back
  into the mill `feed` port. Label it "Circulating load" or "Underflow
  (recycle)", and give it a stream number.
- **Classification instrumentation** commonly shown:
  - cyclone feed pressure (PIT)
  - feed flow (FIT) and density (DIT)
  - overflow particle size (AIT, "PSI")
  - sump level (LIT)
  - pump speed (SIC / VFD)
  - mill power (JI)
  These are also the usual ML model inputs and outputs, so the PFD can
  double as the "where the data comes from" figure.
- **Direct vs. reverse closed circuit.** In a *direct* closed circuit the
  fresh feed enters the mill. In a *reverse* one it goes to the cyclones
  first. Make the entry point of the fresh feed unambiguous.
- **Cyclone cluster (battery).** Draw 2–3 cyclone symbols side by side, or one
  symbol labelled "Cyclone cluster (n = 8)", with a distributor node feeding
  them.
- **Leaching / CIL train.** `agitated_tank` symbols in cascade, each one
  slightly lower (gravity overflow), `out` → `in`. Reagent lines (NaCN, lime,
  O₂) enter the `reagent` port from above.

## 4. Plant layouts (plan view, to scale)

- Draw to scale with a conversion factor: `k = paperCm / siteMetres; m = @(v) v*k;`.
  Then use real dimensions in metres: `'W', m(40)`.
- Areas are `pd_node(..., 'Shape','process')` rectangles with a role per area
  type. Roads and racks are grey filled nodes with `'Edge','none'`.
- Round tanks and thickeners are `'Shape','circle'`.
- Always add `pd_scalebar(x, y, lengthCm, realLength, 'm')` and
  `pd_north(x, y)`.
- Put the site boundary as `pd_group([xmin ymin w h], 'LineStyle','-.', 'Role','none')`.
  Keep its title away from the scale bar.
- Draw conveyors and pipe racks between areas as `pipe` or `feedback`
  connectors. In a layout, arrows mean material flow, so say so in the
  caption.

Template: `examples/ex_plant_layout.m`.

## 5. System / project / software architecture

- **Lanes**: horizontal layers top → bottom, for example
  sources → data platform → models/services → consumers. Put each layer in a
  `pd_group` with a short bold title.
- **Bus pattern**: when many nodes feed one stage, make that stage one *wide*
  node spanning them and drop straight lines with
  `'ToOffset', (xs(i) - bus.x)/(bus.w/2)`. This avoids spaghetti fan-ins.
- **Shared trunks**: several targets from one source with the same `'From'`
  point and `'Route','vhv', 'MidAbs', yBetweenLanes`. The lines share a trunk
  and branch cleanly.
- **Link types**:
  - solid = data / calls
  - dashed `feedback` = control loop / actuation
  - dotted `optional` = monitoring, versioning, asynchronous
  - `'Arrow','both'` = bidirectional
- **Closed loops** that span the whole figure (model → plant → sensors):
  route them around the outside with `'Via'`, along the bottom and up a
  margin. Label the long vertical leg with
  `'LabelPos',0.5, 'LabelSide','left', 'LabelRotation',90` so the text runs
  along the line instead of sticking out into the figure.
- **Icons** (`pd_icon`: `database`, `server`, `cloud`, `sensor`, `user`,
  `gear`, `chart`, `nn`, `tree`, `forest`, `optim`, `loop`, `doc`) are visual
  anchors. Use one per concept at most, and never as the only carrier of
  meaning.
- **Group titles collide with incoming arrows.** Move the title
  (`'TitlePos','top-right'`) or widen the padding on the title side.

Template: `examples/ex_architecture.m`.

## 6. Machine-learning and neural-network diagrams

Choose the abstraction the paper needs.

| Need | Tool | Notes |
|---|---|---|
| Neuron-level MLP (small nets, surrogate models) | `pd_nn` | Truncates big layers with ⋮ and "(64)". Give `InputLabels` using the paper's variable symbols. |
| Layer-by-layer architecture (LSTM, Transformer, CNN head) | `pd_layers` | `'Direction','down'` for tall stacks, `'Rotated',true` for a left→right row of thin blocks. Skip/residual: `pd_connect(L(i), L(j), 'From','E','To','E','Type','feedback')`. |
| CNN tensors / feature maps / data cubes | `pd_box3d` | Width ∝ channels, height ∝ spatial size. Use `'Dims'` for H and C labels. |
| Tree ensembles (RF, GBM, XGBoost) | `pd_icon('tree' / 'forest')` next to a `'stack'` node | Show "n_{trees} = 500" in the label. Don't draw every split. |
| Training pipeline / MLOps | flowchart + architecture patterns | Data → preprocessing → split → train → validate → deploy. |
| Surrogate-based optimisation / MPC | two groups: *offline* (training) and *online* (loop) | Connect the trained model into the loop with a `data` arrow. |

Conventions:
- Colour by role:
  - input = `data`
  - hidden / learnable = `model`
  - normalisation / dropout / pooling = `neutral`
  - merge / add = `optim`
  - output / loss = `output`
- Activation functions and hyper-parameters go in the second label line
  (`{'Dense','64, ReLU'}`) or as a muted note. Don't add extra boxes for them.
- Match symbols to the equations: `\bf{x}\rm`, `y_{pred}`, `f(\bf{x}\rm)`,
  `g(\bf{x}\rm) \leq 0`.

Templates: `examples/ex_neural_network.m`, `examples/ex_ml_optimization.m`.

## 7. Multi-panel figures

Draw all panels on one `pd_figure` canvas; do not use subplots. Divide the
canvas by coordinates and add bold panel letters:

```matlab
pd_text(0.15, H - 0.15, '(a)', 'FontWeight','bold', 'HA','left', 'VA','top');
```

Keep the same style struct, font sizes and roles across panels. Leave at
least 0.5 cm between panels.

## 8. Troubleshooting layout problems

| Symptom | Fix |
|---|---|
| `pd_check`: overlapping text | Increase row/column spacing. Shorten labels. Move edge labels with `'LabelPos'` (fraction) or `'LabelSide'`. |
| Connector crosses text | Use `'Route'`, `'MidAbs'` or `'Via'` for the connector. Rotate labels on vertical legs (`'LabelRotation',90`). Or nudge the label (`'TextDX'`, `'LabelDX'`) or change `'LabelSide'`. |
| Group frame crosses text | Increase `'Pad'` (per side: `[l r b t]`). |
| Arrow enters a node at an odd spot | Set `'From'` / `'To'` sides explicitly. Use `'ToOffset'` to spread several arrows on one side. |
| Small jog in a "straight" line | End points differ by a few mm. Align centres (same x or same y), or compute coordinates from ports/anchors (`pd_anchor(n,'S')`). |
| Big empty margins | `pd_trim(fig)` (keeps width) before `pd_check` / `pd_export`. |
| Text too small after placing in the paper | You changed the canvas size after designing. Keep `pd_figure` at the final column width and never rescale in LaTeX/Word (`\includegraphics` without `width=`, or exactly `\linewidth` / `\columnwidth` matching the preset). |
| Gradient or odd colours in a fill | Always pass colours through pdlib functions (they use explicit `FaceColor`); avoid raw `patch(x,y,rgb)` in your own additions. |
