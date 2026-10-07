function N = pd_icon(type, x, y, varargin)
%PD_ICON Small vector icon for architecture / pipeline diagrams.
%   pd_icon('tree', x, y)                 decision tree (RF / GBM / XGBoost)
%   pd_icon('nn', x, y, 'Size', 1.0, 'Role','model')
%   Types: 'tree' | 'forest' | 'nn' | 'gear' | 'chart' | 'database' |
%          'server' | 'cloud' | 'sensor' | 'user' | 'doc' | 'optim' | 'loop'
%   Options: 'Size' (box side, cm, 0.8), 'Role' ('' = dark ink),
%            'Label' (below), 'FontSize', 'LineWidth'
%   Icons are pure vector geometry (no fonts, no bitmaps) so they export
%   cleanly to PDF/EPS and scale without artefacts.
S = pd_getstyle();
o = pd_opts(struct('Size', 0.8, 'Role', '', 'Label', '', ...
    'FontSize', S.fontSizeSmall, 'LineWidth', S.lineWidthThin, 'Parent', gca), varargin{:});
ax = o.Parent; s = o.Size; lw = o.LineWidth;
if isempty(o.Role), f = [1 1 1]; e = S.edgeColor;
else, [f, e] = pd_rolecolor(S, o.Role); end
h = pd_hempty();
t = linspace(0, 2*pi, 41)'; t(end) = [];
circ = @(cx, cy, r, fc) pd_patch(cx + r*cos(t), cy + r*sin(t), fc, 'EdgeColor', e, ...
    'LineWidth', lw, 'Parent', ax);
ln = @(X, Y) line(X, Y, 'Color', e, 'LineWidth', lw, 'Parent', ax);
switch lower(type)
    case 'tree'
        h = local_tree(x, y, s, f, e, lw, ax, circ, ln);
    case 'forest'
        h = [local_tree(x - 0.3*s, y + 0.1*s, 0.6*s, f, e, lw, ax, circ, ln), ...
             local_tree(x + 0.3*s, y + 0.1*s, 0.6*s, f, e, lw, ax, circ, ln), ...
             local_tree(x, y - 0.25*s, 0.6*s, f, e, lw, ax, circ, ln)];
    case 'nn'
        L = {[-0.25 0 0.25], [-0.36 -0.12 0.12 0.36], [-0.15 0.15]};
        xs = [-0.38 0 0.38]*s;
        for l = 1:2
            for i = 1:numel(L{l}), for j = 1:numel(L{l+1})
                h(end+1) = ln(x + xs([l l+1]), y + [L{l}(i) L{l+1}(j)]*s); %#ok<AGROW>
            end, end
        end
        for l = 1:3, for i = 1:numel(L{l})
            h(end+1) = circ(x + xs(l), y + L{l}(i)*s, 0.07*s, f); %#ok<AGROW>
        end, end
    case 'gear'
        nt = 8;
        r = repmat([0.30 0.42 0.42 0.30]', nt, 1)*s;
        k = (0:4*nt-1)'; base = floor(k/4)*(2*pi/nt);
        off = repmat([0 0.12 0.38 0.5]', nt, 1)*(2*pi/nt);
        a = base + off;
        h(end+1) = pd_patch(x + r.*cos(a), y + r.*sin(a), f, 'EdgeColor', e, 'LineWidth', lw, 'Parent', ax);
        h(end+1) = circ(x, y, 0.12*s, [1 1 1]);
    case 'chart'
        h(end+1) = ln(x + [-0.4 -0.4 0.4]*s, y + [0.4 -0.4 -0.4]*s);
        h(end+1) = line(x + [-0.32 -0.15 0.0 0.15 0.32]*s, y + [-0.25 0.0 -0.1 0.2 0.3]*s, ...
            'Color', e, 'LineWidth', lw*1.6, 'Parent', ax);
        for k = [-0.25 -0.05 0.15]
            h(end+1) = pd_patch(x + (k + [0 0.12 0.12 0])*s, y + [-0.4 -0.4 -0.3 -0.3]*s - 0.0, f, ...
                'EdgeColor', e, 'LineWidth', lw, 'Parent', ax); %#ok<AGROW>
        end
    case 'database'
        [px, py, ex] = pd_shape('database', x, y, 0.6*s, 0.8*s);
        h(end+1) = pd_patch(px, py, f, 'EdgeColor', e, 'LineWidth', lw, 'Parent', ax);
        h(end+1) = ln(ex{1}, ex{2});
        h(end+1) = ln(ex{1}, ex{2} - 0.22*s);
    case 'server'
        for k = 1:3
            yc = y + (k - 2)*0.27*s;
            h(end+1) = pd_patch(x + [-0.35 0.35 0.35 -0.35]*s, yc + [-0.11 -0.11 0.11 0.11]*s, f, ...
                'EdgeColor', e, 'LineWidth', lw, 'Parent', ax); %#ok<AGROW>
            h(end+1) = circ(x + 0.24*s, yc, 0.035*s, e); %#ok<AGROW>
        end
    case 'cloud'
        % union of circles: fill without edges, then outline only the arcs
        % that are not inside another circle (true silhouette, no seams)
        c = [-0.22 -0.08 0.14; 0.02 0.10 0.2; 0.24 -0.06 0.15; -0.36 -0.14 0.08; 0.36 -0.14 0.08]*s;
        yb = y - 0.22*s;
        for k = 1:size(c, 1)
            h(end+1) = pd_patch(x + c(k,1) + c(k,3)*cos(t), y + c(k,2) + c(k,3)*sin(t), f, ...
                'EdgeColor', 'none', 'Parent', ax); %#ok<AGROW>
        end
        h(end+1) = pd_patch(x + [-0.36 0.36 0.36 -0.36]*s, [yb yb y-0.1*s y-0.1*s], f, ...
            'EdgeColor', 'none', 'Parent', ax);
        tt = linspace(0, 2*pi, 181)';
        X = []; Y = [];
        for k = 1:size(c, 1)
            px = x + c(k,1) + c(k,3)*cos(tt); py = y + c(k,2) + c(k,3)*sin(tt);
            in = py < yb;
            for m = 1:size(c, 1)
                if m == k, continue; end
                in = in | ((px - x - c(m,1)).^2 + (py - y - c(m,2)).^2 < (c(m,3)*0.999)^2);
            end
            px(in) = NaN; py(in) = NaN;
            X = [X; px; NaN]; Y = [Y; py; NaN]; %#ok<AGROW>
        end
        h(end+1) = ln(X, Y);
        h(end+1) = ln(x + [-0.36 0.36]*s, [yb yb]);
    case 'sensor'
        h(end+1) = circ(x - 0.2*s, y - 0.1*s, 0.12*s, f);
        for r = [0.25 0.38 0.51]
            a = linspace(-pi/5, pi/2.2, 15)';
            h(end+1) = ln(x - 0.2*s + r*s*cos(a), y - 0.1*s + r*s*sin(a)); %#ok<AGROW>
        end
    case 'user'
        h(end+1) = circ(x, y + 0.15*s, 0.16*s, f);
        a = linspace(0, pi, 30)';
        h(end+1) = pd_patch(x + 0.32*s*cos(a), y - 0.4*s + 0.36*s*sin(a), f, ...
            'EdgeColor', e, 'LineWidth', lw, 'Parent', ax);
    case 'doc'
        h(end+1) = pd_patch(x + [-0.28 0.14 0.28 0.28 -0.28]*s, y + [0.4 0.4 0.26 -0.4 -0.4]*s, f, ...
            'EdgeColor', e, 'LineWidth', lw, 'Parent', ax);
        for k = 1:4
            h(end+1) = ln(x + [-0.18 0.18]*s, y + [1 1]*(0.18 - (k-1)*0.14)*s); %#ok<AGROW>
        end
    case 'optim'
        xs = linspace(-0.38, 0.38, 40)';
        h(end+1) = line(x + xs*s, y + (-0.25 + 2.2*(xs - 0.08).^2)*s, 'Color', e, ...
            'LineWidth', lw*1.4, 'Parent', ax);
        h(end+1) = circ(x + 0.08*s, y - 0.25*s, 0.06*s, e);
        h(end+1) = ln(x + [-0.4 -0.4 0.42]*s, y + [0.42 -0.4 -0.4]*s);
    case 'loop'
        a = linspace(0.35, 2*pi - 0.35, 50)';
        X = x + 0.32*s*cos(a); Y = y + 0.32*s*sin(a);
        h(end+1) = line(X, Y, 'Color', e, 'LineWidth', lw*1.6, 'Parent', ax);
        tip = [X(end) Y(end)]; v = [-sin(a(end)) cos(a(end))]; nv = [-v(2) v(1)];
        L = 0.16*s; W = 0.14*s; b = tip - v*L;
        h(end+1) = pd_patch([tip(1) b(1)+nv(1)*W b(1)-nv(1)*W], [tip(2) b(2)+nv(2)*W b(2)-nv(2)*W], ...
            e, 'EdgeColor', e, 'Parent', ax);
    otherwise
        error('pd:icon', 'Unknown icon "%s".', type);
end
if ~isempty(o.Label)
    yl = y - 0.5*s - 0.08; if strcmpi(type, 'cloud'), yl = y - 0.25*s - 0.08; end
    h(end+1) = text(x, yl, o.Label, 'Parent', ax, 'FontName', S.font, ...
        'FontSize', o.FontSize, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
        'Color', S.textColor, 'Interpreter', S.interpreter, 'Tag', 'pd_iconlabel');
end
N = pd_mknode('icon', 'box', x, y, s, s, h, o.Label);
end

function h = local_tree(x, y, s, f, e, lw, ax, circ, ln)
h = pd_hempty();
P = [0 0.32; -0.22 0; 0.22 0; -0.33 -0.32; -0.11 -0.32; 0.11 -0.32; 0.33 -0.32]*s;
E = [1 2; 1 3; 2 4; 2 5; 3 6; 3 7];
for k = 1:size(E, 1)
    h(end+1) = ln(x + P(E(k,:), 1), y + P(E(k,:), 2)); %#ok<AGROW>
end
for k = 1:size(P, 1)
    fc = f; if k >= 4, fc = e; end
    h(end+1) = circ(x + P(k,1), y + P(k,2), 0.075*s, fc); %#ok<AGROW>
end
end
