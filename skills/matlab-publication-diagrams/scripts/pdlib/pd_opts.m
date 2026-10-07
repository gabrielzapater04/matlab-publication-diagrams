function o = pd_opts(o, varargin)
%PD_OPTS Merge name-value pairs into a struct of defaults (case-insensitive).
%   o = pd_opts(defaults, 'Name', value, ...)
%   Unknown names raise an error listing the valid options, so typos are
%   caught immediately instead of being silently ignored.
if numel(varargin) == 1 && iscell(varargin{1}), varargin = varargin{1}; end
if mod(numel(varargin), 2) ~= 0
    error('pd:opts', 'Options must be given as name-value pairs.');
end
f = fieldnames(o);
for k = 1:2:numel(varargin)
    name = varargin{k};
    if ~ischar(name), error('pd:opts', 'Option names must be char.'); end
    idx = find(strcmpi(f, name), 1);
    if isempty(idx)
        error('pd:opts', 'Unknown option "%s". Valid options: %s', ...
            name, strjoin(f', ', '));
    end
    o.(f{idx}) = varargin{k + 1};
end
end
