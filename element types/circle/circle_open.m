%Giles Holland 2022-24


        %(Handle deprecated)
        %---
        if isfield(this, 'showFill')
            if isempty(this.showFill)
                       %Deprecated default = true -> deprecated RGB color (not RGBA)
            else
                if is01s(this.showFill)
                    if all2(this.showFill)
                        %all true -> deprecated RGB color (not RGBA)
                    elseif all2(~this.showFill)
                        this.color = [0 0 0 0];
                    else
                        error('Property .showFill is deprecated. Please use number(s) in column 4 of .color to set fill or no fill (0 = no fill) instead.')
                    end
                end
            end
        end

        if isfield(this, 'showBorder')
            if isempty(this.showBorder)
                        %Deprecated default = false
                        this.borderWidth = 0;
            else
                if is01s(this.showBorder) 
                    if all2(~this.showBorder)
                        this.borderWidth = 0;
                    else
                        error('Property .showBorder is deprecated. Please use .borderWidth to set border or no border (0 = no border) instead.')
                    end
                end
            end
        end
        %---


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.borderWidth = element_deg2px(this.borderWidth);
this.positions = element_deg2px(this.positions);
%---


sizes = this.size;
colors = this.color;
borderWidths = this.borderWidth;
borderColors = this.borderColor;
positions = this.positions;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isa(positions, 'numeric') && ismatrix(positions) && size(positions, 2) == 2 && ~isempty(positions))
    error('Property .positions must be an nx2 matrix.')
end
numCircles = size(positions, 1);


if size(sizes, 1) == 1
    %Same size across shapes
    sizes = repmat(sizes, numCircles, 1);
end
if size(sizes, 2) == 1
    %Circles
    sizes = repmat(sizes, 1, 2);
end
if ~(isa(sizes, 'numeric') && ismatrix(sizes) && size(sizes, 1) == numCircles && size(sizes, 2) == 2 && all2(sizes > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0. It can also be an nx1/2 vector where n is number of shapes in .positions.')
end
this.size = sizes;


if size(colors, 1) == 1
    colors = repmat(colors, numCircles, 1);
end    
if ~(isa(colors, 'numeric') && ismatrix(colors) && size(colors, 1) == numCircles && any(size(colors, 2) == [3 4]) && all2(colors >= 0 & colors <= 1))
    error('Property .color must be a 1x3 or 1x4 vector with numbers between 0-1. It can also be an nx3/4 matrix where n is number of shapes in .positions.')
end
if size(colors, 2) < 4
    %RGB -> RGBA cause will check (4) later
    colors(:,4) = 1;
end
this.color = colors;


if numel(borderWidths) == 1
    borderWidths = repmat(borderWidths, 1, numCircles);
else
    borderWidths = row(borderWidths);
end
if ~(isa(borderWidths, 'numeric') && numel(borderWidths) == numCircles && all(borderWidths >= 0))
    error('Property .borderWidth must be a number >= 0. It can also be a 1xn vector where n is number of shapes in .positions.')
end
this.borderWidth = borderWidths;


if size(borderColors, 1) == 1
    borderColors = repmat(borderColors, numCircles, 1);
end    
if ~(isa(borderColors, 'numeric') && ismatrix(borderColors) && size(borderColors, 1) == numCircles && any(size(borderColors, 2) == [3 4]) && all2(borderColors >= 0 & borderColors <= 1))
    error('Property .borderColor must be a 1x3 or 1x4 vector with numbers between 0-1. It can also be an nx3/4 matrix where n is number of shapes in .positions.')
end
if size(borderColors, 2) < 4
    borderColors(:,4) = 1;
end
this.borderColor = borderColors;
%---


%Will draw shapes to a texture for PsychBench to draw to screen...
%Get shape rects rel to texture top left, texture size, object center offset from position.
%Texture fit to arrangement of multiple shapes.
%User set shape positions relative to object position.    
rects_position = [positions-sizes/2 positions+sizes/2];                 %shape rects relative to object position
position_texture = -min(rects_position(:,[1 2]), [], 1);                %object position relative to texture top left
rects_texture = rects_position+repmat(position_texture, numCircles, 2); %shape rects relative to texture top left
textureSize = max(rects_texture(:,[3 4]), [], 1);                       %texture size
center_texture = (textureSize+1)/2;                                     %object center relative to texture top left
centerOffset = center_texture-position_texture;                         %object center offset from position


%Format for input to PTB FillRect/FrameRect for multiple shapes later
colors = transpose(colors);
borderColors = transpose(borderColors);
rects_texture = transpose(rects_texture);


this.color = colors;
this.borderColor = borderColors;
this.numCircles = numCircles;
this.rects_texture = rects_texture;
this.textureSize = textureSize;
this.centerOffset = centerOffset;