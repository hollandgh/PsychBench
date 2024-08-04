%Giles Holland 2022


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.frequency = element_deg2px(this.frequency, -1);
this.driftVel = element_deg2px(this.driftVel);

%Standardize strings from "x"/'x' to 'x'
this.shape = var2char(this.shape);
%---


shape = this.shape;
siz = this.size;
frequency = this.frequency;
orientation = this.orientation;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
color = this.color;
driftVel = this.driftVel;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isRowChar(shape) && any(strcmpi(shape, {'rectangle' 'sine'})))
    error('Property .shape must be a string "rectangle" or "sine".')
end

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

if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end
if ~isOneNum(driftVel)
    error('Property .driftVel must be a number.')
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
data = element_doShared(@makeDisplayData, shape, siz, frequency, orientation, phase, meanIntensity, amplitude, color, driftVel);
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




function data = makeDisplayData(shape, siz, frequency, theta, phase, meanIntensity, amplitude, color, driftVel) %local function


%Round dims to nearest odd integers, then center area on a coordinate grid of size = dims with one 0 pixel at center, dims = 2*radius+1.
    siz = round(siz);
    siz = siz-1+mod(siz, 2);
if driftVel ~= 0
    %Pad with spatial period on each side so when occluded by mask with aperture = nominal size, appears to drift smoothly
    siz = siz+2*ceil(1/frequency);
end
radius = (siz-1)/2;
[xx, yy] = meshgrid(-radius(1):radius(1), -radius(2):radius(2));

%Grating
if strcmpi(shape, 'rectangle')
    data = amplitude*(ceil(sin(2*pi*(frequency*(xx*cosd(theta) + yy*sind(theta)) + phase)))*2-1)+meanIntensity;
else %'sine'
    data = amplitude*sin(2*pi*(frequency*(xx*cosd(theta) + yy*sind(theta)) + phase))+meanIntensity;
end

%Apply color
color = repmat(reshape(color, [1 1 3]), flip(siz));
data = repmat(data, [1 1 3]).*color;

    
end %makeDisplayData