function G = pd_group(target, varargin)
%PD_GROUP Frame around nodes (subsystem, module, plant area, layer...).
%   G = pd_group([n1 n2 n3], 'Title','Data layer')
%   G = pd_group({n1, eq1}, 'Title','Grinding', 'Role','process')
%   G = pd_group([xmin ymin w h], 'Title','Area 200')      explicit box
%
%   Options
%     'Title'      text; 'TitlePos' 'top-left'|'top'|'top-right'|
%                  'bottom-left'|'bottom'|'outside-top-left'
%     'Pad'        padding around nodes (cm), scalar or [l r b t]
%     'Role'       fill tint from palette ('' = light grey, 'none' = no fill)
%     'Fill','Edge','LineStyle' ('--' default),'LineWidth','Radius'
%     'FontWeight' ('bold'), 'FontSize'
%     'TitleSpace' extra top padding reserved for the title (cm, auto)
%   The frame is sent behind everything already drawn, so call it AFTER
%   the nodes it contains. Returns a node struct: you can connect to it.
S = pd_getstyle();
o = pd_opts(struct('Title', '', 'TitlePos', 'top-left', 'Pad', S.pad, ...
    'Role', '', 'Fill', [], 'Edge', [], 'LineStyle', '--', ...
    'LineWidth', S.lineWidthThin, 'Radius', S.corner*1.5, ...
    'FontWeight', 'bold', 'FontSize', S.fontSizeSmall, 'TitleSpace', [], ...
    'Parent', gca), varargin{:});
ax = o.Parent;
pad = o.Pad; if isscalar(pad), pad = pad*[1 1 1 1]; end
if isempty(o.TitleSpace)
    o.TitleSpace = 0;
    if ~isempty(o.Title) && strncmpi(o.TitlePos, 'top', 3)
        nl = 1; if iscell(o.Title), nl = numel(o.Title); end
        o.TitleSpace = nl * o.FontSize * 0.0353 * 1.25;   % pt -> cm
    end
end

if isnumeric(target) && numel(target) == 4
    L = target(1); B = target(2); R = L + target(3); T = B + target(4);
else
    if ~iscell(target), target = num2cell(target); end   % cells may mix kinds
    L = inf; B = inf; R = -inf; T = -inf;
    for k = 1:numel(target)
        n = target{k};
        L = min(L, n.x - n.w/2); R = max(R, n.x + n.w/2);
        B = min(B, n.y - n.h/2); T = max(T, n.y + n.h/2);
    end
    L = L - pad(1); R = R + pad(2); B = B - pad(3); T = T + pad(4) + o.TitleSpace;
end

if isempty(o.Role), fill = S.groupFill; edge = S.groupEdge;
else, [fill, edge] = pd_rolecolor(S, o.Role); fill = fill + (1 - fill)*0.55; end
if ~isempty(o.Fill), fill = o.Fill; end
if ~isempty(o.Edge), edge = o.Edge; end

[px, py] = pd_shape('rounded', (L+R)/2, (B+T)/2, R-L, T-B, o.Radius);
if (ischar(fill) && strcmpi(fill, 'none')) || (ischar(o.Role) && strcmpi(o.Role, 'none'))
    hp = pd_patch(px, py, [1 1 1], 'FaceColor', 'none', 'EdgeColor', edge, ...
        'LineStyle', o.LineStyle, 'LineWidth', o.LineWidth, 'Parent', ax, 'Tag', 'pd_group');
else
    hp = pd_patch(px, py, fill, 'EdgeColor', edge, 'LineStyle', o.LineStyle, ...
        'LineWidth', o.LineWidth, 'Parent', ax, 'Tag', 'pd_group');
end
h = hp;
if ~isempty(o.Title)
    m = 0.15;
    switch lower(o.TitlePos)
        case 'top-left',     xy = [L+m, T-m*0.7]; ha = 'left';   va = 'top';
        case 'top',          xy = [(L+R)/2, T-m*0.7]; ha = 'center'; va = 'top';
        case 'top-right',    xy = [R-m, T-m*0.7]; ha = 'right';  va = 'top';
        case 'bottom-left',  xy = [L+m, B+m*0.7]; ha = 'left';   va = 'bottom';
        case 'bottom',       xy = [(L+R)/2, B+m*0.7]; ha = 'center'; va = 'bottom';
        case 'outside-top-left', xy = [L, T+0.05]; ha = 'left'; va = 'bottom';
        otherwise, error('pd:group', 'Unknown TitlePos "%s".', o.TitlePos);
    end
    h(end+1) = text(xy(1), xy(2), o.Title, 'Parent', ax, 'FontName', S.font, ...
        'FontSize', o.FontSize, 'FontWeight', o.FontWeight, 'Color', edge*0.8, ...
        'HorizontalAlignment', ha, 'VerticalAlignment', va, ...
        'Interpreter', S.interpreter, 'Tag', 'pd_grouptitle');
end
pd_toback(ax, hp);
G = pd_mknode('group', 'box', (L+R)/2, (B+T)/2, R-L, T-B, h, o.Title);
end
