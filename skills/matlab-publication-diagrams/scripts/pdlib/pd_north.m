function N = pd_north(x, y, varargin)
%PD_NORTH North arrow for plant layouts. Options: 'Size' (0.8 cm), 'Angle' (0)
S = pd_getstyle();
o = pd_opts(struct('Size', 0.8, 'Angle', 0, 'Parent', gca), varargin{:});
ax = o.Parent; s = o.Size; a = o.Angle*pi/180; Rm = [cos(a) -sin(a); sin(a) cos(a)];
L = Rm*[0 -0.25 0; 0.5 -0.4 -0.22]*s; Rr = Rm*[0 0.25 0; 0.5 -0.4 -0.22]*s;
h1 = pd_patch(x + L(1,:), y + L(2,:), S.textColor, 'EdgeColor', S.textColor, 'LineWidth', 0.5, 'Parent', ax);
h2 = pd_patch(x + Rr(1,:), y + Rr(2,:), [1 1 1], 'EdgeColor', S.textColor, 'LineWidth', 0.5, 'Parent', ax);
p = Rm*[0; 0.62]*s;
h3 = text(x + p(1), y + p(2), 'N', 'Parent', ax, 'FontName', S.font, ...
    'FontSize', S.fontSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'Color', S.textColor);
N = pd_mknode('north', 'box', x, y, s, s, [h1 h2 h3], 'N');
end
