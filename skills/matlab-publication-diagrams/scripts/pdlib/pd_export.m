function files = pd_export(fig, basename, varargin)
%PD_EXPORT Export a pd figure at its exact physical size.
%   pd_export(fig, 'fig_process')                    -> PDF + PNG (600 dpi)
%   pd_export(fig, 'out/fig3', 'Formats', {'pdf','eps','svg','tif','png'})
%   pd_export(fig, 'fig3', 'Method','exportgraphics')  tight crop (MATLAB)
%
%   Options
%     'Formats'     cell: 'pdf','eps','svg','png','tif','emf'  ({'pdf','png'})
%     'Resolution'  dpi for raster formats (600). Line art: 600-1200.
%     'Method'      'print' (default: page = figure size, exact cm) |
%                   'exportgraphics' (MATLAB R2020a+, crops to content)
%     'RemoveGrid'  delete the pd_figure layout grid before export (true)
%
%   Vector formats (PDF/EPS/SVG) are what journals want for line art:
%   text stays text, fonts are embedded, zoom is lossless. Use PNG/TIFF
%   only when a raster is explicitly requested (e.g. some MDPI/Word flows).
o = pd_opts(struct('Formats', {{'pdf', 'png'}}, 'Resolution', 600, ...
    'Method', 'print', 'RemoveGrid', true), varargin{:});
if ischar(o.Formats), o.Formats = {o.Formats}; end
if o.RemoveGrid, delete(findall(fig, 'Tag', 'pd_grid')); end
[d, ~, ~] = fileparts(basename);
if ~isempty(d) && ~exist(d, 'dir'), mkdir(d); end
try, set(fig, 'Renderer', 'painters'); catch, end
drawnow;
isOct = pd_isoctave();
if isOct, warning('off', 'Octave:print:figure-too-large'); end  % rounding false alarm
useEG = strcmpi(o.Method, 'exportgraphics') && ~isOct && exist('exportgraphics', 'file');
files = {};
for k = 1:numel(o.Formats)
    fmt = lower(o.Formats{k});
    fn = [basename '.' strrep(fmt, 'tiff', 'tif')];
    if useEG && ~strcmp(fmt, 'svg')
        if any(strcmp(fmt, {'pdf', 'eps', 'emf'}))
            exportgraphics(fig, fn, 'ContentType', 'vector', 'BackgroundColor', 'white');
        else
            exportgraphics(fig, fn, 'Resolution', o.Resolution, 'BackgroundColor', 'white');
        end
    else
        r = sprintf('-r%d', o.Resolution);
        switch fmt
            case 'pdf',  dev = {'-dpdf'};
            case 'eps',  dev = {'-depsc'};
            case 'svg',  dev = {'-dsvg'};
            case 'png',  dev = {'-dpng', r};
            case {'tif', 'tiff'}
                if isOct, dev = {'-dtiff', r}; else, dev = {'-dtiffn', r}; end
            case 'emf',  dev = {'-dmeta'};
            otherwise, error('pd:export', 'Unknown format "%s".', fmt);
        end
        if ~isOct && any(strcmp(fmt, {'pdf', 'eps', 'svg', 'emf'}))
            dev{end+1} = local_vectorflag(); %#ok<AGROW>
        end
        print(fig, dev{:}, fn);
    end
    files{end+1} = fn; %#ok<AGROW>
    fprintf('pd_export: wrote %s\n', fn);
end
end

function f = local_vectorflag()
% '-vector' replaced '-painters' in R2022b; both force true vector output.
if verLessThan('matlab', '9.13'), f = '-painters'; else, f = '-vector'; end
end
