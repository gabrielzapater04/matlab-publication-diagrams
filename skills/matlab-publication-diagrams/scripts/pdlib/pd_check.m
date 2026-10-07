function R = pd_check(fig, varargin)
%PD_CHECK Pre-submission lint for a pd figure. Prints a report.
%   R = pd_check(fig)
%   R = pd_check(fig, 'Target','single')   also checks the width target
%
%   Checks
%     - font sizes below style minimum (journals reject < 6-7 pt)
%     - text running outside the canvas (would be clipped on export)
%     - overlapping text labels (the #1 defect in generated diagrams)
%     - hairlines thinner than 0.3 pt (~0.1 mm; vanish in print), NN edges excepted
%     - more than 6 distinct hues (visual noise; greys/shades not counted)
%     - figure width vs the style's single / 1.5 / double column widths
%   Returns struct with fields .errors, .warnings, .info (cellstr).
o = pd_opts(struct('Target', '', 'OverlapTol', 0.03, 'MaxReport', 15), varargin{:});
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
S = pd_getstyle(ax);
xl = get(ax, 'XLim'); yl = get(ax, 'YLim'); sz = [diff(xl) diff(yl)];
E = {}; W = {}; I = {};

% ---- text --------------------------------------------------------------------
tx = findall(ax, 'Type', 'text');
keep = true(size(tx));
for k = 1:numel(tx)
    s = get(tx(k), 'String');
    if isempty(s) || strcmp(get(tx(k), 'Tag'), 'pd_grid') || strcmp(get(tx(k), 'Visible'), 'off')
        keep(k) = false;
    end
end
tx = tx(keep);
ext = zeros(numel(tx), 4);
for k = 1:numel(tx)
    fs = get(tx(k), 'FontSize');
    str = local_str(get(tx(k), 'String'));
    if fs < S.minFontSize - 1e-6
        E{end+1} = sprintf('Font %.1f pt < %.1f pt minimum: "%s"', fs, S.minFontSize, str); %#ok<AGROW>
    end
    ext(k, :) = get(tx(k), 'Extent');
    if strcmp(get(tx(k), 'Tag'), 'pd_tagtext')   % include the tag's marker
        ext(k, :) = ext(k, :) + [-0.2 -0.14 0.4 0.28];   % diamond ~0.5 x 0.42 cm
    end
    e = ext(k, :);
    if e(1) < xl(1) - 0.01 || e(2) < yl(1) - 0.01 || e(1) + e(3) > xl(2) + 0.01 || e(2) + e(4) > yl(2) + 0.01
        E{end+1} = sprintf('Text outside canvas (will be clipped): "%s" at [%.2f %.2f]', ...
            str, e(1), e(2)); %#ok<AGROW>
    end
end
nOv = 0; t = o.OverlapTol;
for i = 1:numel(tx)
    for j = i+1:numel(tx)
        a = ext(i, :); b = ext(j, :);
        ox = min(a(1)+a(3), b(1)+b(3)) - max(a(1), b(1));
        oy = min(a(2)+a(4), b(2)+b(4)) - max(a(2), b(2));
        if ox > t && oy > t
            nOv = nOv + 1;
            if nOv <= o.MaxReport
                W{end+1} = sprintf('Overlapping text: "%s"  <->  "%s"', ...
                    local_str(get(tx(i), 'String')), local_str(get(tx(j), 'String'))); %#ok<AGROW>
            end
        end
    end
end
if nOv > o.MaxReport, W{end+1} = sprintf('... %d more overlaps', nOv - o.MaxReport); end

% ---- connectors / frames crossing text --------------------------------------
segs = zeros(0, 4); segName = {};
hl = [findall(ax, 'Tag', 'pd_connector'); findall(ax, 'Tag', 'pd_group'); ...
      findall(ax, 'Tag', 'pd_arrowhead')];
for k = 1:numel(hl)
    X = get(hl(k), 'XData'); Y = get(hl(k), 'YData'); X = X(:); Y = Y(:);
    if any(strcmp(get(hl(k), 'Tag'), {'pd_group', 'pd_arrowhead'})), X(end+1) = X(1); Y(end+1) = Y(1); end %#ok<AGROW>
    for j = 1:numel(X)-1
        if any(isnan([X(j:j+1); Y(j:j+1)])), continue; end
        segs(end+1, :) = [X(j) Y(j) X(j+1) Y(j+1)]; %#ok<AGROW>
        tgk = get(hl(k), 'Tag'); if strcmp(tgk, 'pd_arrowhead'), tgk = 'pd_connector'; end
        segName{end+1} = tgk; %#ok<AGROW>
    end
end
nX = 0;
for i = 1:numel(tx)
    tg = get(tx(i), 'Tag');
    isTitle = strcmp(tg, 'pd_grouptitle');      % titles sit on frames by design
    bg = get(tx(i), 'BackgroundColor');
    if isnumeric(bg) && strcmp(tg, 'pd_edgelabel'), continue; end   % 'on' labels
    e = ext(i, :) + [t t -2*t -2*t];
    for j = 1:size(segs, 1)
        if isTitle && strcmp(segName{j}, 'pd_group'), continue; end
        if local_segbox(segs(j, :), e)
            nX = nX + 1;
            if nX <= o.MaxReport
                what = 'connector'; if strcmp(segName{j}, 'pd_group'), what = 'group frame'; end
                W{end+1} = sprintf('A %s crosses text "%s"', what, local_str(get(tx(i), 'String'))); %#ok<AGROW>
            end
            break;
        end
    end
end

% ---- lines -----------------------------------------------------------------
ln = [findall(ax, 'Type', 'line'); findall(ax, 'Type', 'patch')];
thin = 0;
for k = 1:numel(ln)
    tg = get(ln(k), 'Tag');
    if any(strcmp(tg, {'pd_grid', 'pd_nnedge', 'pd_arrowhead'})), continue; end
    if strcmp(get(ln(k), 'Type'), 'patch')
        ec = get(ln(k), 'EdgeColor');
        if ischar(ec) && strcmp(ec, 'none'), continue; end
    end
    if get(ln(k), 'LineWidth') < 0.3 - 1e-6, thin = thin + 1; end
end
if thin > 0
    W{end+1} = sprintf('%d line(s) thinner than 0.3 pt (~0.1 mm, below most journals'' minimum).', thin);
end

% ---- colours ---------------------------------------------------------------
P = findall(ax, 'Type', 'patch'); cols = zeros(0, 3);
for k = 1:numel(P)
    fc = get(P(k), 'FaceColor');
    if strcmp(get(P(k), 'Tag'), 'pd_group'), continue; end
    if isnumeric(fc) && numel(fc) == 3
        hsv = rgb2hsv(fc(:)');
        if hsv(2) > 0.10              % ignore greys/white; shades share a hue
            cols(end+1, :) = [round(hsv(1)*24) 0 0]; %#ok<AGROW>
        end
    end
end
nc = size(unique(cols, 'rows'), 1);
if nc > 6
    W{end+1} = sprintf('%d distinct hues: consider fewer semantic roles (<= 6).', nc);
end
I{end+1} = sprintf('Canvas %.2f x %.2f cm; %d text objects; %d hues.', sz(1), sz(2), numel(tx), nc);

% ---- width target ------------------------------------------------------------
cands = [S.colWidth S.midWidth S.twoColWidth]; names = {'single', '1.5', 'double'};
if ~isempty(o.Target)
    idx = find(strcmpi(names, o.Target) | strcmpi({'single','mid','double'}, o.Target), 1);
    if ~isempty(idx) && abs(sz(1) - cands(idx)) > 0.05*cands(idx)
        W{end+1} = sprintf('Width %.2f cm differs from %s-column %.2f cm (%s).', ...
            sz(1), names{idx}, cands(idx), S.name);
    end
elseif sz(1) > S.twoColWidth + 0.05
    E{end+1} = sprintf('Width %.2f cm exceeds double column %.2f cm: it will be downscaled.', ...
        sz(1), S.twoColWidth);
end

% ---- report ------------------------------------------------------------------
R = struct('errors', {E}, 'warnings', {W}, 'info', {I});
fprintf('\n== pd_check (%s style) ==\n', S.name);
for k = 1:numel(I), fprintf('  info : %s\n', I{k}); end
for k = 1:numel(E), fprintf('  ERROR: %s\n', E{k}); end
for k = 1:numel(W), fprintf('  warn : %s\n', W{k}); end
if isempty(E) && isempty(W), fprintf('  OK: no issues found.\n'); end
fprintf('\n');
end

function hit = local_segbox(sg, e)
% true if segment sg=[x1 y1 x2 y2] intersects box e=[x y w h] (Liang-Barsky)
x1 = sg(1); y1 = sg(2); dx = sg(3) - x1; dy = sg(4) - y1;
p = [-dx dx -dy dy]; q = [x1 - e(1), e(1) + e(3) - x1, y1 - e(2), e(2) + e(4) - y1];
u0 = 0; u1 = 1; hit = true;
for k = 1:4
    if abs(p(k)) < 1e-12
        if q(k) < 0, hit = false; return; end
    else
        r = q(k) / p(k);
        if p(k) < 0, u0 = max(u0, r); else, u1 = min(u1, r); end
        if u0 > u1, hit = false; return; end
    end
end
end

function s = local_str(s)
if iscell(s), s = strjoin(s(:)', ' / '); end
if size(s, 1) > 1, s = strjoin(cellstr(s)', ' / '); end
if numel(s) > 40, s = [s(1:37) '...']; end
end
