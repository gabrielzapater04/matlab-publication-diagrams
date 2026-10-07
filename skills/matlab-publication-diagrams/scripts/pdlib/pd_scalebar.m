function N = pd_scalebar(x, y, lenCm, realLen, units, varargin)
%PD_SCALEBAR Alternating scale bar for plant layouts / plan views.
%   pd_scalebar(1, 0.8, 3, 30, 'm')   3 cm on paper represents 30 m
%   Options: 'Segments' (4), 'Height' (0.12), 'FontSize'
S = pd_getstyle();
o = pd_opts(struct('Segments', 4, 'Height', 0.12, 'FontSize', S.fontSizeSmall, ...
    'Parent', gca), varargin{:});
ax = o.Parent; n = o.Segments; sl = lenCm/n; hh = o.Height; h = pd_hempty();
for k = 1:n
    c = [1 1 1]; if mod(k, 2) == 1, c = S.textColor; end
    h(end+1) = pd_patch(x + (k-1)*sl + [0 sl sl 0], y + [0 0 hh hh], c, ...
        'EdgeColor', S.textColor, 'LineWidth', 0.5, 'Parent', ax); %#ok<AGROW>
end
vals = [0, realLen/2, realLen]; xs = [x, x + lenCm/2, x + lenCm];
for k = 1:3
    str = sprintf('%g', vals(k)); if k == 3, str = sprintf('%g %s', vals(k), units); end
    h(end+1) = text(xs(k), y + hh + 0.05, str, 'Parent', ax, 'FontName', S.font, ...
        'FontSize', o.FontSize, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'Color', S.textColor); %#ok<AGROW>
end
N = pd_mknode('scalebar', 'box', x + lenCm/2, y + 0.25, lenCm, 0.5, h, '');
end
