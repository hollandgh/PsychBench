%Giles Holland 2022-24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.points = element_deg2px(this.points);
this.width = element_deg2px(this.width);
%---


points = this.points;
widths = this.width;
colors = this.color;
n_window = this.n_window;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---    
if ~(isa(points, 'numeric') && ismatrix(points) && size(points, 2) == 4 && ~isempty(points))
    error('Property .points must be a 1x4 vector or nx4 matrix.')
end
if any(points(:,1) == points(:,3) & points(:,2) == points(:,4))
    error('In property .points: All line lengths must be > 0.')
end
numLines = size(points, 1);


if numel(widths) == 1
    widths = repmat(widths, 1, numLines);
else
    widths = row(widths);
end
if ~(isRowNum(widths) && numel(widths) == numLines && all(widths > 0))
    error('Property .width must be a number > 0. It can also be a 1xn vector where n is number of lines in .points.')
end
this.width = widths;


if size(colors, 1) == 1
    colors = repmat(colors, numLines, 1);
end    
if ~(isa(colors, 'numeric') && ismatrix(colors) && size(colors, 1) == numLines && size(colors, 2) == 3 && all2(colors >= 0 & colors <= 1))
    error('Property .color must be a 1x3 vector of numbers between 0-1. It can also be an nx3 matrix where n is number of lines in .points.')
end
this.color = colors;
%---


    [minLineWidth, maxLineWidth] = Screen('DrawLines', n_window);
    i = find(~(widths >= minLineWidth & widths <= maxLineWidth), 1);
    if ~isempty(i)
        if numel(widths) == 1
            error(['In property .width: ' num2str(widths) ' px is out of range. On your system lines must be between ' num2str(minLineWidth) '-' num2str(maxLineWidth) ' px.'])
        else
            error(['In property .width: ' 10 ...
                10 ...
                val2char(widths) ' px' 10 ...
                10 ...
                num2str(widths(i)) ' px is out of range. On your system lines must be between ' num2str(minLineWidth) '-' num2str(maxLineWidth) ' px.'])
        end
    end


%Will draw lines to a texture for PsychBench to draw to screen...
%Get line points rel to texture top left, texture size, object center offset from position.
%Texture fit to arrangement + padding = line width on each side, then lines at edges won't be clipped.
%User set line points relative to object position.
maxWidth = max(widths);
points = transpose(reshape(transpose(points), 2, numLines*2));      %reshape into points (start, end, start, end) x coords (x, y)
rect = [min(points, [], 1)-maxWidth max(points, [], 1)+maxWidth];	%texture rect relative to window, including padding = max line width
points_texture = points-repmat(rect(1:2), size(points, 1), 1);      %line points relative to texture top left
textureSize = rect(3:4)-rect(1:2);                                	%texture size
centerOffset = (rect(1:2)+rect(3:4)+1)/2;                           %object center offset from position


%Format for input to PTB DrawLines.
%Include flip ordering so for multiple lines maybe overlapping draw with first above last to match convention for property .depth (+ = behind).
%---
widths = flip(widths);

x(1:2:numLines*2,:) = colors;
x(2:2:numLines*2,:) = colors;
x = transpose(flip(x, 1));
colors = x;

points_texture = transpose(flip(points_texture, 1));
%---


this.width = widths;
this.color = colors;
this.points_texture = points_texture;
this.textureSize = textureSize;
this.centerOffset = centerOffset;