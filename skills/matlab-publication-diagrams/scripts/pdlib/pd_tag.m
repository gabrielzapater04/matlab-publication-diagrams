function N = pd_tag(x, y, str, varargin)
%PD_TAG Small labelled marker: PFD stream numbers, step numbers, callouts.
%   pd_tag(x, y, '3')                       stream number (diamond)
%   pd_tag(x, y, 'A', 'Shape','circle', 'Role','highlight')
%   Shapes: 'diamond' (PFD streams) | 'circle' (steps) | 'rect' | 'flag'
S = pd_getstyle();
o = pd_opts(struct('Shape', 'diamond', 'Size', [], 'Role', '', ...
    'FontSize', S.fontSizeSmall, 'FontWeight', 'normal', ...
    'LineWidth', S.lineWidthThin, 'Parent', gca), varargin{:});
sz = o.Size;
if isempty(sz), sz = max(0.42, 0.045*o.FontSize*max(1, numel(str)*0.6)); end
[fill, edge] = pd_rolecolor(S, o.Role);
ax = o.Parent;
switch lower(o.Shape)
    case 'diamond', shp = 'decision'; w = sz*1.25; h = sz*1.0;
    case 'circle',  shp = 'circle';   w = sz; h = sz;
    case 'rect',    shp = 'process';  w = sz*1.2; h = sz*0.75;
    case 'flag'
        w = sz*1.4; h = sz*0.75;
        px = [x-w/2 x+w/2-h/2 x+w/2 x+w/2-h/2 x-w/2]';
        py = [y-h/2 y-h/2 y y+h/2 y+h/2]';
        shp = '';
    otherwise, error('pd:tag', 'Unknown Shape "%s".', o.Shape);
end
if ~isempty(shp), [px, py] = pd_shape(shp, x, y, w, h); end
hp = pd_patch(px, py, fill, 'EdgeColor', edge, 'LineWidth', o.LineWidth, 'Parent', ax);
ht = text(x, y, str, 'Parent', ax, 'FontName', S.font, 'FontSize', o.FontSize, ...
    'FontWeight', o.FontWeight, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'Color', S.textColor, ...
    'Interpreter', S.interpreter, 'Tag', 'pd_tagtext');
N = pd_mknode('tag', 'box', x, y, w, h, [hp ht], str);
end
