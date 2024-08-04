%Giles Holland 2023-24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.points = element_deg2px(this.points);
this.borderWidth = element_deg2px(this.borderWidth);
%---


points = this.points;
colors = this.color;
borderWidths = this.borderWidth;
borderColors = this.borderColor;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~isa(points, 'cell')
    %Same size across polygons
    points = {points};
end
    points = row(points);
if ~(~isempty(points) && all(cellfun(@(x) isa(x, 'numeric') && ismatrix(x) && size(x, 2) == 2 && size(x, 1) >= 3,    points)))
    error('Property .points must be an nx2 matrix with 3+ rows. It can also be a cell array of matrixes.')
end
numPolys = numel(points);


if size(colors, 1) == 1
    colors = repmat(colors, numPolys, 1);
end    
if ~(isa(colors, 'numeric') && ismatrix(colors) && size(colors, 1) == numPolys && any(size(colors, 2) == [3 4]) && all2(colors >= 0 & colors <= 1))
    error('Property .color must be a 1x3 or 1x4 vector with numbers between 0-1. It can also be an nx3/4 matrix where n is number of polygons in .points.')
end
if size(colors, 2) < 4
    %RGB -> RGBA cause will check (4) later
    colors(:,4) = 1;
end
this.color = colors;


if numel(borderWidths) == 1
    borderWidths = repmat(borderWidths, 1, numPolys);
end
    borderWidths = row(borderWidths);
if ~(isa(borderWidths, 'numeric') && numel(borderWidths) == numPolys && all(borderWidths >= 0))
    error('Property .borderWidth must be a number >= 0. It can also be a 1xn vector where n is number of polygons in .points.')
end
this.borderWidth = borderWidths;


if size(borderColors, 1) == 1
    borderColors = repmat(borderColors, numPolys, 1);
end    
if ~(isa(borderColors, 'numeric') && ismatrix(borderColors) && size(borderColors, 1) == numPolys && any(size(borderColors, 2) == [3 4]) && all2(borderColors >= 0 & borderColors <= 1))
    error('Property .borderColor must be a 1x3 or 1x4 vector with numbers between 0-1. It can also be an nx3/4 matrix where n is number of polygons in .points.')
end
if size(borderColors, 2) < 4
    borderColors(:,4) = 1;
end
this.borderColor = borderColors;
%---


%Will draw polygons to a texture for PsychBench to draw to screen...
%Get polygon points rel to texture top left, texture size, object center offset from position.
%Texture fit to arrangement polygons + padding = polygon border width size on each side, then borders won't be clipped.
%User set polygon points relative to object position.
%---
    mins = zeros(numPolys, 2);
    maxs = zeros(numPolys, 2);
for n = 1:numPolys
    mins(n,:) = min(points{n}, [], 1);
    maxs(n,:) = max(points{n}, [], 1);
end
    maxBorderWidth = max(borderWidths);
rect = [min(mins, [], 1)-maxBorderWidth max(maxs, [], 1)+maxBorderWidth]; 	%texture rect relative to window, including padding = max polygon border width

    points_texture = cell(size(points));
for n = 1:numPolys
    points_texture{n} = points{n}-repmat(rect(1:2), size(points{n}, 1), 1);
end                                                                         %polygon points relative to texture top left
textureSize = rect(3:4)-rect(1:2);                                          %texture size
centerOffset = (rect(1:2)+rect(3:4)+1)/2;                                   %object center offset from position
%---

    
%Format for input to PTB FillRect/FrameRect for multiple polygons later
colors = transpose(colors);
borderColors = transpose(borderColors);


this.color = colors;
this.borderColor = borderColors;
this.numPolys = numPolys;
this.points_texture = points_texture;
this.textureSize = textureSize;
this.centerOffset = centerOffset;