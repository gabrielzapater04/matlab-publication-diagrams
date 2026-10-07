%% ex_ml_optimization.m -- Surrogate-model optimization loop (algorithm figure)
% Generic example: offline training (left) feeds an online optimization
% loop (right) with an explicit iteration arrow and a convergence test.
% Patterns shown: two-column method figure, icons as visual anchors,
% 'stack' shape for ensembles, loop drawn as dashed feedback.
S = pd_style('elsevier');
[fig, ax] = pd_figure('double', 9.0, S);           % 19 x 9 cm

% ---- offline stage -----------------------------------------------------------
o1 = pd_node(2.4, 7.4, {'Historical','plant data'}, 'Shape','database', 'Role','data', 'W',2.6, 'H',1.2);
o2 = pd_node(2.4, 5.6, {'Feature engineering','& selection'}, 'Role','process', 'W',3.2);
o3 = pd_node(2.4, 3.8, {'Ensemble surrogate','f(\bf{x}\rm)'}, 'Shape','stack', 'Role','model', 'W',3.0, 'H',1.0);
o4 = pd_node(2.4, 2.0, {'k-fold CV','(RMSE, R^2)'}, 'Role','neutral', 'W',3.0);
pd_connect(o1, o2); pd_connect(o2, o3); pd_connect(o3, o4);
pd_icon('forest', 4.75, 5.6, 'Size',0.8, 'Role','model', 'Label','RF / GBM');
G1 = pd_group({o1, o2, o3, o4}, 'Title','Offline: model building', 'Pad',[0.35 1.4 0.3 0.2]);

% ---- online stage ------------------------------------------------------------
x0 = 10.6;
n1 = pd_node(x0, 7.6, {'Current operating','point  \bf{x}_0'}, 'Shape','io', 'Role','io', 'W',3.4);
n2 = pd_node(x0, 6.0, {'Candidate generation','(GA / Bayesian opt.)'}, 'Role','optim', 'W',3.6);
n3 = pd_node(x0, 4.4, {'Predict  f(\bf{x}_k\rm)','+ constraints g(\bf{x}_k\rm) \leq 0'}, 'Role','model', 'W',3.8);
n4 = pd_node(x0, 2.6, {'Converged?'}, 'Shape','decision', 'Role','decision', 'W',2.6, 'H',1.1);
n5 = pd_node(x0 + 5.0, 2.6, {'Optimal set-points','\bf{x}^*'}, 'Shape','terminal', 'Role','output', 'W',3.2, 'H',0.8);
pd_connect(n1, n2); pd_connect(n2, n3); pd_connect(n3, n4);
pd_connect(n4, n5, 'From','E', 'Label','Yes', 'LabelPos','start');
pd_connect(n4, n2, 'From','W', 'To','W', 'Type','feedback', 'Detour',1.0, ...
    'Label','No: k \leftarrow k+1', 'LabelPos',0.33, 'LabelSide','left');
pd_icon('optim', x0 + 2.6, 6.0, 'Size',0.8, 'Role','optim');
G2 = pd_group({n1, n2, n3, n4, n5}, 'Title','Online: set-point optimization', 'Pad',[2.35 0.3 0.3 0.2]);

% trained model feeds the online loop
pd_connect(o3, n3, 'From','E', 'To','W', 'Type','data', 'Route','hvh', 'MidAbs', 5.95, ...
    'Label','trained f', 'LabelPos',0.68);

pd_trim(fig);                       % drop empty margin, keep column width
pd_check(fig);
pd_export(fig, 'ex_ml_optimization', 'Formats', {'pdf','png'});
