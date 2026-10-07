function w = pd_textwidth(str, fontSize)
%PD_TEXTWIDTH Estimated width (cm) of a label's longest line.
%   Uses 0.52 em per character (Helvetica/Arial average), ignoring TeX
%   markup such as _{...}, ^{...} and \alpha. Good enough for layout
%   planning; pd_check measures the real extents after drawing.
if nargin < 2, fontSize = 8; end
if ischar(str), str = cellstr(str); end
if isempty(str), w = 0; return; end
n = 0;
for k = 1:numel(str)
    s = regexprep(str{k}, '\\[a-zA-Z]+', 'x');     % \alpha -> 1 char
    s = regexprep(s, '[_^{}]', '');
    n = max(n, numel(s));
end
w = n * fontSize * 0.0353 * 0.52;
end
