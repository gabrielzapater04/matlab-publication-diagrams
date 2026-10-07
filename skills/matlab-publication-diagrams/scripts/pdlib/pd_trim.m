function sz = pd_trim(fig, varargin)
%PD_TRIM Shrink the canvas to the drawn content plus a margin.
%   pd_trim(fig)                     trim height only (width = journal column)
%   pd_trim(fig, 'Axis','both')      trim width too (e.g. for a sub-panel)
%   pd_trim(fig, 'Margin', 0.2)      margin in cm (0.15)
%   Call it right before pd_check / pd_export. Nothing is moved: the axis
%   limits are changed, so all coordinates you used remain valid.
o = pd_opts(struct('Axis', 'y', 'Margin', 0.15), varargin{:});
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
delete(findall(ax, 'Tag', 'pd_grid'));
drawnow;
L = inf; R = -inf; B = inf; T = -inf;
ch = findall(ax);
for k = 1:numel(ch)
    ty = get(ch(k), 'Type');
    switch ty
        case 'text'
            if isempty(get(ch(k), 'String')), continue; end
            e = get(ch(k), 'Extent');
            X = [e(1) e(1) + e(3)]; Y = [e(2) e(2) + e(4)];
        case {'line', 'patch'}
            X = get(ch(k), 'XData'); Y = get(ch(k), 'YData');
        otherwise, continue;
    end
    X = X(isfinite(X)); Y = Y(isfinite(Y));
    if isempty(X), continue; end
    L = min(L, min(X)); R = max(R, max(X)); B = min(B, min(Y)); T = max(T, max(Y));
end
m = o.Margin; xl = get(ax, 'XLim'); yl = get(ax, 'YLim');
if any(strcmpi(o.Axis, {'y', 'both'})), yl = [B - m, T + m]; end
if any(strcmpi(o.Axis, {'x', 'both'})), xl = [L - m, R + m]; end
w = diff(xl); h = diff(yl);
set(ax, 'XLim', xl, 'YLim', yl);
p = get(fig, 'Position'); set(fig, 'Position', [p(1) p(2) w h]);
set(fig, 'PaperSize', [w h], 'PaperPosition', [0 0 w h]);
setappdata(ax, 'pd_size', [w h]);
sz = [w h];
fprintf('pd_trim: canvas is now %.2f x %.2f cm\n', w, h);
end
