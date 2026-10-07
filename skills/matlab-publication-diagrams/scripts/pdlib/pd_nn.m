function NN = pd_nn(x0, y0, sizes, varargin)
%PD_NN Fully-connected neural network (neurons + weights) diagram.
%   NN = pd_nn(x0, y0, [5 16 16 1])
%   NN = pd_nn(2, 4, [4 32 32 2], 'MaxShow', 6, ...
%        'LayerLabels', {'Input','Hidden 1','Hidden 2','Output'}, ...
%        'InputLabels', {'Q','P','\rho_s','d_a'}, 'OutputLabels', {'P_{80}','R_f'})
%
%   (x0, y0): centre of the FIRST layer (x) and vertical centre (y), cm.
%   Layers larger than MaxShow are truncated with a vertical ellipsis and
%   (if 'Counts' is true) annotated with their true size, e.g. "(32)".
%
%   Options
%     'DX' layer spacing (1.6)       'DY' neuron spacing (0.55)
%     'R'  neuron radius (0.15)      'MaxShow' neurons drawn per layer (7)
%     'LayerLabels'  cell, one per layer (drawn below)
%     'LayerRoles'   cell of roles, e.g. {'data','model','model','output'}
%     'InputLabels','OutputLabels'  cell of per-neuron labels
%     'Counts'       true -> "(n)" under truncated layers
%     'EdgeColor'    ([0.7 0.7 0.7]) 'EdgeWidth' (0.35 pt)
%     'Bias'         true -> bias unit "+1" above each non-output layer
%   Returns node struct (bounding box) with extra field .centers{l} (Nx2).
S = pd_getstyle();
o = pd_opts(struct('DX', 1.6, 'DY', 0.55, 'R', 0.15, 'MaxShow', 7, ...
    'LayerLabels', {{}}, 'LayerRoles', {{}}, 'InputLabels', {{}}, ...
    'OutputLabels', {{}}, 'Counts', true, 'EdgeColor', [0.72 0.72 0.72], ...
    'EdgeWidth', 0.35, 'Bias', false, 'FontSize', S.fontSizeSmall, ...
    'Parent', gca), varargin{:});
ax = o.Parent; nL = numel(sizes);
roles = o.LayerRoles;
if isempty(roles)
    roles = repmat({'model'}, 1, nL); roles{1} = 'data'; roles{end} = 'output';
end

% ---- neuron positions -----------------------------------------------------
C = cell(1, nL); gaps = zeros(1, nL);
for l = 1:nL
    n = sizes(l); shown = min(n, o.MaxShow);
    x = x0 + (l-1)*o.DX;
    if n > o.MaxShow
        top = ceil((o.MaxShow - 1)/2);
        slots = shown + 1;                      % one slot for the ellipsis
        ys = y0 + ((slots-1)/2 - (0:slots-1))*o.DY;
        gaps(l) = ys(top + 1);
        ys(top + 1) = [];
        C{l} = [repmat(x, numel(ys), 1), ys(:)];
    else
        ys = y0 + ((n-1)/2 - (0:n-1))*o.DY;
        C{l} = [repmat(x, n, 1), ys(:)];
        gaps(l) = NaN;
    end
end

h = pd_hempty();
% ---- weights (drawn first so they sit behind neurons) --------------------
for l = 1:nL-1
    A = C{l}; B = C{l+1};
    X = []; Y = [];
    for i = 1:size(A, 1)
        for j = 1:size(B, 1)
            X = [X; A(i,1); B(j,1); NaN]; Y = [Y; A(i,2); B(j,2); NaN]; %#ok<AGROW>
        end
    end
    h(end+1) = line(X, Y, 'Color', o.EdgeColor, 'LineWidth', o.EdgeWidth, ...
        'Parent', ax, 'Tag', 'pd_nnedge'); %#ok<AGROW>
end
% ---- neurons --------------------------------------------------------------
t = linspace(0, 2*pi, 49)'; t(end) = [];
for l = 1:nL
    [f, e] = pd_rolecolor(S, roles{l});
    for i = 1:size(C{l}, 1)
        h(end+1) = pd_patch(C{l}(i,1) + o.R*cos(t), C{l}(i,2) + o.R*sin(t), f, ...
            'EdgeColor', e, 'LineWidth', S.lineWidthThin, 'Parent', ax); %#ok<AGROW>
    end
    if ~isnan(gaps(l))                          % vertical ellipsis
        for d = [-1 0 1]
            h(end+1) = pd_patch(C{l}(1,1) + 0.03*cos(t), gaps(l) + d*o.DY*0.22 + 0.03*sin(t), ...
                S.textColor, 'EdgeColor', 'none', 'Parent', ax); %#ok<AGROW>
        end
    end
    if o.Bias && l < nL
        yb = max(C{l}(:,2)) + o.DY*1.1;
        h(end+1) = pd_patch(C{l}(1,1) + o.R*cos(t), yb + o.R*sin(t), [1 1 1], ...
            'EdgeColor', S.mutedColor, 'LineStyle', '--', 'LineWidth', S.lineWidthThin, 'Parent', ax); %#ok<AGROW>
        h(end+1) = text(C{l}(1,1), yb, '+1', 'FontSize', o.FontSize - 1, 'FontName', S.font, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Parent', ax); %#ok<AGROW>
    end
end
% ---- labels -----------------------------------------------------------------
yMin = inf; yMax = -inf;
for l = 1:nL, yMin = min(yMin, min(C{l}(:,2))); yMax = max(yMax, max(C{l}(:,2))); end
if o.Bias, yMax = yMax + o.DY*1.1; end
yLab = yMin - o.R - 0.18;
for l = 1:nL
    xl = C{l}(1,1); str = '';
    if numel(o.LayerLabels) >= l, str = o.LayerLabels{l}; end
    if o.Counts && sizes(l) > o.MaxShow
        cnt = sprintf('(%d)', sizes(l));
        if isempty(str), str = cnt; elseif iscell(str), str{end+1} = cnt; else, str = {str, cnt}; end
    end
    if ~isempty(str)
        h(end+1) = text(xl, yLab, str, 'Parent', ax, 'FontName', S.font, ...
            'FontSize', o.FontSize, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'top', 'Color', S.textColor, ...
            'Interpreter', S.interpreter, 'Tag', 'pd_nnlabel'); %#ok<AGROW>
    end
end
xMin = C{1}(1,1) - o.R; xMax = C{end}(1,1) + o.R;
if ~isempty(o.InputLabels)
    for i = 1:min(numel(o.InputLabels), size(C{1}, 1))
        h(end+1) = text(C{1}(i,1) - o.R - 0.12, C{1}(i,2), o.InputLabels{i}, 'Parent', ax, ...
            'FontName', S.font, 'FontSize', o.FontSize, 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'middle', 'Interpreter', S.interpreter, 'Tag', 'pd_nnlabel'); %#ok<AGROW>
    end
    xMin = xMin - 0.9;
end
if ~isempty(o.OutputLabels)
    for i = 1:min(numel(o.OutputLabels), size(C{end}, 1))
        h(end+1) = text(C{end}(i,1) + o.R + 0.12, C{end}(i,2), o.OutputLabels{i}, 'Parent', ax, ...
            'FontName', S.font, 'FontSize', o.FontSize, 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', 'Interpreter', S.interpreter, 'Tag', 'pd_nnlabel'); %#ok<AGROW>
    end
    xMax = xMax + 0.9;
end
B = yMin - o.R; T = yMax + o.R;
nlab = 0;                                     % include layer labels in bbox
for l = 1:nL
    str = ''; if numel(o.LayerLabels) >= l, str = o.LayerLabels{l}; end
    k = ~isempty(str) * (1 + (iscell(str))*(numel(str) - 1));
    k = k + (o.Counts && sizes(l) > o.MaxShow);
    nlab = max(nlab, k);
end
if nlab > 0, B = yLab - nlab*o.FontSize*0.0353*1.25; end
NN = pd_mknode('nn', 'box', (xMin+xMax)/2, (B+T)/2, xMax-xMin, T-B, h, '');
NN.centers = C;
end
