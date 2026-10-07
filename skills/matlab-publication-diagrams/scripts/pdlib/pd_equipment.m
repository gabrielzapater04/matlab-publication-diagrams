function N = pd_equipment(type, x, y, varargin)
%PD_EQUIPMENT Process-equipment symbol (PFD / P&ID style) with named ports.
%   E = pd_equipment('cyclone', x, y, 'Label','Hydrocyclone', 'Scale',0.7)
%   pd_connect(E, E2, 'From','overflow', 'To','in', 'Type','pipe')
%
%   (x, y) is the symbol's reference centre in cm. At Scale 1 most symbols
%   are 1-3 cm; use 'Scale' to fit the layout.
%
%   Types and their named ports  (port exit direction at Rotate = 0)
%     'cyclone'        feed(W) overflow(N) underflow(S)
%     'tank'           closed vessel: in(W) out(E) top(N) bottom(S)
%     'agitated_tank'  leach/CIL/conditioning: in(W) out(E) feed(N, left rim)
%                      reagent(N, right rim) top(N, motor) bottom(S)
%     'sump'           pump box: in(N) in2(W) out(E) bottom(S)
%     'pump'           centrifugal: suction(W) discharge(E)
%     'mill'           ball/SAG/rod mill: feed(W) discharge(E)
%                      'Variant': 'ball' (default) | 'sag' | 'rod'
%     'valve'          in(W) out(E)
%     'control_valve'  in(W) out(E) actuator(N)
%     'instrument'     ISA bubble; 'Tag',{'PIT','101'}; ports N,S,E,W
%                      'Variant': 'field' | 'panel' | 'dcs' | 'plc'
%     'thickener'      feed(N) overflow(E) underflow(S)
%     'screen'         vibrating screen: feed(W) oversize(E) undersize(S)
%     'conveyor'       in(N) out(E)
%     'bin'            hopper / feed bin: in(N) out(S)
%     'stockpile'      in(N) out(S)
%     'column'         flotation/leach/adsorption column:
%                      in(W) out(E) top(N) bottom(S)
%     'motor'          ports N,S,E,W
%     'heat_exchanger' in(W) out(E) shell_in(N) shell_out(S)
%   Every symbol also answers to 'N','S','E','W','C' (bounding box).
%
%   Options
%     'Scale'    size factor (1)          'Rotate'  degrees CCW (0)
%     'Flip'     mirror left-right (false) e.g. cyclone fed from the right
%     'Label'    text; 'LabelPos' 'below'|'above'|'left'|'right'|'none'
%     'LabelDX','LabelDY'  nudge the label (cm) off pipes that leave the port
%     'Role'     palette role for the fill ('' = white)
%     'Fill','Edge','LineWidth','FontSize'
%     'Tag'      instrument tag (char or 2-cell {'FIC','201'})
%     'Variant'  see above
S = pd_getstyle();
o = pd_opts(struct('Scale', 1, 'Rotate', 0, 'Flip', false, 'Label', '', ...
    'LabelPos', 'below', 'LabelDX', 0, 'LabelDY', 0, 'Role', '', 'Fill', [], 'Edge', [], ...
    'LineWidth', S.lineWidth, 'FontSize', S.fontSizeSmall, 'Tag', '', ...
    'Variant', '', 'Parent', gca), varargin{:});
ax = o.Parent;
[fill, edge] = pd_rolecolor(S, o.Role);
if ~isempty(o.Fill), fill = o.Fill; end
if ~isempty(o.Edge), edge = o.Edge; end

[P, ports, pdir, nodeShape] = local_geometry(lower(type), o);

% ---- transform: flip -> rotate -> scale -> translate --------------------
fx = 1; if o.Flip, fx = -1; end
th = o.Rotate*pi/180; Rm = [cos(th) -sin(th); sin(th) cos(th)];
tf = @(X, Y) local_tf(X, Y, fx, Rm, o.Scale, x, y);

h = pd_hempty();
allX = []; allY = [];
for k = 1:numel(P)
    p = P(k);
    [X, Y] = tf(p.X, p.Y);
    lw = o.LineWidth * p.lwf;
    switch p.t
        case 'poly'
            switch p.mode
                case 'fill', fc = fill;
                case 'dark', fc = edge;
                case 'mask', fc = fill;
                otherwise,   fc = 'none';
            end
            ec = edge; if strcmp(p.mode, 'mask'), ec = 'none'; end
            if ischar(fc)
                h(end+1) = pd_patch(X, Y, [1 1 1], 'FaceColor', 'none', 'EdgeColor', ec, ...
                    'LineWidth', lw, 'LineStyle', p.ls, 'Parent', ax); %#ok<AGROW>
            else
                h(end+1) = pd_patch(X, Y, fc, 'EdgeColor', ec, 'LineWidth', lw, ...
                    'LineStyle', p.ls, 'Parent', ax); %#ok<AGROW>
            end
        case 'line'
            h(end+1) = line(X, Y, 'Color', edge, 'LineWidth', lw, ...
                'LineStyle', p.ls, 'Parent', ax); %#ok<AGROW>
    end
    allX = [allX; X(:)]; allY = [allY; Y(:)]; %#ok<AGROW>
end

% ---- ports ---------------------------------------------------------------
pn = fieldnames(ports);
for k = 1:numel(pn)
    q = ports.(pn{k});
    [qx, qy] = tf(q(1), q(2));
    ports.(pn{k}) = [qx qy];
    pdir.(pn{k}) = local_rotdir(pdir.(pn{k}), fx, Rm);
end

% ---- bounding box / node --------------------------------------------------
L = min(allX); R = max(allX); B = min(allY); T = max(allY);
if strcmp(nodeShape, 'circle')
    cx = x; cy = y; bw = R - L; bh = T - B;
else
    cx = (L+R)/2; cy = (B+T)/2; bw = R - L; bh = T - B;
end

% ---- instrument tag text (always upright) ---------------------------------
if strcmpi(type, 'instrument') && ~isempty(o.Tag)
    tg = o.Tag; if ischar(tg), tg = {tg}; end
    if numel(tg) == 2, fs = 6*o.Scale; else, fs = 7*o.Scale; end
    fs = max(S.minFontSize, fs);   % bubble is 6 mm at Scale 1
    h(end+1) = text(x, y, tg, 'Parent', ax, 'FontName', S.font, 'FontSize', fs, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'Color', S.textColor, 'Interpreter', 'none', 'Tag', 'pd_nodetext');
end
if strcmpi(type, 'motor')
    h(end+1) = text(x, y, 'M', 'Parent', ax, 'FontName', S.font, ...
        'FontSize', max(S.minFontSize, 8*o.Scale), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'Color', S.textColor, 'Tag', 'pd_nodetext');
end

% ---- label ----------------------------------------------------------------
if ~isempty(o.Label) && ~strcmpi(o.LabelPos, 'none')
    g = 0.12;
    switch lower(o.LabelPos)
        case 'below', xy = [cx, B - g]; ha = 'center'; va = 'top';
        case 'above', xy = [cx, T + g]; ha = 'center'; va = 'bottom';
        case 'left',  xy = [L - g, cy]; ha = 'right';  va = 'middle';
        case 'right', xy = [R + g, cy]; ha = 'left';   va = 'middle';
        otherwise, error('pd:equipment', 'Unknown LabelPos "%s".', o.LabelPos);
    end
    h(end+1) = text(xy(1) + o.LabelDX, xy(2) + o.LabelDY, o.Label, 'Parent', ax, ...
        'FontName', S.font, 'FontSize', o.FontSize, 'Color', S.textColor, ...
        'Interpreter', S.interpreter, 'HorizontalAlignment', ha, ...
        'VerticalAlignment', va, 'Tag', 'pd_eqlabel');
end
N = pd_mknode('equipment', nodeShape, cx, cy, bw, bh, h, o.Label, ports, pdir);
end

% ==========================================================================
function [X, Y] = local_tf(X, Y, fx, Rm, s, x0, y0)
U = [fx*X(:)'; Y(:)'];
V = Rm * U * s;
X = V(1, :)' + x0; Y = V(2, :)' + y0;
end

function d = local_rotdir(d, fx, Rm)
switch d
    case 'E', v = [1; 0]; case 'W', v = [-1; 0];
    case 'N', v = [0; 1]; case 'S', v = [0; -1];
    otherwise, return;
end
v(1) = fx*v(1); v = Rm*v;
if abs(v(1)) >= abs(v(2))
    if v(1) > 0, d = 'E'; else, d = 'W'; end
else
    if v(2) > 0, d = 'N'; else, d = 'S'; end
end
end

function p = pr(t, X, Y, mode, ls, lwf)
if nargin < 4 || isempty(mode), mode = 'fill'; end
if nargin < 5 || isempty(ls), ls = '-'; end
if nargin < 6 || isempty(lwf), lwf = 1; end
p = struct('t', t, 'X', X(:), 'Y', Y(:), 'mode', mode, 'ls', ls, 'lwf', lwf);
end

function [X, Y] = circ(cx, cy, r, a0, a1, n)
if nargin < 4, a0 = 0; a1 = 2*pi; end
if nargin < 6, n = 72; end
t = linspace(a0, a1, n)';
X = cx + r*cos(t); Y = cy + r*sin(t);
end

function [X, Y] = rect(L, B, R, T)
X = [L R R L]'; Y = [B B T T]';
end

function [P, ports, pdir, shp] = local_geometry(type, o)
P = struct('t', {}, 'X', {}, 'Y', {}, 'mode', {}, 'ls', {}, 'lwf', {});
ports = struct(); pdir = struct(); shp = 'box';
switch type
    case {'cyclone', 'hydrocyclone'}
        [X, Y] = rect(-0.85, 0.95, -0.45, 1.25);        P(end+1) = pr('poly', X, Y); % inlet
        P(end+1) = pr('poly', [-0.5 0.5 0.5 0.1 -0.1 -0.5], [1.3 1.3 0.6 -1.3 -1.3 0.6]);
        P(end+1) = pr('line', [-0.5 0.5], [0.6 0.6], '', '-', 0.6);
        [X, Y] = rect(-0.15, 1.3, 0.15, 1.75);          P(end+1) = pr('poly', X, Y); % vortex finder
        P(end+1) = pr('line', [-0.15 -0.15 0.15 0.15], [1.3 0.8 0.8 1.3], '', '--', 0.6);
        [X, Y] = rect(-0.1, -1.5, 0.1, -1.3);           P(end+1) = pr('poly', X, Y); % apex
        ports.feed = [-0.85 1.1];   pdir.feed = 'W';
        ports.overflow = [0 1.75];  pdir.overflow = 'N';
        ports.underflow = [0 -1.5]; pdir.underflow = 'S';
    case {'tank', 'vessel'}
        [xb, yb] = circ(0, -0.8, 0.6, pi, 2*pi, 30); yb = -0.8 + (yb + 0.8)*0.42;
        [xt, yt] = circ(0, 0.8, 0.6, 0, pi, 30);     yt = 0.8 + (yt - 0.8)*0.42;
        P(end+1) = pr('poly', [xb; xt], [yb; yt]);
        ports.in = [-0.6 0.45];  pdir.in = 'W';
        ports.out = [0.6 -0.45]; pdir.out = 'E';
        ports.top = [0 1.052];   pdir.top = 'N';
        ports.bottom = [0 -1.052]; pdir.bottom = 'S';
    case {'agitated_tank', 'leach_tank', 'cil_tank'}
        [X, Y] = rect(-0.9, -0.9, 0.9, 0.7);   P(end+1) = pr('poly', X, Y);
        P(end+1) = pr('line', [-0.85 0.85], [0.52 0.52], '', '--', 0.5);  % level
        P(end+1) = pr('line', [0 0], [0.85 -0.45], '', '-', 1);           % shaft
        [X, Y] = rect(-0.36, -0.52, 0.36, -0.42); P(end+1) = pr('poly', X, Y, 'dark');
        [X, Y] = rect(-0.2, 0.85, 0.2, 1.15);  P(end+1) = pr('poly', X, Y);
        ports.in = [-0.9 0.3];   pdir.in = 'W';
        ports.out = [0.9 -0.6];  pdir.out = 'E';
        ports.feed = [-0.55 0.7]; pdir.feed = 'N';     % open top, left
        ports.reagent = [0.55 0.7]; pdir.reagent = 'N'; % open top, right
        ports.top = [0 1.15];    pdir.top = 'N';
        ports.bottom = [0 -0.9]; pdir.bottom = 'S';
    case {'sump', 'pump_box', 'open_tank'}
        [X, Y] = rect(-0.6, -0.5, 0.6, 0.4);  P(end+1) = pr('poly', X, Y, 'mask');
        P(end+1) = pr('line', [-0.6 -0.6 0.6 0.6], [0.4 -0.5 -0.5 0.4]);
        P(end+1) = pr('line', [-0.55 0.55], [0.22 0.22], '', '--', 0.5);
        ports.in = [0 0.4];     pdir.in = 'N';
        ports.in2 = [-0.6 0.05]; pdir.in2 = 'W';
        ports.out = [0.6 -0.35]; pdir.out = 'E';
        ports.bottom = [0 -0.5]; pdir.bottom = 'S';
    case 'pump'
        P(end+1) = pr('poly', [-0.28 0.28 0.14 -0.14], [-0.5 -0.5 -0.25 -0.25]);
        [X, Y] = circ(0, 0, 0.35);             P(end+1) = pr('poly', X, Y);
        xc = sqrt(0.35^2 - 0.2^2);
        P(end+1) = pr('poly', [0 0.58 0.58 xc], [0.35 0.35 0.2 0.2], 'mask');
        P(end+1) = pr('line', [0 0.58 0.58 xc], [0.35 0.35 0.2 0.2]);
        ports.suction = [-0.35 0];     pdir.suction = 'W';
        ports.discharge = [0.58 0.275]; pdir.discharge = 'E';
    case 'mill'
        v = lower(o.Variant); if isempty(v), v = 'ball'; end
        switch v
            case 'sag', sh = 0.8; xs = 0.7; xc = 1.05;
            otherwise,  sh = 0.6; xs = 0.9; xc = 1.2;
        end
        tr = 0.18; xt = xc + 0.3;
        Xo = [-xt -xc -xs xs xc xt xt xc xs -xs -xc -xt];
        Yo = [tr tr sh sh tr tr -tr -tr -sh -sh -tr -tr];
        P(end+1) = pr('poly', Xo, Yo);
        [X, Y] = rect(xs*0.55, -sh-0.08, xs*0.55+0.1, sh+0.08); P(end+1) = pr('poly', X, Y);
        switch v
            case 'rod'
                for yy = [-0.45 -0.32 -0.19]
                    P(end+1) = pr('line', [-xs+0.1 xs-0.1], [yy yy], '', '-', 1.2); %#ok<AGROW>
                end
            otherwise
                b = [-0.5 -0.42; -0.3 -0.46; -0.1 -0.46; 0.1 -0.42; -0.4 -0.26; ...
                     -0.2 -0.3; 0 -0.28; -0.3 -0.12; 0.2 -0.26];
                if strcmp(v, 'sag'), b = b(1:2:end, :); b(:, 2) = b(:, 2) - 0.15; end
                for k = 1:size(b, 1)
                    [X, Y] = circ(b(k, 1), b(k, 2), 0.075, 0, 2*pi, 24);
                    P(end+1) = pr('poly', X, Y, 'dark', '-', 0.5); %#ok<AGROW>
                end
        end
        ports.feed = [-xt 0];     pdir.feed = 'W';
        ports.discharge = [xt 0]; pdir.discharge = 'E';
    case 'valve'
        P(end+1) = pr('poly', [-0.25 -0.25 0 0.25 0.25 0], [-0.15 0.15 0 0.15 -0.15 0]);
        ports.in = [-0.25 0]; pdir.in = 'W'; ports.out = [0.25 0]; pdir.out = 'E';
    case 'control_valve'
        P(end+1) = pr('poly', [-0.25 -0.25 0 0.25 0.25 0], [-0.15 0.15 0 0.15 -0.15 0]);
        P(end+1) = pr('line', [0 0], [0 0.3]);
        [X, Y] = circ(0, 0.3, 0.18, 0, pi, 30); P(end+1) = pr('poly', X, Y);
        ports.in = [-0.25 0]; pdir.in = 'W'; ports.out = [0.25 0]; pdir.out = 'E';
        ports.actuator = [0 0.48]; pdir.actuator = 'N';
    case 'instrument'
        shp = 'circle'; r = 0.3;
        v = lower(o.Variant); if isempty(v), v = 'field'; end
        if any(strcmp(v, {'dcs', 'plc'}))
            [X, Y] = rect(-r, -r, r, r); P(end+1) = pr('poly', X, Y, 'fill', '-', 0.8);
        end
        if strcmp(v, 'plc')
            P(end+1) = pr('poly', [0 r 0 -r], [-r 0 r 0], 'fill', '-', 0.8);
        else
            [X, Y] = circ(0, 0, r); P(end+1) = pr('poly', X, Y, 'fill', '-', 0.8);
        end
        if strcmp(v, 'panel')
            P(end+1) = pr('line', [-r r], [0 0], '', '-', 0.8);
        end
        ports.N = [0 r]; pdir.N = 'N'; ports.S = [0 -r]; pdir.S = 'S';
        ports.E = [r 0]; pdir.E = 'E'; ports.W = [-r 0]; pdir.W = 'W';
    case 'thickener'
        P(end+1) = pr('poly', [-1.5 -1.5 -0.15 0.15 1.5 1.5], [0.4 0 -0.5 -0.5 0 0.4], 'mask');
        P(end+1) = pr('line', [-1.5 -1.5 -0.15 0.15 1.5 1.5], [0.4 0 -0.5 -0.5 0 0.4]);
        [X, Y] = rect(-0.1, -0.7, 0.1, -0.5);    P(end+1) = pr('poly', X, Y);
        [X, Y] = rect(1.5, 0.18, 1.75, 0.4);     P(end+1) = pr('poly', X, Y);   % launder
        [X, Y] = rect(-0.35, 0.05, 0.35, 0.45);  P(end+1) = pr('poly', X, Y, 'fill', '-', 0.7);
        P(end+1) = pr('line', [0 0], [0.45 -0.35], '', '-', 0.8);
        P(end+1) = pr('line', [-1.25 0 1.25], [0.02 -0.36 0.02], '', '-', 0.8); % rakes
        [X, Y] = rect(-0.1, 0.45, 0.1, 0.62);    P(end+1) = pr('poly', X, Y);
        P(end+1) = pr('line', [-1.45 1.45], [0.33 0.33], '', '--', 0.5);
        ports.feed = [-0.25 0.45];   pdir.feed = 'N';
        ports.overflow = [1.75 0.29]; pdir.overflow = 'E';
        ports.underflow = [0 -0.7];  pdir.underflow = 'S';
    case 'screen'
        P(end+1) = pr('poly', [-0.8 0.8 0.15 -0.15], [-0.3 -0.3 -0.75 -0.75]);
        P(end+1) = pr('poly', [-1.2 1.2 1.2 -1.2], [0.35 -0.15 0.05 0.6]);
        P(end+1) = pr('line', [-1.1 1.1], [0.4 -0.02], '', '--', 0.7);
        P(end+1) = pr('line', [-0.9 -0.9 NaN 0.9 0.9], [0.28 -0.1 NaN -0.1 -0.45], '', '-', 0.7);
        ports.feed = [-1.2 0.5];    pdir.feed = 'W';
        ports.oversize = [1.2 -0.05]; pdir.oversize = 'E';
        ports.undersize = [0 -0.75]; pdir.undersize = 'S';
    case 'conveyor'
        r = 0.12;
        P(end+1) = pr('line', [-1.2 1.2 NaN -1.2 1.2], [r r NaN -r -r]);
        [X, Y] = circ(-1.2, 0, r); P(end+1) = pr('poly', X, Y);
        [X, Y] = circ(1.2, 0, r);  P(end+1) = pr('poly', X, Y);
        ports.in = [-0.95 0.3]; pdir.in = 'N';
        ports.out = [1.35 0];   pdir.out = 'E';
    case {'bin', 'hopper'}
        P(end+1) = pr('poly', [-0.6 0.6 0.6 0.12 -0.12 -0.6], [0.6 0.6 0 -0.5 -0.5 0]);
        [X, Y] = rect(-0.12, -0.65, 0.12, -0.5); P(end+1) = pr('poly', X, Y);
        ports.in = [0 0.6]; pdir.in = 'N'; ports.out = [0 -0.65]; pdir.out = 'S';
    case 'stockpile'
        [X, Y] = circ(0, -0.3, 1.0, 0, pi, 40); Y = -0.3 + (Y + 0.3)*0.65;
        P(end+1) = pr('poly', X, Y);
        P(end+1) = pr('line', [-1.15 1.15], [-0.3 -0.3], '', '-', 1.2);
        ports.in = [0 0.35]; pdir.in = 'N'; ports.out = [0 -0.3]; pdir.out = 'S';
    case 'column'
        [X, Y] = rect(-0.35, -1.2, 0.35, 1.2); P(end+1) = pr('poly', X, Y);
        if strcmpi(o.Variant, 'flotation')
            b = [-0.15 -0.6; 0.1 -0.3; -0.05 0.0; 0.15 0.3; -0.12 0.55; 0.05 0.8];
            for k = 1:size(b, 1)
                [X, Y] = circ(b(k, 1), b(k, 2), 0.06, 0, 2*pi, 20);
                P(end+1) = pr('poly', X, Y, 'none', '-', 0.5); %#ok<AGROW>
            end
        end
        ports.in = [-0.35 0.3]; pdir.in = 'W'; ports.out = [0.35 0.9]; pdir.out = 'E';
        ports.top = [0 1.2]; pdir.top = 'N'; ports.bottom = [0 -1.2]; pdir.bottom = 'S';
    case 'motor'
        shp = 'circle';
        [X, Y] = circ(0, 0, 0.3); P(end+1) = pr('poly', X, Y);
    case {'heat_exchanger', 'hx'}
        shp = 'circle';
        [X, Y] = circ(0, 0, 0.35); P(end+1) = pr('poly', X, Y);
        P(end+1) = pr('line', [-0.5 -0.2 -0.1 0.05 0.15 0.5], [0 0 0.2 -0.2 0 0]);
        ports.in = [-0.5 0]; pdir.in = 'W'; ports.out = [0.5 0]; pdir.out = 'E';
        ports.shell_in = [0 0.35]; pdir.shell_in = 'N';
        ports.shell_out = [0 -0.35]; pdir.shell_out = 'S';
    otherwise
        error('pd:equipment', 'Unknown equipment type "%s".', type);
end
end
