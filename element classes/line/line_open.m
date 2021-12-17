%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Convert deg units to px
this.points = element_deg2px(this.points);
this.width = element_deg2px(this.width);
%---


points = this.points;
width = this.width;
color = this.color;
position = this.position;
opacity = this.opacity;
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

if ~(isRowNum(width) && all(width > 0) && ~isempty(width))
    error('Property .width must be a number or row vector of numbers > 0.')
end
if ~any(numel(width) == [1 numLines])
    error('In property .width: Number of widths must = 1 or number of lines set by .points.')
end
if numel(width) == 1
    width = repmat(width, 1, numLines);
end
this.width = width;

if ~(isa(color, 'numeric') && ismatrix(color) && size(color, 2) == 3 && allish(color >= 0 & color <= 1))
    error('Property .color must be a 1x3 vector or nx3 matrix with numbers between 0-1.')
end
if ~any(size(color, 1) == [1 numLines])
    error('In property .color: Number of colors must = 1 or number of lines set by .points.')
end
if size(color, 1) == 1
    color = repmat(color, numLines, 1);
end
this.color = color;
%---


if WITHPTB
        [minLineWidth, maxLineWidth] = Screen('DrawLines', n_window);
        if ~all(width >= minLineWidth & width <= maxLineWidth)
            error(['In property .width: [' num2str(width) '] px is out of range. On your system lines must be between ' num2str(minLineWidth) '-' num2str(maxLineWidth) ' px.'])
        end
        
        
    %Format color and merge into RGBA for PTB DrawLines
    x(1:2:numLines*2,:) = color;
    x(2:2:numLines*2,:) = color;
    x(:,4) = opacity;
    x = transpose(x);
    color = x;
end

    
%Reshape into standard coords (x, y) x points (start, end, start, end, ...)
points = reshape(transpose(points), 2, numLines*2);

%Shift from relative to object position -> relative to screen top left
points = points+repmat(transpose(position), 1, numLines*2);

%Won't use texture method for showing object display, so tell PsychBench display size (approx).
%Input rect since display might not be centered at object position (just relative to it).
rect = transpose([min(points, [], 2); max(points, [], 2)]);
this = element_setDisplaySize(this, rect);


this.color = color;
this.numLines = numLines;
this.points = points;