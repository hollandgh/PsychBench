%Giles Holland 2022-24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.positions = element_deg2px(this.positions);
this.size = element_deg2px(this.size);
%---


positions = this.positions;
sizes = this.size;
colors = this.color;
type = this.type;
n_window = this.n_window;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isa(positions, 'numeric') && ismatrix(positions) && size(positions, 2) == 2 && ~isempty(positions))
    error('Property .positions must be an nx2 matrix.')
end
numDots = size(positions, 1);


if numel(sizes) == 1
    %Same size across dots
    sizes = repmat(sizes, 1, numDots);
end
if ~(isRowNum(sizes) && numel(sizes) == numDots && all(sizes > 0))
    error('Property .size must be a number > 0. It can also be a 1xn vector where n is number of dots in .positions.')
end
this.size = sizes;


if size(colors, 1) == 1
    colors = repmat(colors, numDots, 1);
end
if ~(isa(colors, 'numeric') && ismatrix(colors) && size(colors, 1) == numDots && any(size(colors, 2) == [3 4]) && all2(colors >= 0 & colors <= 1))
    error('Property .color must be a 1x3 or 1x4 vector of numbers between 0-1. It can also be an nx3/4 matrix where n is number of dots in .positions.')
end
if size(colors, 2) == 3
    %Standardize to RGBA
    colors(:,4) = 1;
end
this.color = colors;


if ~(isOneNum(type) && isIntegerVal(type) && type >= 1 && type <= 5)
    error('Property .type must be a number between 1-5.')
end
%---


    [minDotSize, maxDotSize] = Screen('DrawDots', n_window);
    i = find(~(sizes >= minDotSize & sizes <= maxDotSize), 1);
    if ~isempty(i)
        if numel(sizes) == 1
            error(['In property .size: ' num2str(sizes) ' px is out of range. On your system dots must be between ' num2str(minDotSize) '-' num2str(maxDotSize) ' px.'])
        else
            error(['In property .size: ' 10 ...
                10 ...
                val2char(sizes) ' px' 10 ...
                10 ...
                num2str(sizes(i)) ' px is out of range. On your system dots must be between ' num2str(minDotSize) '-' num2str(maxDotSize) ' px.'])
        end
    end
    

%Will draw dots to a texture for PsychBench to draw to screen...
%Get dot positions rel to texture top left, texture size, object center offset from position.
%Texture fit to arrangement + padding = dot size on each side, then dots at edges won't be clipped.
%User set dot positions relative to object position.
maxSize = max(sizes);
rect = [min(positions, [], 1)-(maxSize+1)/2 max(positions, [], 1)+(maxSize-1)/2];	%texture rect relative to window, including padding = max dot size
positions_texture = positions-repmat(rect(1:2), size(positions, 1), 1);             %dot positions relative to texture top left
textureSize = rect(3:4)-rect(1:2);                                                  %texture size
centerOffset = (rect(1:2)+rect(3:4)+1)/2;                                           %object center offset from position


this.positions_texture = positions_texture;
this.textureSize = textureSize;
this.centerOffset = centerOffset;