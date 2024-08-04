%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.frequency = element_deg2px(this.frequency, -1);
this.sigma = element_deg2px(this.sigma);
%---


siz = this.size;
frequency = this.frequency;
orientation = this.orientation;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
sigma = this.sigma;
color = this.color;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(siz) == 1
    %Square
    siz = [siz siz];
end
if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0.')
end
this.size = siz;

if ~(isOneNum(frequency) && frequency >= 0)
    error('Property .frequency must be a number >= 0.')
end
if ~isOneNum(orientation)
    error('Property .orientation must be a number.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~isOneNum(meanIntensity)
    error('Property .meanIntensity must be a number.')
end

    if ~(~isempty(amplitude) || ~isempty(contrast))
        error('One of properties .amplitude or .contrast must be set.')
    end
if ~isempty(contrast)
    if ~(isOneNum(contrast) && contrast >= 0)
        error('Property .contrast must be a number >= 0, or [].')
    end
    if ~(meanIntensity > 0)
        error('If property .contrast is set, .meanIntensity must be > 0.')
    end  
else
    if ~(isOneNum(amplitude) && amplitude >= 0)
        error('Property .amplitude must be a number >= 0, or [].')
    end
end

if numel(sigma) == 1
    sigma = [sigma sigma];
end
if ~(isRowNum(sigma) && numel(sigma) == 2 && all(sigma > 0))
    error('Property .sigma must be a number or 1x2 vector of numbers > 0.')
end
this.sigma = sigma;

if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
%---


%User sets amplitude OR contrast (amplitude/mean)
if ~isempty(contrast)
    %Calculate amplitude from contrast cause used below
    amplitude = contrast*meanIntensity;
end

if meanIntensity >= 0 && meanIntensity <= 1
    %Calculate maximum amplitude, contrast before intensity would clip at 0 or 1, for experiment results output
    maxAmplitude = min(1-meanIntensity, meanIntensity-0);
    maxContrast = maxAmplitude/meanIntensity;
else
    %Mean intensity past clip -> no maximum before clip possible
    maxAmplitude = [];
    maxContrast = [];
end


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
data = element_doShared(@makeDisplayData, siz, frequency, orientation, phase, meanIntensity, amplitude, sigma, color);
%---


this.amplitude = amplitude;
this.maxAmplitude = maxAmplitude;
this.maxContrast = maxContrast;
%data is large, so set shared so only holds one value in memory for all objects
%of this type with the same type-specific property values set by user
%---
this = element_setShared(this, 'data', data);
%---


%end script




function data = makeDisplayData(siz, frequency, theta, phase, meanIntensity, amplitude, sigma, color) %local function


%Round dims to nearest odd integers, then center area on a coordinate grid of size = dims with one 0 pixel at center, dims = 2*radius+1.
siz = round(siz);
siz = siz-1+mod(siz, 2);
radius = (siz-1)/2;
[xx, yy] = meshgrid(-radius(1):radius(1), -radius(2):radius(2));

%Grating
grating = amplitude*sin(2*pi*(frequency*(xx*cosd(theta) + yy*sind(theta)) + phase));

%Gaussian envelope
a = cosd(theta)^2/(2*sigma(1)^2) + sind(theta)^2/(2*sigma(2)^2);
b = sind(2*theta)/(4*sigma(1)^2) - sind(2*theta)/(4*sigma(2)^2);
c = sind(theta)^2/(2*sigma(1)^2) + cosd(theta)^2/(2*sigma(2)^2);
envelope = exp(-(a*xx.^2 + 2*b*xx.*yy + c*yy.^2));

%Enveloped grating
data = grating.*envelope + meanIntensity;

%Apply color
color = repmat(reshape(color, [1 1 3]), flip(siz));
data = repmat(data, [1 1 3]).*color;

    
end %makeDisplayData