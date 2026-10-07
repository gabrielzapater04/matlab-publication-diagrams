function h = pd_patch(X, Y, fc, varargin)
%PD_PATCH patch() with an explicit FaceColor.
%   patch(X, Y, [r g b]) is ambiguous: for 3-vertex polygons (arrowheads,
%   triangles) MATLAB/Octave may read the triplet as per-vertex colour
%   data and interpolate, producing gradients. Always pass FaceColor.
h = patch('XData', X(:), 'YData', Y(:), 'FaceColor', fc, varargin{:});
end
