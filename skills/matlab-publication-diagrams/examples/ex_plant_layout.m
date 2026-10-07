%% ex_plant_layout.m -- Plant layout (plan view) drawn to scale
% Generic example: site plan with process areas, a road, pipe racks and
% the equipment footprint. Pattern shown: a metre->cm scale factor so the
% drawing is TRULY to scale, plus scale bar and north arrow.
S = pd_style('elsevier');
[fig, ax] = pd_figure('double', 10.0, S);          % 19 x 10 cm
k = 18/180;                          % 180 m of site -> 18 cm on paper
m = @(v) v*k;                        % metres -> cm

% site boundary and internal road (grey, behind)
pd_group([m(2) m(3) m(184) m(92)], 'Title','Site boundary', 'Role','none', ...
    'TitlePos','top-right', 'LineStyle','-.');
pd_node(m(93), m(50), '', 'Shape','process', 'W',m(176), 'H',m(6), ...
    'Fill',[0.88 0.88 0.88], 'Edge','none');
pd_text(m(166), m(50), 'Main haul road', 'FontSize',S.fontSizeSmall, 'FontAngle','italic');

% process areas (true dimensions in metres)
A(1) = pd_node(m(22), m(75), {'Area 100','Crushing'},    'Shape','process', 'W',m(30), 'H',m(28), 'Role','process');
A(2) = pd_node(m(62), m(75), {'Area 200','Grinding &','classification'}, 'Shape','process', 'W',m(40), 'H',m(28), 'Role','process');
A(3) = pd_node(m(105), m(75), {'Area 300','Leaching'},   'Shape','process', 'W',m(36), 'H',m(28), 'Role','process');
A(4) = pd_node(m(145), m(75), {'Area 400','Recovery'},   'Shape','process', 'W',m(34), 'H',m(28), 'Role','output');
A(5) = pd_node(m(30), m(26), {'Control room','& lab'},    'Shape','process', 'W',m(26), 'H',m(20), 'Role','io');
A(6) = pd_node(m(80), m(24), {'Reagent','storage'},       'Shape','process', 'W',m(28), 'H',m(18), 'Role','neutral');
A(7) = pd_node(m(135), m(24), {'Tailings','thickener'},   'Shape','circle',  'W',m(34), 'Role','data');

% conveyors / pipe racks between areas (dashed = overhead rack)
for i = 1:3, pd_connect(A(i), A(i+1), 'Type','pipe'); end
pd_connect(A(3), A(7), 'From','S', 'To','N', 'Type','feedback', 'Label','Tailings line');

pd_scalebar(m(8), m(8) - 0.3, m(40), 40, 'm');
pd_north(m(170), m(18));

pd_check(fig);
pd_export(fig, 'ex_plant_layout', 'Formats', {'pdf','png'});
