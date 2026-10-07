function S = pd_getstyle(ax)
%PD_GETSTYLE Return the style struct attached to the current pd figure.
if nargin < 1 || isempty(ax), ax = gca; end
S = getappdata(ax, 'pd_style');
if isempty(S)
    S = getappdata(ancestor(ax, 'figure'), 'pd_style');
end
if isempty(S), S = pd_style(); end
end
