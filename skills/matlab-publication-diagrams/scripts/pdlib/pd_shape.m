function [px, py, extra] = pd_shape(shape, x, y, w, h, r)
%PD_SHAPE Outline polygon (column vectors) for a node shape.
%   extra: cell of {xline, yline} decorations drawn as lines on top
%   (e.g. the inner lip of a database cylinder).
%
%   Shapes (ISO 5807 flowchart names in brackets):
%     'process' [process]      'rounded'            'terminal' [terminator]
%     'decision' [decision]    'io' [data]          'database' [stored data]
%     'document' [document]    'predefined' [predefined process]
%     'hexagon' [preparation]  'ellipse' | 'circle' 'note' (folded corner)
%     'stack' (drawn by pd_node as 3 offset rounded boxes)
if nargin < 6 || isempty(r), r = 0.12; end
extra = {};
L = x - w/2; R = x + w/2; B = y - h/2; T = y + h/2;
switch lower(shape)
    case {'process', 'rect', 'box'}
        px = [L R R L]'; py = [B B T T]';
    case {'rounded', 'stack'}
        [px, py] = rrect(L, B, w, h, min(r, min(w, h)/2));
    case {'terminal', 'stadium', 'pill'}
        [px, py] = rrect(L, B, w, h, h/2);
    case {'decision', 'diamond'}
        px = [x R x L]'; py = [B y T y]';
    case {'io', 'data', 'parallelogram'}
        s = min(0.25*w, 0.35*h);
        px = [L R-s R L+s]'; py = [B B T T]';
    case {'hexagon', 'preparation'}
        s = min(0.2*w, 0.4*h);
        px = [L+s R-s R R-s L+s L]'; py = [B B y T T y]';
    case {'ellipse', 'circle', 'oval'}
        t = linspace(0, 2*pi, 97)'; t(end) = [];
        px = x + w/2*cos(t); py = y + h/2*sin(t);
    case {'database', 'cylinder'}
        ry = min(0.14*h, 0.18*w);
        t = linspace(pi, 2*pi, 40)';
        xb = x + w/2*cos(t); yb = (B + ry) + ry*sin(t);       % bottom arc
        t2 = linspace(0, pi, 40)';
        xt = x + w/2*cos(t2); yt = (T - ry) + ry*sin(t2);     % top arc
        px = [xb; xt]; py = [yb; yt];
        t3 = linspace(pi, 2*pi, 40)';
        extra = {x + w/2*cos(t3), (T - ry) + ry*sin(t3)};    % inner lip
    case 'document'
        a = 0.08*h;
        xs = linspace(R, L, 40)';
        ys = B + a*sin(2*pi*(xs - L)/w);
        px = [xs; L; R]; py = [ys; T; T];
    case {'predefined', 'subroutine'}
        px = [L R R L]'; py = [B B T T]';
        d = min(0.1*w, 0.25);
        extra = {[L+d L+d NaN R-d R-d]', [B T NaN B T]'};
    case 'note'
        c = min(0.25*h, 0.25);
        px = [L R R R-c L]'; py = [B B T-c T T]';
        extra = {[R-c R-c R]', [T T-c T-c]'};
    otherwise
        error('pd:shape', 'Unknown shape "%s".', shape);
end
end

function [px, py] = rrect(L, B, w, h, r)
n = 10;
if r <= 0
    px = [L L+w L+w L]'; py = [B B B+h B+h]'; return;
end
c = [L+w-r B+r; L+w-r B+h-r; L+r B+h-r; L+r B+r];
a0 = [-pi/2 0 pi/2 pi];
px = []; py = [];
for k = 1:4
    t = linspace(a0(k), a0(k) + pi/2, n)';
    px = [px; c(k,1) + r*cos(t)]; %#ok<AGROW>
    py = [py; c(k,2) + r*sin(t)]; %#ok<AGROW>
end
end
