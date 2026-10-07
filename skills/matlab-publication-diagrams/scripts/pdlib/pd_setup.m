function pd_setup()
%PD_SETUP Add the pdlib folder to the path (call once per session).
%   run('path/to/pdlib/pd_setup.m')  or  addpath('path/to/pdlib')
addpath(fileparts(mfilename('fullpath')));
if pd_isoctave()
    % Headless Octave: qt toolkit renders text/patches most faithfully.
    try, graphics_toolkit('qt'); catch, end
end
end
