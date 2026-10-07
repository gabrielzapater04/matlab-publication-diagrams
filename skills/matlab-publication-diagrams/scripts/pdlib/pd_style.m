function S = pd_style(preset, varargin)
%PD_STYLE Publication style: fonts, line weights, sizes and color roles.
%   S = pd_style()                 generic journal style (8 pt Helvetica)
%   S = pd_style('ieee')           IEEE Transactions / Access
%   S = pd_style('elsevier')       Elsevier (Minerals Eng., Powder Tech., ...)
%   S = pd_style('springer')       Springer / Nature-family single column
%   S = pd_style('acs')            ACS journals
%   S = pd_style('mdpi')           MDPI (Minerals, Processes, ...)
%   S = pd_style('thesis')         A4 thesis / report
%   S = pd_style('slides')         presentations & posters (larger text)
%   S = pd_style(preset, 'Palette','gray', 'Font','Arial', 'FontSize',9)
%
%   All lengths are in centimetres, font sizes and line widths in points.
%   Because pd_figure maps 1 data unit = 1 cm, what you set here is what
%   is printed at 100 % in the journal.
%
%   Column widths are typical values -- ALWAYS confirm with the target
%   journal's current "Guide for Authors" before final submission.

if nargin < 1 || isempty(preset), preset = 'default'; end
S.name = lower(preset);

% ---- base (generic journal) --------------------------------------------
S.font          = 'Helvetica';
S.fontSize      = 8;      % body text inside nodes
S.fontSizeSmall = 7;      % edge labels, tags, annotations
S.fontSizeTitle = 9;      % group / panel titles
S.minFontSize   = 6;      % pd_check warns below this
S.lineWidth     = 0.75;   % node outlines and connectors (pt)
S.lineWidthThin = 0.5;    % secondary lines, NN edges, signals
S.lineWidthThick= 1.5;    % main process streams / pipes
S.arrowLength   = 0.20;   % cm
S.arrowWidth    = 0.14;   % cm
S.nodeW         = 2.8;    % default node width  (cm)
S.nodeH         = 0.9;    % default node height (cm)
S.corner        = 0.12;   % rounded-corner radius (cm)
S.pad           = 0.30;   % group padding (cm)
S.interpreter   = 'tex';
S.colWidth      = 8.5;    % single column (cm)
S.midWidth      = 12.5;   % 1.5 column (cm)
S.twoColWidth   = 17.5;   % double column (cm)
S.maxHeight     = 23.0;   % max figure height (cm)
S.palette       = 'okabe-ito';

switch S.name
    case 'default'
    case 'ieee'
        S.colWidth = 8.89; S.twoColWidth = 18.13; S.midWidth = 12.5;
        S.font = 'Helvetica'; S.fontSize = 8; S.fontSizeSmall = 7;
    case 'elsevier'
        S.colWidth = 9.0; S.midWidth = 14.0; S.twoColWidth = 19.0;
        S.font = 'Arial'; S.fontSize = 8; S.fontSizeSmall = 7;
    case 'springer'
        S.colWidth = 8.4; S.midWidth = 12.9; S.twoColWidth = 17.4;
        S.font = 'Helvetica'; S.fontSize = 8; S.fontSizeSmall = 7;
    case 'acs'
        S.colWidth = 8.25; S.midWidth = 12.7; S.twoColWidth = 17.78;
        S.font = 'Helvetica'; S.fontSize = 7; S.fontSizeSmall = 6;
        S.fontSizeTitle = 8; S.minFontSize = 4.5;
    case 'mdpi'
        S.colWidth = 8.5; S.midWidth = 13.0; S.twoColWidth = 16.0;
        S.font = 'Palatino Linotype'; S.fontSize = 8; S.fontSizeSmall = 7;
    case 'thesis'
        S.colWidth = 15.0; S.midWidth = 15.0; S.twoColWidth = 15.0;
        S.font = 'Helvetica'; S.fontSize = 9; S.fontSizeSmall = 8;
        S.fontSizeTitle = 10; S.nodeW = 3.2; S.nodeH = 1.0;
    case {'slides', 'poster'}
        S.colWidth = 25; S.midWidth = 25; S.twoColWidth = 33.8; S.maxHeight = 19;
        S.font = 'Helvetica'; S.fontSize = 16; S.fontSizeSmall = 13;
        S.fontSizeTitle = 18; S.minFontSize = 12;
        S.lineWidth = 1.5; S.lineWidthThin = 1; S.lineWidthThick = 2.5;
        S.arrowLength = 0.40; S.arrowWidth = 0.28;
        S.nodeW = 5.5; S.nodeH = 1.8; S.corner = 0.25; S.pad = 0.5;
    otherwise
        error('pd:style', 'Unknown preset "%s".', preset);
end

% ---- user overrides (any field above, case-insensitive) ----------------
if ~isempty(varargin)
    S = pd_opts(S, varargin{:});
end
S = local_colors(S);
end

% ========================================================================
function S = local_colors(S)
% Neutral inks
S.textColor = [0.10 0.10 0.10];
S.edgeColor = [0.15 0.15 0.15];
S.lineColor = [0.15 0.15 0.15];
S.mutedColor = [0.55 0.55 0.55];
S.groupEdge = [0.45 0.45 0.45];
S.groupFill = [0.965 0.965 0.965];

switch lower(S.palette)
    case {'okabe-ito', 'okabeito', 'cb'}
        % Okabe & Ito (2008) colour-blind-safe palette
        base = [  0 114 178;   % 1 blue
                230 159   0;   % 2 orange
                  0 158 115;   % 3 bluish green
                204 121 167;   % 4 reddish purple
                 86 180 233;   % 5 sky blue
                213  94   0;   % 6 vermillion
                240 228  66;   % 7 yellow
                 90  90  90] / 255;   % 8 grey
        tint = 0.80;
    case {'gray', 'grey', 'grayscale'}
        base = repmat([0.20; 0.35; 0.45; 0.55; 0.30; 0.40; 0.60; 0.50], 1, 3);
        tint = 0.75;
    case {'tol', 'tol-muted'}
        % Paul Tol "muted" scheme (colour-blind safe)
        base = [ 51  34 136;  204 102 119;  17 119  51;  136  34  85;
                136 204 238;   68 170 153; 221 204 119;  170 170 170] / 255;
        tint = 0.78;
    otherwise
        error('pd:style', 'Unknown palette "%s".', S.palette);
end
S.colors = base;
S.fills  = base + (1 - base) * tint;   % light tints for node fills
S.fills(7, :) = base(7, :) + (1 - base(7, :)) * 0.60; % yellow needs less tint

% ---- semantic roles: use the SAME role for the same concept in every
%      figure of the paper so colour carries meaning consistently -------
r = struct();
r.process   = 1;  % generic process step / unit operation
r.model     = 2;  % ML model, surrogate, predictor
r.optim     = 3;  % optimizer, controller, decision logic
r.decision  = 7;  % flowchart decision
r.data      = 5;  % data, database, dataset, sensor stream
r.io        = 4;  % input / output, user, external system
r.output    = 6;  % result, KPI, final output
r.highlight = 6;  % the element the reader must notice
r.neutral   = 8;  % auxiliary blocks
S.roleIndex = r;
end
