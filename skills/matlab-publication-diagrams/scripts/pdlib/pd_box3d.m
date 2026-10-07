function N = pd_box3d(x, y, w, h, d, varargin)
%PD_BOX3D Oblique cuboid: tensors, CNN feature maps, data cubes.
%   N = pd_box3d(x, y, w, h, d)  front face centred at (x,y), w x h cm,
%                                depth d cm drawn at 'Angle' degrees.
%   N = pd_box3d(3, 2, 0.3, 2.4, 2.0, 'Role','model', 'Label','Conv 3x3, 32', ...
%                'Dims', {'64','64','32'})
%   Options: 'Role','Fill','Edge','Angle' (40),'DepthScale' (0.5),
%            'Label' (below), 'Dims' {h, w, c} labels on the edges,
%            'FontSize','LineWidth'
S = pd_getstyle();
o = pd_opts(struct('Role', 'model', 'Fill', [], 'Edge', [], 'Angle', 40, ...
    'DepthScale', 0.5, 'Label', '', 'Dims', {{}}, 'FontSize', S.fontSizeSmall, ...
    'LineWidth', S.lineWidthThin, 'Parent', gca), varargin{:});
ax = o.Parent;
[f, e] = pd_rolecolor(S, o.Role);
if ~isempty(o.Fill), f = o.Fill; end
if ~isempty(o.Edge), e = o.Edge; end
a = o.Angle*pi/180; dx = d*o.DepthScale*cos(a); dy = d*o.DepthScale*sin(a);
L = x - w/2; R = x + w/2; B = y - h/2; T = y + h/2;
h1 = pd_patch([L R R L], [B B T T], f, 'EdgeColor', e, 'LineWidth', o.LineWidth, 'Parent', ax);
h2 = pd_patch([L R R+dx L+dx], [T T T+dy T+dy], 0.85*f + 0.15, 'EdgeColor', e, ...
    'LineWidth', o.LineWidth, 'Parent', ax);
h3 = pd_patch([R R+dx R+dx R], [B B+dy T+dy T], 0.72*f + 0.28*e, 'EdgeColor', e, ...
    'LineWidth', o.LineWidth, 'Parent', ax);
hs = [h1 h2 h3];
fs = o.FontSize;
if numel(o.Dims) >= 1 && ~isempty(o.Dims{1})     % height, left edge
    hs(end+1) = text(L - 0.06, y - 0.3*h, o.Dims{1}, 'Parent', ax, 'FontSize', fs - 1, ... % below arrow height
        'FontName', S.font, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
end
if numel(o.Dims) >= 2 && ~isempty(o.Dims{2})     % width, bottom edge
    hs(end+1) = text(x, B - 0.05, o.Dims{2}, 'Parent', ax, 'FontSize', fs - 1, ...
        'FontName', S.font, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
end
if numel(o.Dims) >= 3 && ~isempty(o.Dims{3})     % depth, top-right edge
    hs(end+1) = text(R + dx/2 + 0.06, T + dy/2, o.Dims{3}, 'Parent', ax, ...
        'FontSize', fs - 1, 'FontName', S.font, 'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top');
end
yb = B - 0.08; if numel(o.Dims) >= 2 && ~isempty(o.Dims{2}), yb = yb - 0.3; end
if ~isempty(o.Label)
    hs(end+1) = text(x + dx/2, yb, o.Label, 'Parent', ax, 'FontSize', fs, ...
        'FontName', S.font, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
        'Interpreter', S.interpreter, 'Tag', 'pd_boxlabel');
end
% Node is centred on the FRONT face's mid-height (bbox made symmetric) so
% that E/W anchors of boxes with different depths line up -> straight arrows.
N = pd_mknode('box3d', 'box', x + dx/2, y, w + dx, h + 2*dy, hs, o.Label);
end
