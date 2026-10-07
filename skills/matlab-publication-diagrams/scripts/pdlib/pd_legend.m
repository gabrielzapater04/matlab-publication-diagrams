function G = pd_legend(x, y, items, varargin)
%PD_LEGEND Diagram legend for line types and colour roles.
%   pd_legend(x, y, items)  (x,y) = top-left corner of the legend, cm
%   items: cell array, one row per entry:
%     {'line',  'Slurry stream', 'Type','pipe'}      any pd_connect Type
%     {'arrow', 'Information flow'}
%     {'patch', 'ML model', 'Role','model'}          role-coloured swatch
%     {'patch', 'Measured', 'Fill',[1 1 1], 'Edge',[0 0 0]}
%   Options: 'Columns' (1), 'ColWidth' (cm, auto), 'RowH' (0.42),
%            'Box' (true), 'Title' (''), 'FontSize'
S = pd_getstyle();
o = pd_opts(struct('Columns', 1, 'ColWidth', [], 'RowH', 0.42, 'Box', true, ...
    'Title', '', 'FontSize', S.fontSizeSmall, 'Parent', gca), varargin{:});
ax = o.Parent; n = numel(items);
sw = 0.9;                                  % swatch length (cm)
if isempty(o.ColWidth)
    mx = 0;
    for k = 1:n, mx = max(mx, numel(items{k}{2})); end
    o.ColWidth = sw + 0.25 + mx*o.FontSize*0.0353*0.55 + 0.3;
end
nr = ceil(n / o.Columns);
x0 = x + 0.2; y0 = y - 0.2 - o.RowH/2;
if ~isempty(o.Title), y0 = y0 - o.RowH; end
h = pd_hempty();
for k = 1:n
    it = items{k}; kind = lower(it{1}); lab = it{2}; extra = it(3:end);
    c = floor((k-1) / nr); r = mod(k-1, nr);
    xs = x0 + c*o.ColWidth; ys = y0 - r*o.RowH;
    switch kind
        case {'line', 'arrow'}
            arr = 'none'; if strcmp(kind, 'arrow'), arr = 'end'; end
            e = [{'Arrow', arr}, extra];
            Cn = pd_connect([xs ys], [xs+sw ys], 'Route', 'straight', e{:}, 'Parent', ax);
            h = [h, Cn.handles]; %#ok<AGROW>
        case 'patch'
            q = pd_opts(struct('Role', '', 'Fill', [], 'Edge', [], 'LineStyle', '-'), extra{:});
            [f, ed] = pd_rolecolor(S, q.Role);
            if ~isempty(q.Fill), f = q.Fill; end
            if ~isempty(q.Edge), ed = q.Edge; end
            [px, py] = pd_shape('rounded', xs+sw/2, ys, sw*0.7, o.RowH*0.62, 0.05);
            h(end+1) = pd_patch(px, py, f, 'EdgeColor', ed, 'LineWidth', S.lineWidthThin, ...
                'LineStyle', q.LineStyle, 'Parent', ax); %#ok<AGROW>
        otherwise, error('pd:legend', 'Unknown item kind "%s".', kind);
    end
    h(end+1) = text(xs + sw + 0.2, ys, lab, 'Parent', ax, 'FontName', S.font, ...
        'FontSize', o.FontSize, 'Color', S.textColor, 'Interpreter', S.interpreter, ...
        'VerticalAlignment', 'middle', 'Tag', 'pd_legendtext'); %#ok<AGROW>
end
W = 0.2 + o.Columns*o.ColWidth; H = 0.4 + nr*o.RowH + ~isempty(o.Title)*o.RowH;
if ~isempty(o.Title)
    h(end+1) = text(x + 0.2, y - 0.2, o.Title, 'Parent', ax, 'FontName', S.font, ...
        'FontSize', o.FontSize, 'FontWeight', 'bold', 'VerticalAlignment', 'top', ...
        'Color', S.textColor, 'Tag', 'pd_legendtext');
end
if o.Box
    hb = pd_patch([x x+W x+W x], [y-H y-H y y], [1 1 1], 'EdgeColor', S.groupEdge, ...
        'LineWidth', S.lineWidthThin, 'Parent', ax);
    pd_toback(ax, hb); h(end+1) = hb;
end
G = pd_mknode('legend', 'box', x + W/2, y - H/2, W, H, h, o.Title);
end
