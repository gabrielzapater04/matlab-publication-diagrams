function [fig, ax] = pd_figure(w, h, S, varargin)
%PD_FIGURE Create a diagram canvas where 1 data unit = 1 cm on paper.
%   [fig, ax] = pd_figure(w, h)          w x h cm, default style
%   [fig, ax] = pd_figure(w, h, S)       with a pd_style struct
%   w may also be 'single' | 'mid' | 'double' (uses the style's widths).
%
%   Options:
%     'Visible'  'on'|'off'  (use 'off' for batch/headless export)
%     'Grid'     true -> draws a 1 cm layout grid with coordinates. Use it
%                while designing, then set false for the final export.
%
%   Coordinates: origin (0,0) is bottom-left, x to the right, y upward,
%   everything in cm. Place nodes by their CENTRE.

if nargin < 3 || isempty(S), S = pd_style(); end
o = pd_opts(struct('Visible', 'on', 'Grid', false), varargin{:});
if ischar(w)
    switch lower(w)
        case {'single', 'col', 'column'}, w = S.colWidth;
        case {'mid', '1.5', 'onehalf'},   w = S.midWidth;
        case {'double', 'full', 'two'},   w = S.twoColWidth;
        otherwise, error('pd:figure', 'Unknown width "%s".', w);
    end
end
if h > S.maxHeight
    warning('pd:figure', 'Height %.1f cm exceeds max page height %.1f cm.', h, S.maxHeight);
end

fig = figure('Color', 'w', 'Visible', o.Visible, 'InvertHardcopy', 'off', ...
    'Units', 'centimeters');
p = get(fig, 'Position');
set(fig, 'Position', [p(1) p(2) w h]);
% Orientation must be forced: Octave flips to 'landscape' when w > h,
% which silently crops wide figures on export.
set(fig, 'PaperUnits', 'centimeters', 'PaperOrientation', 'portrait', 'PaperSize', [w h], ...
    'PaperPositionMode', 'manual', 'PaperPosition', [0 0 w h]);
try, set(fig, 'Renderer', 'painters'); catch, end  % vector output

ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0 0 1 1], ...
    'XLim', [0 w], 'YLim', [0 h], 'Visible', 'off', 'Color', 'none');
set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual', 'DataAspectRatio', [1 1 1]);
hold(ax, 'on');
set(ax, 'FontName', S.font, 'FontSize', S.fontSize);

setappdata(fig, 'pd_style', S);
setappdata(ax, 'pd_style', S);
setappdata(ax, 'pd_size', [w h]);

if o.Grid, local_grid(ax, w, h); end
end

function local_grid(ax, w, h)
c = [0.85 0.90 1.0];
for x = 0:floor(w)
    line([x x], [0 h], 'Color', c, 'LineWidth', 0.25, 'Parent', ax, 'Tag', 'pd_grid');
    text(x, 0.05, sprintf('%d', x), 'FontSize', 5, 'Color', [0.4 0.5 0.9], ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'Parent', ax, 'Tag', 'pd_grid');
end
for y = 0:floor(h)
    line([0 w], [y y], 'Color', c, 'LineWidth', 0.25, 'Parent', ax, 'Tag', 'pd_grid');
    text(0.05, y, sprintf('%d', y), 'FontSize', 5, 'Color', [0.4 0.5 0.9], ...
        'VerticalAlignment', 'middle', 'Parent', ax, 'Tag', 'pd_grid');
end
end
