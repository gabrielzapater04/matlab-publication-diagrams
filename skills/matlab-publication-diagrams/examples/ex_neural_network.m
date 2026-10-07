%% ex_neural_network.m -- Neural-network figures in three styles (panels a-c)
% (a) neuron-level MLP (pd_nn), (b) layer-block architecture (pd_layers)
% with a residual connection, (c) CNN feature maps as cuboids (pd_box3d).
% Pattern shown: multi-panel figure with bold (a)/(b)/(c) labels.
S = pd_style('ieee');
[fig, ax] = pd_figure('double', 9.6, S);           % 18.13 x 9.6 cm

% (a) MLP ------------------------------------------------------------------
pd_text(0.15, 9.45, '(a)', 'FontWeight','bold', 'HA','left', 'VA','top');
pd_nn(1.6, 6.3, [5 64 64 2], 'MaxShow', 7, 'DX', 1.7, 'DY', 0.42, ...
    'LayerLabels', {'Input','Hidden 1','Hidden 2','Output'}, ...
    'InputLabels', {'x_1','x_2','x_3','x_4','x_5'}, 'OutputLabels', {'y_1','y_2'});
pd_text(4.15, 8.9, 'ReLU', 'FontSize',S.fontSizeSmall, 'FontAngle','italic');

% (b) layer blocks ---------------------------------------------------------
pd_text(8.4, 9.45, '(b)', 'FontWeight','bold', 'HA','left', 'VA','top');
spec = {'Input  (T \times 8)', 'input'
        {'LSTM','64 units'},   'lstm'
        'LayerNorm',           'norm'
        {'LSTM','64 units'},   'lstm'
        'Add',                 'add'
        {'Dense','32, ReLU'},  'dense'
        'Output  (2)',         'output'};
L = pd_layers(10.2, 8.6, spec, 'Direction','down', 'W',3.0, 'H',0.62, 'Gap',0.32);
pd_connect(L(2), L(5), 'From','E', 'To','E', 'Type','feedback', 'Detour',0.55, ...
    'Label','residual', 'LabelSide','right');
pd_text(13.3, 5.6, {'Dropout 0.2','after each','LSTM'}, 'FontSize',S.fontSizeSmall, ...
    'HA','left', 'Color',S.mutedColor);

% (c) CNN ------------------------------------------------------------------
pd_text(0.15, 3.1, '(c)', 'FontWeight','bold', 'HA','left', 'VA','top');
b1 = pd_box3d(1.2, 1.5, 0.22, 2.0, 2.0, 'Role','data',  'Dims',{'64','','3'},  'Label','Input');
b2 = pd_box3d(3.0, 1.5, 0.45, 1.6, 1.6, 'Role','model', 'Dims',{'32','','16'}, 'Label','Conv 3\times3');
b3 = pd_box3d(4.8, 1.5, 0.70, 1.1, 1.1, 'Role','model', 'Dims',{'16','','32'}, 'Label','Conv 3\times3');
b4 = pd_node(6.8, 1.5, {'Global','avg-pool'}, 'W',1.3, 'H',0.8, 'Role','neutral', 'FontSize',S.fontSizeSmall);
b5 = pd_node(8.4, 1.5, 'Softmax', 'W',1.2, 'H',0.8, 'Role','output', 'FontSize',S.fontSizeSmall);
pd_connect(b1, b2); pd_connect(b2, b3); pd_connect(b3, b4); pd_connect(b4, b5);

pd_check(fig);
pd_export(fig, 'ex_neural_network', 'Formats', {'pdf','png'});
