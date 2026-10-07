function [p, dir] = pd_anchor(N, spec, offset)
%PD_ANCHOR Point on a node's boundary (and the direction a line leaves it).
%   p = pd_anchor(N, 'E')          east side midpoint
%   p = pd_anchor(N, 'N', 0.5)     north side, shifted +50 % of half-width
%   p = pd_anchor(N, 'overflow')   named port of an equipment symbol
%   p = pd_anchor([x y])           a bare point passes through
%
%   spec: 'N','S','E','W','NE','NW','SE','SW','C' or a port name.
%   offset (-1..1) slides the point along N/S (in x) or E/W (in y) sides,
%   which lets several arrows enter the same side without overlapping.
%   dir: 'N','S','E','W' (exit direction) or '' when undefined.
if nargin < 3 || isempty(offset), offset = 0; end
if isnumeric(N)
    p = N(:)'; dir = ''; return;
end
if nargin < 2 || isempty(spec), spec = 'C'; end
if isnumeric(spec), p = spec(:)'; dir = ''; return; end

% named ports (equipment) ------------------------------------------------
pn = fieldnames(N.ports);
k = find(strcmpi(pn, spec), 1);
if ~isempty(k)
    p = N.ports.(pn{k});
    dir = '';
    if isfield(N.portdir, pn{k}), dir = N.portdir.(pn{k}); end
    return;
end

x = N.x; y = N.y; w = N.w; h = N.h; t = offset;
sh = N.shape;
isEll = any(strcmp(sh, {'ellipse', 'circle', 'oval'}));
isDia = any(strcmp(sh, {'decision', 'diamond'}));
isPar = any(strcmp(sh, {'io', 'data', 'parallelogram'}));
s = min(0.25*w, 0.35*h);
dir = upper(spec);
if strcmp(sh, 'stack')   % copies sit up-right: N/E leave from the back copy
    d = 2*(0.08 + 0.02*w);
    switch upper(spec)
        case 'N', p = [x + t*w/2, y + h/2 + d]; return;
        case 'E', p = [x + w/2 + d, y + t*h/2]; return;
    end
end
switch upper(spec)
    case 'C', p = [x y]; dir = '';
    case 'N'
        if isEll,     p = [x + t*w/2, y + h/2*sqrt(max(0, 1 - t^2))];
        elseif isDia, p = [x + t*w/2, y + h/2*(1 - abs(t))];
        elseif isPar, p = [x + t*(w/2 - s), y + h/2];
        else,         p = [x + t*w/2, y + h/2];
        end
    case 'S'
        if isEll,     p = [x + t*w/2, y - h/2*sqrt(max(0, 1 - t^2))];
        elseif isDia, p = [x + t*w/2, y - h/2*(1 - abs(t))];
        elseif isPar, p = [x + t*(w/2 - s), y - h/2];
        else,         p = [x + t*w/2, y - h/2];
        end
    case 'E'
        if isEll,     p = [x + w/2*sqrt(max(0, 1 - t^2)), y + t*h/2];
        elseif isDia, p = [x + w/2*(1 - abs(t)), y + t*h/2];
        elseif isPar, p = [x + w/2 - s*(1 - t)/2, y + t*h/2];
        else,         p = [x + w/2, y + t*h/2];
        end
    case 'W'
        if isEll,     p = [x - w/2*sqrt(max(0, 1 - t^2)), y + t*h/2];
        elseif isDia, p = [x - w/2*(1 - abs(t)), y + t*h/2];
        elseif isPar, p = [x - w/2 + s*(1 + t)/2, y + t*h/2];
        else,         p = [x - w/2, y + t*h/2];
        end
    case {'NE', 'NW', 'SE', 'SW'}
        sx = 1; if any(upper(spec) == 'W'), sx = -1; end
        sy = 1; if upper(spec(1)) == 'S', sy = -1; end
        if isEll,     p = [x + sx*w/2*cos(pi/4), y + sy*h/2*sin(pi/4)];
        elseif isDia, p = [x + sx*w/4, y + sy*h/4];
        else,         p = [x + sx*w/2, y + sy*h/2];
        end
        dir = '';
    otherwise
        error('pd:anchor', 'Unknown anchor/port "%s". Ports here: %s', ...
            spec, strjoin(pn', ', '));
end
end
