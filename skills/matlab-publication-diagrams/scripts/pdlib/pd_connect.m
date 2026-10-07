function C = pd_connect(A, B, varargin)
%PD_CONNECT Arrow/line between two nodes, ports or points.
%   pd_connect(n1, n2)                         auto sides, auto route
%   pd_connect(n1, n2, 'From','S', 'To','N')
%   pd_connect(dec, n3, 'From','E', 'Label','Yes', 'LabelPos','start')
%   pd_connect(cyc, tank, 'From','underflow', 'To','in', 'Type','pipe')
%   pd_connect(n4, n1, 'From','W','To','W')    feedback loop (auto detour)
%   pd_connect([1 2], [5 2])                   bare points
%
%   Options
%     'From','To'      side ('N','S','E','W','NE',...), port name, or 'auto'
%     'FromOffset','ToOffset'  slide along the side (-1..1)
%     'Route'   'auto'|'straight'|'hv'|'vh'|'hvh'|'vhv'
%     'Mid'     fraction (0..1) for the middle leg of hvh/vhv   (0.5)
%     'MidAbs'  absolute x (hvh) or y (vhv) of the middle leg  ([])
%     'Detour'  clearance (cm) for same-side / backward loops   (0.5)
%     'Via'     Nx2 waypoints -> polyline p1-Via-p2 (full manual control)
%     'Type'    'flow' (default) | 'pipe' (thick process stream) |
%               'signal' (dashed, thin: instrument/control) |
%               'data' (solid thin) | 'optional' (dotted) | 'feedback'
%     'Arrow'   'end'|'start'|'both'|'none'|'mid'
%     'Label'   text; 'LabelPos' 'start'|'mid'|'end'|fraction of length
%     'LabelSide' 'auto'|'above'|'below'|'left'|'right'|'on'
%     'LabelOffset' cm; 'FontSize'; 'Interpreter'
%     'LabelRotation' 0 | 90: 90 runs the label ALONG a vertical leg
%                  (use for long vertical loops at the figure margin)
%     'Color','LineWidth','LineStyle','ArrowSize' (scale factor)
%   Returns struct with .points (polyline) and .handles.
S = pd_getstyle();
o = pd_opts(struct('From', 'auto', 'To', 'auto', 'FromOffset', 0, ...
    'ToOffset', 0, 'Route', 'auto', 'Mid', 0.5, 'MidAbs', [], ...
    'Detour', 0.5, 'Via', [], 'Type', 'flow', 'Arrow', 'end', ...
    'Label', '', 'LabelPos', 'mid', 'LabelSide', 'auto', ...
    'LabelOffset', 0.08, 'LabelRotation', 0, 'FontSize', S.fontSizeSmall, ...
    'Interpreter', S.interpreter, 'Color', [], 'LineWidth', [], ...
    'LineStyle', '', 'ArrowSize', 1, 'Parent', gca), varargin{:});
ax = o.Parent;

% ---- type presets -------------------------------------------------------
lw = S.lineWidth; ls = '-'; col = S.lineColor;
switch lower(o.Type)
    case 'flow'
    case 'pipe',     lw = S.lineWidthThick;
    case 'signal',   lw = S.lineWidthThin; ls = '--';
    case 'data',     lw = S.lineWidthThin;
    case 'optional', lw = S.lineWidthThin; ls = ':';
    case 'feedback', ls = '--';
    otherwise, error('pd:connect', 'Unknown Type "%s".', o.Type);
end
if ~isempty(o.LineWidth), lw = o.LineWidth; end
if ~isempty(o.LineStyle), ls = o.LineStyle; end
if ~isempty(o.Color), col = o.Color; end

% ---- resolve end points -------------------------------------------------
cA = local_center(A); cB = local_center(B);
fromSpec = o.From; toSpec = o.To;
if strcmpi(fromSpec, 'auto'), fromSpec = local_face(cA, cB, A); end
if strcmpi(toSpec, 'auto'),   toSpec   = local_face(cB, cA, B); end
[p1, d1] = pd_anchor(A, fromSpec, o.FromOffset);
[p2, d2] = pd_anchor(B, toSpec, o.ToOffset);
if isempty(d1), d1 = local_dominant(p1, p2); end
if isempty(d2), d2 = local_opposite(local_dominant(p1, p2)); end

% ---- route --------------------------------------------------------------
if ~isempty(o.Via)
    P = [p1; o.Via; p2];
else
    P = local_route(p1, p2, d1, d2, o);
end
P = local_dedup(P);

% ---- arrowheads (line is shortened so the tip is crisp) ----------------
L = S.arrowLength * o.ArrowSize; W = S.arrowWidth * o.ArrowSize;
h = pd_hempty(); Pl = P;
wantEnd   = any(strcmpi(o.Arrow, {'end', 'both'}));
wantStart = any(strcmpi(o.Arrow, {'start', 'both'}));
if wantEnd
    [h(end+1), Pl(end, :)] = local_head(P(end-1, :), P(end, :), L, W, col, ax);
end
if wantStart
    [h(end+1), Pl(1, :)] = local_head(P(2, :), P(1, :), L, W, col, ax);
end
hl = line(Pl(:, 1), Pl(:, 2), 'Color', col, 'LineWidth', lw, ...
    'LineStyle', ls, 'Parent', ax, 'Tag', 'pd_connector');
h = [hl, h];
if strcmpi(o.Arrow, 'mid')
    [q, seg] = local_along(P, 0.5);
    dvec = P(seg+1, :) - P(seg, :); dvec = dvec / norm(dvec);
    h(end+1) = local_head(q - dvec*L/2, q + dvec*L/2, L, W, col, ax);
end

% ---- label --------------------------------------------------------------
if ~isempty(o.Label)
    h(end+1) = local_label(P, o, S, ax);
end
C = struct('points', P, 'handles', h);
end

% ========================================================================
function c = local_center(A)
if isnumeric(A), c = A(:)'; else, c = [A.x A.y]; end
end

function f = local_face(c, other, A)
if isnumeric(A), f = 'C'; return; end
d = other - c;
% scale by node aspect so wide nodes prefer E/W, tall prefer N/S
if abs(d(1))/max(A.w, eps) >= abs(d(2))/max(A.h, eps)
    if d(1) >= 0, f = 'E'; else, f = 'W'; end
else
    if d(2) >= 0, f = 'N'; else, f = 'S'; end
end
end

function d = local_dominant(p1, p2)
v = p2 - p1;
if abs(v(1)) >= abs(v(2))
    if v(1) >= 0, d = 'E'; else, d = 'W'; end
else
    if v(2) >= 0, d = 'N'; else, d = 'S'; end
end
end

function d = local_opposite(d)
switch d
    case 'E', d = 'W'; case 'W', d = 'E';
    case 'N', d = 'S'; case 'S', d = 'N';
end
end

function P = local_route(p1, p2, d1, d2, o)
isH = @(d) any(strcmp(d, {'E', 'W'}));
r = lower(o.Route); tol = 1e-6; dt = o.Detour;
if strcmp(r, 'auto')
    if isH(d1) && isH(d2)
        if abs(p1(2) - p2(2)) < tol && local_forward(p1, p2, d1), r = 'straight';
        else, r = 'hvh'; end
    elseif ~isH(d1) && ~isH(d2)
        if abs(p1(1) - p2(1)) < tol && local_forward(p1, p2, d1), r = 'straight';
        else, r = 'vhv'; end
    elseif isH(d1), r = 'hv';
    else, r = 'vh';
    end
end
switch r
    case 'straight'
        P = [p1; p2];
    case 'hv'
        P = [p1; p2(1) p1(2); p2];
    case 'vh'
        P = [p1; p1(1) p2(2); p2];
    case 'hvh'
        if ~isempty(o.MidAbs), xm = o.MidAbs;
        elseif strcmp(d1, d2)                          % same side loop
            if strcmp(d1, 'E'), xm = max(p1(1), p2(1)) + dt;
            else,               xm = min(p1(1), p2(1)) - dt; end
        elseif ~local_forward(p1, p2, d1)              % backward: 5 legs
            s1 = 1; if strcmp(d1, 'W'), s1 = -1; end
            ym = (p1(2) + p2(2))/2;
            P = [p1; p1(1)+s1*dt p1(2); p1(1)+s1*dt ym; ...
                 p2(1)-s1*dt ym; p2(1)-s1*dt p2(2); p2];
            return;
        else, xm = p1(1) + o.Mid*(p2(1) - p1(1));
        end
        P = [p1; xm p1(2); xm p2(2); p2];
    case 'vhv'
        if ~isempty(o.MidAbs), ym = o.MidAbs;
        elseif strcmp(d1, d2)
            if strcmp(d1, 'N'), ym = max(p1(2), p2(2)) + dt;
            else,               ym = min(p1(2), p2(2)) - dt; end
        elseif ~local_forward(p1, p2, d1)
            s1 = 1; if strcmp(d1, 'S'), s1 = -1; end
            xm = (p1(1) + p2(1))/2;
            P = [p1; p1(1) p1(2)+s1*dt; xm p1(2)+s1*dt; ...
                 xm p2(2)-s1*dt; p2(1) p2(2)-s1*dt; p2];
            return;
        else, ym = p1(2) + o.Mid*(p2(2) - p1(2));
        end
        P = [p1; p1(1) ym; p2(1) ym; p2];
    otherwise
        error('pd:connect', 'Unknown Route "%s".', o.Route);
end
end

function tf = local_forward(p1, p2, d1)
v = p2 - p1;
switch d1
    case 'E', tf = v(1) > -1e-9;
    case 'W', tf = v(1) <  1e-9;
    case 'N', tf = v(2) > -1e-9;
    case 'S', tf = v(2) <  1e-9;
    otherwise, tf = true;
end
end

function P = local_dedup(P)
keep = [true; any(abs(diff(P, 1, 1)) > 1e-9, 2)];
P = P(keep, :);
% drop collinear interior points
k = 2;
while k < size(P, 1)
    a = P(k, :) - P(k-1, :); b = P(k+1, :) - P(k, :);
    if abs(a(1)*b(2) - a(2)*b(1)) < 1e-9 && dot(a, b) > 0
        P(k, :) = [];
    else
        k = k + 1;
    end
end
end

function [hp, base] = local_head(from, tip, L, W, col, ax)
v = tip - from; n = norm(v);
if n < eps, v = [1 0]; else, v = v / n; end
L = min(L, 0.9*max(n, L));
base = tip - v*L; nrm = [-v(2) v(1)];
X = [tip; base + nrm*W/2; base - nrm*W/2];
hp = pd_patch(X(:, 1), X(:, 2), col, 'EdgeColor', col, 'LineWidth', 0.3, ...
    'Parent', ax, 'Tag', 'pd_arrowhead');
base = tip - v*L*0.8;   % overlap slightly with the head -> no gap
end

function [q, seg] = local_along(P, f)
d = sqrt(sum(diff(P, 1, 1).^2, 2)); cs = [0; cumsum(d)];
t = f * cs(end);
seg = find(cs <= t, 1, 'last'); seg = min(seg, numel(d));
u = (t - cs(seg)) / max(d(seg), eps);
q = P(seg, :) + u*(P(seg+1, :) - P(seg, :));
end

function ht = local_label(P, o, S, ax)
d = sqrt(sum(diff(P, 1, 1).^2, 2)); total = sum(d);
lp = o.LabelPos;
if ischar(lp)
    switch lower(lp)
        case 'start', lp = min(0.35, 0.4*total) / total;
        case 'end',   lp = 1 - min(0.45, 0.4*total) / total;
        case 'mid',   lp = 0.5;
    end
end
[q, seg] = local_along(P, lp);
v = P(seg+1, :) - P(seg, :);
horiz = abs(v(1)) >= abs(v(2));
side = lower(o.LabelSide);
if strcmp(side, 'auto')
    if horiz, side = 'above'; else, side = 'right'; end
end
off = o.LabelOffset; ha = 'center'; va = 'middle'; bg = 'none';
if o.LabelRotation == 90                      % text runs along a vertical leg
    switch side
        case {'left', 'above'}, q(1) = q(1) - off; va = 'bottom';
        case {'right', 'below'}, q(1) = q(1) + off; va = 'top';
        case 'on', bg = 'w';
    end
    side = 'done';
end
switch side
    case 'above', q(2) = q(2) + off; va = 'bottom';
    case 'below', q(2) = q(2) - off; va = 'top';
    case 'right', q(1) = q(1) + off; ha = 'left';
    case 'left',  q(1) = q(1) - off; ha = 'right';
    case 'on',    bg = 'w';
end
ht = text(q(1), q(2), o.Label, 'Rotation', o.LabelRotation, 'Parent', ax, 'FontName', S.font, ...
    'FontSize', o.FontSize, 'Color', S.textColor, 'Interpreter', o.Interpreter, ...
    'HorizontalAlignment', ha, 'VerticalAlignment', va, ...
    'BackgroundColor', bg, 'Margin', 0.5, 'Tag', 'pd_edgelabel');
end
