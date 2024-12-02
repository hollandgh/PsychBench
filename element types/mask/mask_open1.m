%Giles Holland 2023, 24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.sigma = element_deg2px(this.sigma);
this.backSize = element_deg2px(this.backSize);

%Standardize strings from "x"/'x' to 'x'
this.shape = var2char(this.shape);
%---


shape = this.shape;
siz = this.size;
sigma = this.sigma;
backSize = this.backSize;
color = this.color;
position = this.position;
propertySetNames = this.propertySetNames;
windowSize = devices.screen.windowSize;
windowCenter = devices.screen.windowCenter;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(shape) && any(strcmpi(shape, {'square' 'rectangle' 'circle' 'oval' 'gaussian'})))
    error('Property .shape must be a string "rectangle", "circle", or "gaussian".')
end

if any(strcmpi(shape, {'square' 'rectangle' 'circle' 'oval'}))
    if numel(siz) == 1
        %Square
        siz = [siz siz];
    end
    if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0))
        error('Property .size must be a number or 1x2 vector of numbers > 0.')
    end
    this.size = siz;
else %gaussian
    if numel(sigma) == 1
        sigma = [sigma sigma];
    end
    if ~(isRowNum(sigma) && numel(sigma) == 2 && all(sigma > 0))
        error('Property .sigma must be a number or 1x2 vector of numbers > 0.')
    end
    this.sigma = sigma;
end

if ~(isOneNum(backSize) && backSize == inf)
    if numel(backSize) == 1
        backSize = [backSize backSize];
    end
    if ~(isRowNum(backSize) && numel(backSize) == 2 && all(backSize > 0))
        error('Property .backSize must be a number or 1x2 vector of numbers > 0, or the number inf.')
    end
    this.backSize = backSize;
end

if ~(isRgb1(color) || isempty(color))
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---


if numel(backSize) == 1 && backSize == inf
    %Fill window when drawn centered at any position and with any rotation
    backSize = (2*max(windowSize)^2)^(1/2)+2*abs(position-windowCenter);
end

if isempty(color)
    %Mask color = trial background color
    color = trial.backColor;
end


if ~any(strcmp(propertySetNames, 'depth'))
    %If depth left at default, run after all other objects each frame so that it draws in front of them
    this = element_setFrameOrder(this, 'after');
end


this.backSize = backSize;
this.color = color;