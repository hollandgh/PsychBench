%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Convert deg units to px
this.size = element_deg2px(this.size);
this.frequency = element_deg2px(this.frequency, -1);
this.sigma = element_deg2px(this.sigma);
%---


siz = this.size;
frequency = this.frequency;
phase = this.phase;
rotateInArea = this.rotateInArea;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
sigma = this.sigma;
color = this.color;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(siz) == 1
    siz = [siz siz];
end
if ~(isRowNum(siz) && numel(siz) == 2 && all(siz > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0.')
end
this.size = siz;

if ~(isOneNum(frequency) && frequency >= 0)
    error('Property .frequency must be a number >= 0.')
end
if ~isOneNum(phase)
    error('Property .phase must be a number.')
end
if ~isOneNum(rotateInArea)
    error('Property .rotateInArea must be a number.')
end
if ~isOneNum(meanIntensity)
    error('Property .meanIntensity must be a number.')
end

    if ~(isOneNum(contrast) && contrast >= 0 || isempty(contrast))
        error('Property .contrast must be a number >= 0, or [].')
    end
if ~isempty(contrast)
    if ~(meanIntensity > 0)
        error('If property .contrast is set .meanIntensity must be > 0.')
    end  
else
    if isempty(amplitude)
        error('One of properties .amplitude or .contrast must be set.')
    end
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

if ~(isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1))
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
%Maybe slow, so encapsulate in a function and share so only computes once for
%all objects of the class with the same function input values.
%---
data = element_doShared(@makeDisplayData, siz, frequency, phase, rotateInArea, meanIntensity, amplitude, sigma, color);
%---


this.amplitude = amplitude;
this.maxAmplitude = maxAmplitude;
this.maxContrast = maxContrast;
%data is large, so set shared so only holds one value in memory for all objects
%of the class with the same index property values.
%---
this = element_setShared(this, 'data', data, {'siz' 'frequency' 'phase' 'rotateInArea' 'meanIntensity' 'amplitude' 'sigma' 'color'});
%---


%end script




function data = makeDisplayData(siz, frequency, phase, theta, meanIntensity, amplitude, sigma, color) %local function


%Round dims down to nearest odd integers, then center area on a coordinate grid of size = dims with one 0 pixel at center, dims = 2*radius+1.
siz = floor(siz);
siz = siz-1+mod(siz, 2);
radius = (siz-1)/2;
[xx, yy] = meshgrid(-radius(1):radius(1), -radius(2):radius(2));

%Grating
grating = amplitude*sin(2*pi*frequency*(xx*cosd(theta) + yy*sind(theta)) + phase*2*pi);

%Gaussian envelope
a = cosd(theta)^2/(2*sigma(1)^2) + sind(theta)^2/(2*sigma(2)^2);
b = -sind(2*theta)/(4*sigma(1)^2) + sind(2*theta)/(4*sigma(2)^2);
c = sind(theta)^2/(2*sigma(1)^2) + cosd(theta)^2/(2*sigma(2)^2);
envelope = exp(-(a*xx.^2 + 2*b*xx.*yy + c*yy.^2));

%Enveloped grating
data = grating.*envelope + meanIntensity;

%Apply color
color = repmat(reshape(color, [1 1 3]), siz);
data = repmat(data, [1 1 3]).*color;

    
end %makeDisplayData