function h = pd_hempty()
%PD_HEMPTY Empty graphics-handle array (gobjects in MATLAB, [] in Octave).
if exist('gobjects', 'builtin') || exist('gobjects', 'file')
    h = gobjects(0);
else
    h = [];
end
end
