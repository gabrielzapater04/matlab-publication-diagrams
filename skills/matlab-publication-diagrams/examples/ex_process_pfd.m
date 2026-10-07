%% ex_process_pfd.m -- Process Flow Diagram (PFD) with instrumentation
% Generic example: feed bin -> conveyor -> two agitated leach tanks in
% series -> thickener -> underflow pump. Shows: equipment ports, thick
% process pipes vs dashed signal lines, stream-number tags, an ISA
% instrument loop and a legend. Swap equipment types to build any circuit.
S = pd_style('elsevier');
[fig, ax] = pd_figure('double', 7.2, S);           % 19 x 7.2 cm

bin  = pd_equipment('bin',       1.3, 6.2, 'Scale',0.9, 'Label','Feed bin', 'LabelPos','right');
conv = pd_equipment('conveyor',  1.3 + 0.95*0.9, 4.7, 'Scale',0.9, 'Label','Belt conveyor');
t1   = pd_equipment('agitated_tank', 6.6, 3.6, 'Label','Leach tank 1');
t2   = pd_equipment('agitated_tank', 9.3, 2.7, 'Label','Leach tank 2');   % cascade: lower
thk  = pd_equipment('thickener', 13.2, 3.6, 'Scale',0.95, 'Label','Thickener', 'LabelPos','below', 'LabelDX',0.85);
pmp  = pd_equipment('pump',      15.3, 1.2, 'Label','Underflow pump');
fit  = pd_equipment('instrument', 16.5, 2.4, 'Tag',{'FIT','201'});
fic  = pd_equipment('instrument', 17.6, 2.4, 'Tag',{'FIC','201'}, 'Variant','panel');

% conveyor tail placed exactly under the bin outlet -> straight vertical drop
pd_connect(bin, conv, 'From','out', 'To','in', 'Type','pipe');
% conveyor head discharges into tank 1 from above (hv: right, then down)
pd_connect(conv, t1, 'From','out', 'To','feed', 'Type','pipe', 'Route','hv');
pd_connect(t1, t2, 'From','out', 'To','in', 'Type','pipe');           % same height
% tank 2 -> thickener feedwell: go AROUND the thickener with Via waypoints
fp = thk.ports.feed; y2 = t2.ports.out(2);
pd_connect(t2, thk, 'From','out', 'To','feed', 'Type','pipe', ...
    'Via', [11.0 y2; 11.0 fp(2)+0.55; fp(1) fp(2)+0.55]);
pd_connect(thk, pmp, 'From','underflow', 'To','suction', 'Type','pipe', 'Route','vh');
yd = pmp.ports.discharge(2);
pd_connect(pmp, [18.0 yd], 'From','discharge', 'Type','pipe', 'Route','straight');
pd_text(18.1, yd, {'To','CIP'}, 'HA','left', 'FontSize',S.fontSizeSmall);
yo = thk.ports.overflow(2);
pd_connect(thk, [17.8 yo], 'From','overflow', 'Type','pipe', 'Route','straight');
pd_text(17.9, yo, {'Solution','recycle'}, 'HA','left', 'FontSize',S.fontSizeSmall);
pd_connect([5.6 5.9], t1, 'To','reagent', 'Type','data', 'Route','hv', ...
    'Label','NaCN', 'LabelPos','start');                        % reagent addition

pd_connect([fit.x yd], fit, 'To','S', 'Type','signal', 'Arrow','none');   % tapping point
pd_connect(fit, fic, 'From','E', 'To','W', 'Type','signal');

pd_tag(1.75, 5.25, '1'); pd_tag(4.6, 4.95, '2'); pd_tag(7.95, 3.35, '3');
pd_tag(11.45, 3.6, '4'); pd_tag(13.65, 1.6, '5'); pd_tag(15.3, 4.2, '6');

pd_legend(0.15, 2.2, {{'line','Slurry / solids','Type','pipe'}, ...
    {'line','Reagent','Type','data'}, {'line','Signal','Type','signal'}}, 'RowH',0.38);

pd_check(fig);
pd_export(fig, 'ex_process_pfd', 'Formats', {'pdf','png'});
