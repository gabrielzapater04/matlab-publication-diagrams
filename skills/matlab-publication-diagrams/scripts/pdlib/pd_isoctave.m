function tf = pd_isoctave()
%PD_ISOCTAVE True when running under GNU Octave.
tf = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end
