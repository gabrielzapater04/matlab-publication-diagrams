function Ns = pd_layers(x0, y0, spec, varargin)
%PD_LAYERS Block diagram of a model architecture (layer by layer).
%   Ns = pd_layers(x0, y0, spec)          (x0,y0) = centre of first block
%   spec: N x 2 cell {label, type}; label can be a cell for 2 lines.
%     spec = {'Input (12)',          'input'
%             {'Dense 64','ReLU'},   'dense'
%             'Dropout 0.2',         'dropout'
%             {'LSTM','128 units'},  'rnn'
%             'Output (2)',          'output'};
%   Types -> colour role: input/embed (data), dense/conv/rnn/lstm/gru/
%   attention/transformer (model), pool/norm/dropout/activation (neutral),
%   concat/add (optim), output/loss (output), anything else: process.
%
%   Options
%     'Direction' 'right' | 'down' | 'up' | 'left'   ('right')
%     'W','H'     block size (default 1.6 x 1.0 for right, 3.0 x 0.6 for down)
%     'Gap'       space between blocks (0.45)
%     'Rotated'   true -> tall thin blocks with vertical text (Direction right)
%     'Arrows'    true
%   Returns a struct array of nodes (one per block) for further wiring,
%   e.g. skip connections: pd_connect(Ns(2), Ns(4), 'From','N','To','N').
S = pd_getstyle();
o = pd_opts(struct('Direction', 'right', 'W', [], 'H', [], 'Gap', 0.45, ...
    'Rotated', false, 'Arrows', true, 'FontSize', S.fontSizeSmall, ...
    'Parent', gca), varargin{:});
horiz = any(strcmpi(o.Direction, {'right', 'left'}));
if isempty(o.W) || isempty(o.H)
    if o.Rotated,  W = 0.75; H = 3.0;
    elseif horiz,  W = 1.6;  H = 1.0;
    else,          W = 3.0;  H = 0.6;
    end
    if ~isempty(o.W), W = o.W; end
    if ~isempty(o.H), H = o.H; end
else
    W = o.W; H = o.H;
end
switch lower(o.Direction)
    case 'right', step = [W + o.Gap, 0];
    case 'left',  step = [-(W + o.Gap), 0];
    case 'down',  step = [0, -(H + o.Gap)];
    case 'up',    step = [0, H + o.Gap];
    otherwise, error('pd:layers', 'Unknown Direction "%s".', o.Direction);
end
rot = 0; if o.Rotated, rot = 90; end
n = size(spec, 1);
for k = 1:n
    p = [x0 y0] + (k-1)*step;
    Ns(k) = pd_node(p(1), p(2), spec{k, 1}, 'W', W, 'H', H, ...
        'Role', local_role(spec{k, 2}), 'FontSize', o.FontSize, ...
        'Rotation', rot, 'Parent', o.Parent); %#ok<AGROW>
end
if o.Arrows
    for k = 1:n-1
        pd_connect(Ns(k), Ns(k+1), 'Parent', o.Parent);
    end
end
end

function r = local_role(t)
switch lower(t)
    case {'input', 'embed', 'embedding', 'data'},                        r = 'data';
    case {'dense', 'fc', 'linear', 'conv', 'conv1d', 'conv2d', 'rnn', ...
          'lstm', 'gru', 'attention', 'transformer', 'model', 'tree'},   r = 'model';
    case {'pool', 'maxpool', 'norm', 'batchnorm', 'layernorm', ...
          'dropout', 'activation', 'flatten', 'reshape'},              r = 'neutral';
    case {'concat', 'add', 'merge', 'optim'},                            r = 'optim';
    case {'output', 'loss', 'softmax', 'head'},                          r = 'output';
    otherwise,                                                           r = 'process';
end
end
