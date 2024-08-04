%Giles Holland 2023-24


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

if ~isRgb1(color)
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


if strcmpi(shape, 'gaussian')
    %Make Gaussian display data.
    %Maybe slow, so encapsulate in a function and do shared so only computes once 
    %for all objects of this type with the same function input values.
    %---
    gaussianData = element_doShared(@makeGaussianDisplayData, sigma, backSize, color);
    %---
else
    gaussianData = [];
end


if ~any(strcmp(propertySetNames, 'depth'))
    %If depth left at default, run after all other objects each frame so that it draws in front of them
    this = element_setFrameOrder(this, 'after');
end


this.backSize = backSize;
this.color = color;
%gaussianData is large, so set shared so only holds one value in memory for all
%objects of this type with the same type-specific property values set by user
%---
this = element_setShared(this, 'gaussianData', gaussianData);
%---


%end script




function data = makeGaussianDisplayData(sigma, backSize, color) %local function


%Round dims up to nearest odd integers, then center area on a coordinate grid of size = dims with one 0 pixel at center, dims = 2*radius+1.
backSize = ceil(backSize);
backSize = backSize+1-mod(backSize, 2);
backRadius = (backSize-1)/2;
[xx, yy] = meshgrid(-backRadius(1):backRadius(1), -backRadius(2):backRadius(2));

%Alpha channel = negative Gaussian centered on coordinate grid
alpha = (1-exp(-(xx.^2/(2*sigma(1)^2) + yy.^2/(2*sigma(2)^2))));

%Constant color
color = repmat(reshape(color, [1 1 3]), flip(backSize));

data = cat(3, color, alpha);

    
end %makeGaussianDisplayData