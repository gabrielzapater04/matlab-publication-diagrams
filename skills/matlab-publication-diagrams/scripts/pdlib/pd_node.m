function N = pd_node(x, y, label, varargin)
%PD_NODE Draw a labelled node centred at (x, y) [cm].
%   N = pd_node(x, y, 'Text')
%   N = pd_node(x, y, {'Line 1', 'Line 2'}, 'Shape','decision', 'Role','optim')
%
%   Options (defaults from the active pd_style):
%     'Shape'      see pd_shape: process | rounded | terminal | decision |
%                  io | database | document | predefined | hexagon |
%                  ellipse | circle | note | stack
%     'W','H'      size in cm ('W','auto' fits the label)
%     'Role'       semantic colour: process | model | optim | decision |
%                  data | io | output | highlight | neutral | none |
%                  palette index | RGB fill
%     'Fill','Edge'  explicit colours (override Role)
%     'LineWidth','LineStyle'
%     'FontSize','FontWeight','FontAngle','TextColor','Interpreter'
%     'Rotation'   text rotation in degrees (e.g. 90 for tall thin blocks)
%     'Radius'     corner radius for 'rounded'
%     'TextDX','TextDY'  nudge the label (cm)
%
%   Returns a node struct usable by pd_connect, pd_group and pd_anchor.
S = pd_getstyle();
if nargin < 3, label = ''; end
o = pd_opts(struct('Shape', 'rounded', 'W', S.nodeW, 'H', S.nodeH, ...
    'Role', '', 'Fill', [], 'Edge', [], 'LineWidth', S.lineWidth, ...
    'LineStyle', '-', 'FontSize', S.fontSize, 'FontWeight', 'normal', ...
    'FontAngle', 'normal', 'TextColor', S.textColor, ...
    'Interpreter', S.interpreter, 'Rotation', 0, 'Radius', S.corner, ...
    'TextDX', 0, 'TextDY', 0, 'Parent', gca), varargin{:});
w = o.W; h = o.H; ax = o.Parent;
if ischar(w) && strcmpi(w, 'auto')           % fit width to the longest line
    w = max(1.2, pd_textwidth(label, o.FontSize) + 0.45);
    if any(strcmpi(o.Shape, {'decision', 'diamond'})), w = w*1.6; end
    if any(strcmpi(o.Shape, {'io', 'hexagon'})), w = w + 0.4; end
end
if any(strcmpi(o.Shape, {'circle'})), h = w; end

[fill, edge] = pd_rolecolor(S, o.Role);
if ~isempty(o.Fill), fill = o.Fill; end
if ~isempty(o.Edge), edge = o.Edge; end

hs = pd_hempty();
if strcmpi(o.Shape, 'stack')      % offset copies behind: "many models"
    d = 0.08 + 0.02*w;
    for k = 2:-1:1
        [px, py] = pd_shape('rounded', x + k*d, y + k*d, w, h, o.Radius);
        hs(end+1) = pd_patch(px, py, fill*0.97, 'EdgeColor', edge, ...
            'LineWidth', o.LineWidth, 'Parent', ax); %#ok<AGROW>
    end
end
[px, py, extra] = pd_shape(o.Shape, x, y, w, h, o.Radius);
if ischar(fill) && strcmpi(fill, 'none')
    hp = pd_patch(px, py, [1 1 1], 'FaceColor', 'none', 'EdgeColor', edge, ...
        'LineWidth', o.LineWidth, 'LineStyle', o.LineStyle, 'Parent', ax);
else
    hp = pd_patch(px, py, fill, 'EdgeColor', edge, 'LineWidth', o.LineWidth, ...
        'LineStyle', o.LineStyle, 'Parent', ax);
end
hs(end+1) = hp;
if ~isempty(extra)
    hs(end+1) = line(extra{1}, extra{2}, 'Color', edge, ...
        'LineWidth', o.LineWidth, 'Parent', ax);
end

ty = y + o.TextDY;
switch lower(o.Shape)
    case {'database', 'cylinder'}, ty = ty - 0.06*h;
    case 'document',               ty = ty + 0.05*h;
end
if ~isempty(label)
    ht = text(x + o.TextDX, ty, label, 'Parent', ax, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'FontName', S.font, 'FontSize', o.FontSize, 'FontWeight', o.FontWeight, ...
        'FontAngle', o.FontAngle, 'Color', o.TextColor, ...
        'Interpreter', o.Interpreter, 'Rotation', o.Rotation, 'Tag', 'pd_nodetext');
    hs(end+1) = ht;
end
N = pd_mknode('node', lower(o.Shape), x, y, w, h, hs, label);
end
