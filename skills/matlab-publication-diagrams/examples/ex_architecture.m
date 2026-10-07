%% ex_architecture.m -- Layered system / software architecture
% Generic example: data sources -> platform -> ML services -> consumers.
% Patterns shown:
%   * "bus" node: one WIDE node receives many inputs with straight vertical
%     drops (instead of a fan-in that turns into spaghetti);
%   * horizontal lane groups; shared trunk lines (same From point);
%   * a long feedback loop routed AROUND everything with 'Via' waypoints.
S = pd_style('ieee');
[fig, ax] = pd_figure('double', 11.0, S);          % 18.13 x 11 cm

y = [9.6 7.2 4.6 2.2];               % lane centres, top -> bottom
xs = [2.0 5.2 8.4 11.6];             % source columns
W = 2.8; H = 1.0;

% lane 1: sources ---------------------------------------------------------
lab = {{'Field sensors','(PLC / SCADA)'}, {'Lab assays','(LIMS)'}, ...
       {'Process','historian'}, {'Operator','inputs'}};
for i = 1:4, s(i) = pd_node(xs(i), y(1), lab{i}, 'W',W, 'H',H, 'Role','io'); end %#ok<SAGROW>
% lane 2: one wide ingestion node under all sources + feature store --------
etl = pd_node(mean(xs([1 4])), y(2), 'Ingestion, ETL & validation', ...
    'W', xs(4) - xs(1) + W, 'H', 0.8, 'Role','process');
fs  = pd_node(15.6, y(2), {'Feature','store'}, 'Shape','database', 'W',2.4, 'H',1.25, 'Role','data');
% lane 3: ML services -------------------------------------------------------
m1 = pd_node(3.6,  y(3), {'Soft-sensor','model'},       'W',W, 'H',H, 'Role','model');
m2 = pd_node(9.2,  y(3), {'Optimizer','(set-points)'},  'W',W, 'H',H, 'Role','optim');
m3 = pd_node(15.6, y(3), {'Model registry','& monitoring'}, 'W',W, 'H',H, 'Role','neutral');
% lane 4: consumers ---------------------------------------------------------
c1 = pd_node(6.4,  y(4), 'Operator dashboard', 'W',3.2, 'H',0.8, 'Role','output');
c2 = pd_node(12.0, y(4), 'DCS set-points',     'W',3.2, 'H',0.8, 'Role','output');

for i = 1:4   % straight drops: offset = column position along the bus
    pd_connect(s(i), etl, 'From','S', 'To','N', 'ToOffset', (xs(i) - etl.x)/(etl.w/2));
end
pd_connect(etl, fs);
ymid = (y(2) + y(3))/2 - 0.1;        % shared trunk height between lanes
pd_connect(fs, m1, 'From','S', 'To','N', 'Route','vhv', 'MidAbs', ymid);
pd_connect(fs, m2, 'From','S', 'To','N', 'Route','vhv', 'MidAbs', ymid);
pd_connect(fs, m3, 'Type','optional', 'Label','drift stats', 'LabelSide','right', 'FromOffset',0.45, 'ToOffset',0.45*fs.w/m3.w);
pd_connect(m1, m2, 'Label','y_{pred}(t)');
pd_connect(m2, m3, 'Arrow','both', 'Type','optional', 'Label','versioning');
ymid2 = (y(3) + y(4))/2;
pd_connect(m1, c1, 'From','S', 'To','N', 'ToOffset',-0.5, 'Route','vhv', 'MidAbs', ymid2);
pd_connect(m2, c1, 'From','S', 'To','N', 'ToOffset', 0.5, 'Route','vhv', 'MidAbs', ymid2);
pd_connect(m2, c2, 'From','S', 'To','N', 'Route','vhv', 'MidAbs', ymid2);
% closed loop: under the consumers lane, up the left margin, into sensors
yb = y(4) - 1.2; xl = 0.25;
pd_connect(c2, s(1), 'From','S', 'To','W', 'Type','feedback', ...
    'Via', [c2.x yb; xl yb; xl y(1)], 'Label','closed-loop actuation', ...
    'LabelPos', 0.18, 'LabelSide','below');

pd_group(num2cell(s), 'Title','Data sources', 'Pad',[0.3 0.3 0.2 0.15]);
pd_group({etl, fs}, 'Title','Data platform', 'Pad',[0.3 0.3 0.2 0.15], 'TitlePos','top-right');
pd_group({m1, m2, m3}, 'Title','ML services', 'Pad',[0.3 0.3 0.2 0.15]);
pd_group({c1, c2}, 'Title','Consumers', 'Pad',[1.7 0.3 0.15 0.15]);   % room for title

pd_icon('cloud', 15.6, y(1), 'Size',1.2, 'Role','data', 'Label','Cloud / on-prem');

pd_check(fig);
pd_export(fig, 'ex_architecture', 'Formats', {'pdf','png'});
