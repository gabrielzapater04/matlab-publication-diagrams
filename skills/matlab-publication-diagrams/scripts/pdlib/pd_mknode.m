function N = pd_mknode(kind, shape, x, y, w, h, handles, label, ports, portdir)
%PD_MKNODE Internal constructor. Every drawable returns this same struct,
%   so nodes, equipment, groups, icons and NN blocks can be concatenated
%   ([n1 n2 n3]) and passed to pd_connect / pd_group interchangeably.
if nargin < 8, label = ''; end
if nargin < 9 || isempty(ports), ports = struct(); end
if nargin < 10 || isempty(portdir), portdir = struct(); end
N = struct('kind', kind, 'shape', shape, 'x', x, 'y', y, 'w', w, 'h', h, ...
    'handles', {handles}, 'label', {label}, 'ports', ports, 'portdir', portdir);
end
