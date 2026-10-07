%% ex_flowchart.m -- Algorithm / methodology flowchart (ISO 5807 shapes)
% Generic example: supervised-learning workflow with a decision and a loop.
% Pattern shown: grid-based layout (column/row vectors), roles for colour,
% Yes/No labels at the start of decision branches, a feedback loop.
S = pd_style('elsevier');
[fig, ax] = pd_figure('single', 12.0, S);          % 9.0 x 12.0 cm

cx  = [3.2 7.3];                   % column centres (main flow, side branch)
row = 11.3 - (0:7)*1.45;           % row centres, top to bottom

n(1) = pd_node(cx(1), row(1), 'Start', 'Shape','terminal', 'W',2.0, 'H',0.65);
n(2) = pd_node(cx(1), row(2), {'Raw dataset','(CSV / historian)'}, 'Shape','io', 'Role','data', 'W',3.4);
n(3) = pd_node(cx(1), row(3), {'Cleaning &','outlier removal'}, 'Role','process');
n(4) = pd_node(cx(1), row(4), {'Train / validation','split (80/20)'}, 'Role','process');
n(5) = pd_node(cx(1), row(5), 'Train model', 'Role','model');
n(6) = pd_node(cx(1), row(6), {'R^2 \geq 0.9 ?'}, 'Shape','decision', 'Role','decision', 'W',2.8, 'H',1.15);
n(7) = pd_node(cx(1), row(7), 'Trained model', 'Shape','database', 'Role','data', 'W',2.4, 'H',1.0);
n(8) = pd_node(cx(1), row(8), 'End', 'Shape','terminal', 'W',2.0, 'H',0.65);
t    = pd_node(cx(2), row(6), {'Tune','hyper-','parameters'}, 'Role','optim', 'W',2.0, 'H',1.15);

for k = 1:5, pd_connect(n(k), n(k+1)); end
pd_connect(n(6), n(7), 'Label','Yes', 'LabelPos','start');
pd_connect(n(7), n(8));
pd_connect(n(6), t, 'From','E', 'To','W', 'Label','No', 'LabelPos','start');
pd_connect(t, n(5), 'From','N', 'To','E');                     % loop back

pd_check(fig);
pd_export(fig, 'ex_flowchart', 'Formats', {'pdf','png'});
