# pdlib API reference

Auto-generated from the help text of each function (`help pd_xxx` shows the same).
All lengths in cm, font sizes and line widths in pt. Options are case-insensitive name-value pairs;
unknown option names raise an error listing the valid ones.

## Contents
- Canvas & style: `pd_style`, `pd_figure`, `pd_trim`
- Flowchart / architecture primitives: `pd_node`, `pd_shape`, `pd_anchor`, `pd_connect`, `pd_group`, `pd_text`, `pd_tag`, `pd_legend`, `pd_textwidth`
- Process equipment: `pd_equipment`
- Machine learning: `pd_nn`, `pd_layers`, `pd_box3d`, `pd_icon`
- Plant layout: `pd_scalebar`, `pd_north`
- Quality & export: `pd_check`, `pd_export`
- Internals (rarely needed): `pd_setup`, `pd_rolecolor`, `pd_toback`, `pd_patch`, `pd_opts`, `pd_getstyle`, `pd_mknode`, `pd_hempty`, `pd_isoctave`

## Canvas & style

### `pd_style`
```text
S = pd_style(preset, varargin)
PD_STYLE Publication style: fonts, line weights, sizes and color roles.
   S = pd_style()                 generic journal style (8 pt Helvetica)
   S = pd_style('ieee')           IEEE Transactions / Access
   S = pd_style('elsevier')       Elsevier (Minerals Eng., Powder Tech., ...)
   S = pd_style('springer')       Springer / Nature-family single column
   S = pd_style('acs')            ACS journals
   S = pd_style('mdpi')           MDPI (Minerals, Processes, ...)
   S = pd_style('thesis')         A4 thesis / report
   S = pd_style('slides')         presentations & posters (larger text)
   S = pd_style(preset, 'Palette','gray', 'Font','Arial', 'FontSize',9)

   All lengths are in centimetres, font sizes and line widths in points.
   Because pd_figure maps 1 data unit = 1 cm, what you set here is what
   is printed at 100 % in the journal.

   Column widths are typical values -- ALWAYS confirm with the target
   journal's current "Guide for Authors" before final submission.
```

### `pd_figure`
```text
[fig, ax] = pd_figure(w, h, S, varargin)
PD_FIGURE Create a diagram canvas where 1 data unit = 1 cm on paper.
   [fig, ax] = pd_figure(w, h)          w x h cm, default style
   [fig, ax] = pd_figure(w, h, S)       with a pd_style struct
   w may also be 'single' | 'mid' | 'double' (uses the style's widths).

   Options:
     'Visible'  'on'|'off'  (use 'off' for batch/headless export)
     'Grid'     true -> draws a 1 cm layout grid with coordinates. Use it
                while designing, then set false for the final export.

   Coordinates: origin (0,0) is bottom-left, x to the right, y upward,
   everything in cm. Place nodes by their CENTRE.
```

### `pd_trim`
```text
sz = pd_trim(fig, varargin)
PD_TRIM Shrink the canvas to the drawn content plus a margin.
   pd_trim(fig)                     trim height only (width = journal column)
   pd_trim(fig, 'Axis','both')      trim width too (e.g. for a sub-panel)
   pd_trim(fig, 'Margin', 0.2)      margin in cm (0.15)
   Call it right before pd_check / pd_export. Nothing is moved: the axis
   limits are changed, so all coordinates you used remain valid.
```

## Flowchart / architecture primitives

### `pd_node`
```text
N = pd_node(x, y, label, varargin)
PD_NODE Draw a labelled node centred at (x, y) [cm].
   N = pd_node(x, y, 'Text')
   N = pd_node(x, y, {'Line 1', 'Line 2'}, 'Shape','decision', 'Role','optim')

   Options (defaults from the active pd_style):
     'Shape'      see pd_shape: process | rounded | terminal | decision |
                  io | database | document | predefined | hexagon |
                  ellipse | circle | note | stack
     'W','H'      size in cm ('W','auto' fits the label)
     'Role'       semantic colour: process | model | optim | decision |
                  data | io | output | highlight | neutral | none |
                  palette index | RGB fill
     'Fill','Edge'  explicit colours (override Role)
     'LineWidth','LineStyle'
     'FontSize','FontWeight','FontAngle','TextColor','Interpreter'
     'Rotation'   text rotation in degrees (e.g. 90 for tall thin blocks)
     'Radius'     corner radius for 'rounded'
     'TextDX','TextDY'  nudge the label (cm)

   Returns a node struct usable by pd_connect, pd_group and pd_anchor.
```

### `pd_shape`
```text
[px, py, extra] = pd_shape(shape, x, y, w, h, r)
PD_SHAPE Outline polygon (column vectors) for a node shape.
   extra: cell of {xline, yline} decorations drawn as lines on top
   (e.g. the inner lip of a database cylinder).

   Shapes (ISO 5807 flowchart names in brackets):
     'process' [process]      'rounded'            'terminal' [terminator]
     'decision' [decision]    'io' [data]          'database' [stored data]
     'document' [document]    'predefined' [predefined process]
     'hexagon' [preparation]  'ellipse' | 'circle' 'note' (folded corner)
     'stack' (drawn by pd_node as 3 offset rounded boxes)
```

### `pd_anchor`
```text
[p, dir] = pd_anchor(N, spec, offset)
PD_ANCHOR Point on a node's boundary (and the direction a line leaves it).
   p = pd_anchor(N, 'E')          east side midpoint
   p = pd_anchor(N, 'N', 0.5)     north side, shifted +50 % of half-width
   p = pd_anchor(N, 'overflow')   named port of an equipment symbol
   p = pd_anchor([x y])           a bare point passes through

   spec: 'N','S','E','W','NE','NW','SE','SW','C' or a port name.
   offset (-1..1) slides the point along N/S (in x) or E/W (in y) sides,
   which lets several arrows enter the same side without overlapping.
   dir: 'N','S','E','W' (exit direction) or '' when undefined.
```

### `pd_connect`
```text
C = pd_connect(A, B, varargin)
PD_CONNECT Arrow/line between two nodes, ports or points.
   pd_connect(n1, n2)                         auto sides, auto route
   pd_connect(n1, n2, 'From','S', 'To','N')
   pd_connect(dec, n3, 'From','E', 'Label','Yes', 'LabelPos','start')
   pd_connect(cyc, tank, 'From','underflow', 'To','in', 'Type','pipe')
   pd_connect(n4, n1, 'From','W','To','W')    feedback loop (auto detour)
   pd_connect([1 2], [5 2])                   bare points

   Options
     'From','To'      side ('N','S','E','W','NE',...), port name, or 'auto'
     'FromOffset','ToOffset'  slide along the side (-1..1)
     'Route'   'auto'|'straight'|'hv'|'vh'|'hvh'|'vhv'
     'Mid'     fraction (0..1) for the middle leg of hvh/vhv   (0.5)
     'MidAbs'  absolute x (hvh) or y (vhv) of the middle leg  ([])
     'Detour'  clearance (cm) for same-side / backward loops   (0.5)
     'Via'     Nx2 waypoints -> polyline p1-Via-p2 (full manual control)
     'Type'    'flow' (default) | 'pipe' (thick process stream) |
               'signal' (dashed, thin: instrument/control) |
               'data' (solid thin) | 'optional' (dotted) | 'feedback'
     'Arrow'   'end'|'start'|'both'|'none'|'mid'
     'Label'   text; 'LabelPos' 'start'|'mid'|'end'|fraction of length
     'LabelSide' 'auto'|'above'|'below'|'left'|'right'|'on'
     'LabelOffset' cm; 'FontSize'; 'Interpreter'
     'LabelRotation' 0 | 90: 90 runs the label ALONG a vertical leg
                  (use for long vertical loops at the figure margin)
     'Color','LineWidth','LineStyle','ArrowSize' (scale factor)
   Returns struct with .points (polyline) and .handles.
```

### `pd_group`
```text
G = pd_group(target, varargin)
PD_GROUP Frame around nodes (subsystem, module, plant area, layer...).
   G = pd_group([n1 n2 n3], 'Title','Data layer')
   G = pd_group({n1, eq1}, 'Title','Grinding', 'Role','process')
   G = pd_group([xmin ymin w h], 'Title','Area 200')      explicit box

   Options
     'Title'      text; 'TitlePos' 'top-left'|'top'|'top-right'|
                  'bottom-left'|'bottom'|'outside-top-left'
     'Pad'        padding around nodes (cm), scalar or [l r b t]
     'Role'       fill tint from palette ('' = light grey, 'none' = no fill)
     'Fill','Edge','LineStyle' ('--' default),'LineWidth','Radius'
     'FontWeight' ('bold'), 'FontSize'
     'TitleSpace' extra top padding reserved for the title (cm, auto)
   The frame is sent behind everything already drawn, so call it AFTER
   the nodes it contains. Returns a node struct: you can connect to it.
```

### `pd_text`
```text
ht = pd_text(x, y, str, varargin)
PD_TEXT Free text with the diagram's typography.
   pd_text(x, y, 'Annotation')
   pd_text(x, y, '(a)', 'FontWeight','bold', 'HA','left', 'VA','top')
   pd_text(x, y, '$\dot{m}_{\mathrm{feed}}$', 'Interpreter','latex')
   Options: 'FontSize','FontWeight','FontAngle','Color','HA','VA',
            'Rotation','Interpreter','Background'
```

### `pd_tag`
```text
N = pd_tag(x, y, str, varargin)
PD_TAG Small labelled marker: PFD stream numbers, step numbers, callouts.
   pd_tag(x, y, '3')                       stream number (diamond)
   pd_tag(x, y, 'A', 'Shape','circle', 'Role','highlight')
   Shapes: 'diamond' (PFD streams) | 'circle' (steps) | 'rect' | 'flag'
```

### `pd_legend`
```text
G = pd_legend(x, y, items, varargin)
PD_LEGEND Diagram legend for line types and colour roles.
   pd_legend(x, y, items)  (x,y) = top-left corner of the legend, cm
   items: cell array, one row per entry:
     {'line',  'Slurry stream', 'Type','pipe'}      any pd_connect Type
     {'arrow', 'Information flow'}
     {'patch', 'ML model', 'Role','model'}          role-coloured swatch
     {'patch', 'Measured', 'Fill',[1 1 1], 'Edge',[0 0 0]}
   Options: 'Columns' (1), 'ColWidth' (cm, auto), 'RowH' (0.42),
            'Box' (true), 'Title' (''), 'FontSize'
```

### `pd_textwidth`
```text
w = pd_textwidth(str, fontSize)
PD_TEXTWIDTH Estimated width (cm) of a label's longest line.
   Uses 0.52 em per character (Helvetica/Arial average), ignoring TeX
   markup such as _{...}, ^{...} and \alpha. Good enough for layout
   planning; pd_check measures the real extents after drawing.
```

## Process equipment

### `pd_equipment`
```text
N = pd_equipment(type, x, y, varargin)
PD_EQUIPMENT Process-equipment symbol (PFD / P&ID style) with named ports.
   E = pd_equipment('cyclone', x, y, 'Label','Hydrocyclone', 'Scale',0.7)
   pd_connect(E, E2, 'From','overflow', 'To','in', 'Type','pipe')

   (x, y) is the symbol's reference centre in cm. At Scale 1 most symbols
   are 1-3 cm; use 'Scale' to fit the layout.

   Types and their named ports  (port exit direction at Rotate = 0)
     'cyclone'        feed(W) overflow(N) underflow(S)
     'tank'           closed vessel: in(W) out(E) top(N) bottom(S)
     'agitated_tank'  leach/CIL/conditioning: in(W) out(E) feed(N, left rim)
                      reagent(N, right rim) top(N, motor) bottom(S)
     'sump'           pump box: in(N) in2(W) out(E) bottom(S)
     'pump'           centrifugal: suction(W) discharge(E)
     'mill'           ball/SAG/rod mill: feed(W) discharge(E)
                      'Variant': 'ball' (default) | 'sag' | 'rod'
     'valve'          in(W) out(E)
     'control_valve'  in(W) out(E) actuator(N)
     'instrument'     ISA bubble; 'Tag',{'PIT','101'}; ports N,S,E,W
                      'Variant': 'field' | 'panel' | 'dcs' | 'plc'
     'thickener'      feed(N) overflow(E) underflow(S)
     'screen'         vibrating screen: feed(W) oversize(E) undersize(S)
     'conveyor'       in(N) out(E)
     'bin'            hopper / feed bin: in(N) out(S)
     'stockpile'      in(N) out(S)
     'column'         flotation/leach/adsorption column:
                      in(W) out(E) top(N) bottom(S)
     'motor'          ports N,S,E,W
     'heat_exchanger' in(W) out(E) shell_in(N) shell_out(S)
   Every symbol also answers to 'N','S','E','W','C' (bounding box).

   Options
     'Scale'    size factor (1)          'Rotate'  degrees CCW (0)
     'Flip'     mirror left-right (false) e.g. cyclone fed from the right
     'Label'    text; 'LabelPos' 'below'|'above'|'left'|'right'|'none'
     'LabelDX','LabelDY'  nudge the label (cm) off pipes that leave the port
     'Role'     palette role for the fill ('' = white)
     'Fill','Edge','LineWidth','FontSize'
     'Tag'      instrument tag (char or 2-cell {'FIC','201'})
     'Variant'  see above
```

## Machine learning

### `pd_nn`
```text
NN = pd_nn(x0, y0, sizes, varargin)
PD_NN Fully-connected neural network (neurons + weights) diagram.
   NN = pd_nn(x0, y0, [5 16 16 1])
   NN = pd_nn(2, 4, [4 32 32 2], 'MaxShow', 6, ...
        'LayerLabels', {'Input','Hidden 1','Hidden 2','Output'}, ...
        'InputLabels', {'Q','P','\rho_s','d_a'}, 'OutputLabels', {'P_{80}','R_f'})

   (x0, y0): centre of the FIRST layer (x) and vertical centre (y), cm.
   Layers larger than MaxShow are truncated with a vertical ellipsis and
   (if 'Counts' is true) annotated with their true size, e.g. "(32)".

   Options
     'DX' layer spacing (1.6)       'DY' neuron spacing (0.55)
     'R'  neuron radius (0.15)      'MaxShow' neurons drawn per layer (7)
     'LayerLabels'  cell, one per layer (drawn below)
     'LayerRoles'   cell of roles, e.g. {'data','model','model','output'}
     'InputLabels','OutputLabels'  cell of per-neuron labels
     'Counts'       true -> "(n)" under truncated layers
     'EdgeColor'    ([0.7 0.7 0.7]) 'EdgeWidth' (0.35 pt)
     'Bias'         true -> bias unit "+1" above each non-output layer
   Returns node struct (bounding box) with extra field .centers{l} (Nx2).
```

### `pd_layers`
```text
Ns = pd_layers(x0, y0, spec, varargin)
PD_LAYERS Block diagram of a model architecture (layer by layer).
   Ns = pd_layers(x0, y0, spec)          (x0,y0) = centre of first block
   spec: N x 2 cell {label, type}; label can be a cell for 2 lines.
     spec = {'Input (12)',          'input'
             {'Dense 64','ReLU'},   'dense'
             'Dropout 0.2',         'dropout'
             {'LSTM','128 units'},  'rnn'
             'Output (2)',          'output'};
   Types -> colour role: input/embed (data), dense/conv/rnn/lstm/gru/
   attention/transformer (model), pool/norm/dropout/activation (neutral),
   concat/add (optim), output/loss (output), anything else: process.

   Options
     'Direction' 'right' | 'down' | 'up' | 'left'   ('right')
     'W','H'     block size (default 1.6 x 1.0 for right, 3.0 x 0.6 for down)
     'Gap'       space between blocks (0.45)
     'Rotated'   true -> tall thin blocks with vertical text (Direction right)
     'Arrows'    true
   Returns a struct array of nodes (one per block) for further wiring,
   e.g. skip connections: pd_connect(Ns(2), Ns(4), 'From','N','To','N').
```

### `pd_box3d`
```text
N = pd_box3d(x, y, w, h, d, varargin)
PD_BOX3D Oblique cuboid: tensors, CNN feature maps, data cubes.
   N = pd_box3d(x, y, w, h, d)  front face centred at (x,y), w x h cm,
                                depth d cm drawn at 'Angle' degrees.
   N = pd_box3d(3, 2, 0.3, 2.4, 2.0, 'Role','model', 'Label','Conv 3x3, 32', ...
                'Dims', {'64','64','32'})
   Options: 'Role','Fill','Edge','Angle' (40),'DepthScale' (0.5),
            'Label' (below), 'Dims' {h, w, c} labels on the edges,
            'FontSize','LineWidth'
```

### `pd_icon`
```text
N = pd_icon(type, x, y, varargin)
PD_ICON Small vector icon for architecture / pipeline diagrams.
   pd_icon('tree', x, y)                 decision tree (RF / GBM / XGBoost)
   pd_icon('nn', x, y, 'Size', 1.0, 'Role','model')
   Types: 'tree' | 'forest' | 'nn' | 'gear' | 'chart' | 'database' |
          'server' | 'cloud' | 'sensor' | 'user' | 'doc' | 'optim' | 'loop'
   Options: 'Size' (box side, cm, 0.8), 'Role' ('' = dark ink),
            'Label' (below), 'FontSize', 'LineWidth'
   Icons are pure vector geometry (no fonts, no bitmaps) so they export
   cleanly to PDF/EPS and scale without artefacts.
```

## Plant layout

### `pd_scalebar`
```text
N = pd_scalebar(x, y, lenCm, realLen, units, varargin)
PD_SCALEBAR Alternating scale bar for plant layouts / plan views.
   pd_scalebar(1, 0.8, 3, 30, 'm')   3 cm on paper represents 30 m
   Options: 'Segments' (4), 'Height' (0.12), 'FontSize'
```

### `pd_north`
```text
N = pd_north(x, y, varargin)
PD_NORTH North arrow for plant layouts. Options: 'Size' (0.8 cm), 'Angle' (0)
```

## Quality & export

### `pd_check`
```text
R = pd_check(fig, varargin)
PD_CHECK Pre-submission lint for a pd figure. Prints a report.
   R = pd_check(fig)
   R = pd_check(fig, 'Target','single')   also checks the width target

   Checks
     - font sizes below style minimum (journals reject < 6-7 pt)
     - text running outside the canvas (would be clipped on export)
     - overlapping text labels (the #1 defect in generated diagrams)
     - hairlines thinner than 0.3 pt (~0.1 mm; vanish in print), NN edges excepted
     - more than 6 distinct hues (visual noise; greys/shades not counted)
     - figure width vs the style's single / 1.5 / double column widths
   Returns struct with fields .errors, .warnings, .info (cellstr).
```

### `pd_export`
```text
files = pd_export(fig, basename, varargin)
PD_EXPORT Export a pd figure at its exact physical size.
   pd_export(fig, 'fig_process')                    -> PDF + PNG (600 dpi)
   pd_export(fig, 'out/fig3', 'Formats', {'pdf','eps','svg','tif','png'})
   pd_export(fig, 'fig3', 'Method','exportgraphics')  tight crop (MATLAB)

   Options
     'Formats'     cell: 'pdf','eps','svg','png','tif','emf'  ({'pdf','png'})
     'Resolution'  dpi for raster formats (600). Line art: 600-1200.
     'Method'      'print' (default: page = figure size, exact cm) |
                   'exportgraphics' (MATLAB R2020a+, crops to content)
     'RemoveGrid'  delete the pd_figure layout grid before export (true)

   Vector formats (PDF/EPS/SVG) are what journals want for line art:
   text stays text, fonts are embedded, zoom is lossless. Use PNG/TIFF
   only when a raster is explicitly requested (e.g. some MDPI/Word flows).
```

## Internals (rarely needed)

### `pd_setup`
```text
pd_setup()
PD_SETUP Add the pdlib folder to the path (call once per session).
   run('path/to/pdlib/pd_setup.m')  or  addpath('path/to/pdlib')
```

### `pd_rolecolor`
```text
[fill, edge] = pd_rolecolor(S, role)
PD_ROLECOLOR Fill (light tint) and edge (full colour) for a role.
   role: '' (white node, dark edge) | role name ('model','data',...) |
         palette index 1..8 | RGB triplet (used as fill; edge darkened).
```

### `pd_toback`
```text
pd_toback(ax, hs)
PD_TOBACK Send graphics objects behind everything else in the axes.
```

### `pd_patch`
```text
h = pd_patch(X, Y, fc, varargin)
PD_PATCH patch() with an explicit FaceColor.
   patch(X, Y, [r g b]) is ambiguous: for 3-vertex polygons (arrowheads,
   triangles) MATLAB/Octave may read the triplet as per-vertex colour
   data and interpolate, producing gradients. Always pass FaceColor.
```

### `pd_opts`
```text
o = pd_opts(o, varargin)
PD_OPTS Merge name-value pairs into a struct of defaults (case-insensitive).
   o = pd_opts(defaults, 'Name', value, ...)
   Unknown names raise an error listing the valid options, so typos are
   caught immediately instead of being silently ignored.
```

### `pd_getstyle`
```text
S = pd_getstyle(ax)
PD_GETSTYLE Return the style struct attached to the current pd figure.
```

### `pd_mknode`
```text
N = pd_mknode(kind, shape, x, y, w, h, handles, label, ports, portdir)
PD_MKNODE Internal constructor. Every drawable returns this same struct,
   so nodes, equipment, groups, icons and NN blocks can be concatenated
   ([n1 n2 n3]) and passed to pd_connect / pd_group interchangeably.
```

### `pd_hempty`
```text
h = pd_hempty()
PD_HEMPTY Empty graphics-handle array (gobjects in MATLAB, [] in Octave).
```

### `pd_isoctave`
```text
tf = pd_isoctave()
PD_ISOCTAVE True when running under GNU Octave.
```
