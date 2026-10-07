function [fill, edge] = pd_rolecolor(S, role)
%PD_ROLECOLOR Fill (light tint) and edge (full colour) for a role.
%   role: '' (white node, dark edge) | role name ('model','data',...) |
%         palette index 1..8 | RGB triplet (used as fill; edge darkened).
if nargin < 2 || isempty(role)
    fill = [1 1 1]; edge = S.edgeColor; return;
end
if ischar(role)
    switch lower(role)
        case {'none', 'white'}, fill = [1 1 1]; edge = S.edgeColor; return;
        case 'group',           fill = S.groupFill; edge = S.groupEdge; return;
    end
    if ~isfield(S.roleIndex, lower(role))
        error('pd:role', 'Unknown role "%s". Valid: %s', role, ...
            strjoin(fieldnames(S.roleIndex)', ', '));
    end
    k = S.roleIndex.(lower(role));
    fill = S.fills(k, :); edge = S.colors(k, :) * 0.85;
elseif isscalar(role)
    fill = S.fills(role, :); edge = S.colors(role, :) * 0.85;
else
    fill = role(:)'; edge = fill * 0.55;
end
end
