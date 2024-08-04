%Giles Holland 2023


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.sigma = element_deg2px(this.sigma);
this.size = element_deg2px(this.size);
%---


sigma = this.sigma;
siz = this.size;
color = this.color;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(sigma) == 1
    sigma = [sigma sigma];
end
if ~(isRowNum(sigma) && numel(sigma) == 2 && all(sigma > 0))
    error('Property .sigma must be a number or 1x2 vector of numbers > 0.')
end
this.sigma = sigma;

if numel(siz) == 1
    %Square
    siz = [siz siz];
end
if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0) || isempty(siz))
    error('Property .size must be a number or 1x2 vector of numbers > 0, or [].')
end
this.size = siz;

if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
data = element_doShared(@makeDisplayData, sigma, siz, color);
%---


%data is large, so set shared so only holds one value in memory for all objects
%of this type with the same type-specific property values set by user
%---
this = element_setShared(this, 'data', data);
%---


%end script




function data = makeDisplayData(sigma, siz, color) %local function


if isempty(siz)
    siz = 6*sigma;
end

%Round dims down to nearest odd integers, then center area on a coordinate grid of size = dims with one 0 pixel at center, dims = 2*radius+1.
siz = floor(siz);
siz = siz-1+mod(siz, 2);
radius = (siz-1)/2;
[xx, yy] = meshgrid(-radius(1):radius(1), -radius(2):radius(2));

%Alpha channel = Gaussian centered on coordinate grid
alpha = exp(-(xx.^2/(2*sigma(1)^2) + yy.^2/(2*sigma(2)^2)));

%Constant color
color = repmat(reshape(color, [1 1 3]), flip(siz));

data = cat(3, color, alpha);

    
end %makeDisplayData