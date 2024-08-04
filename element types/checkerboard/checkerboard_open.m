%Giles Holland 2023


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
%---


siz = this.size;
numChecks = this.numChecks;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
color = this.color;
flickerFrequency = this.flickerFrequency;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(siz) == 1
    siz = [siz siz];
end
if ~(isRowNum(siz) && all(siz > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0.')
end

if numel(numChecks) == 1
    numChecks = [numChecks numChecks];
end
if ~(isRowNum(numChecks) && all(numChecks > 0))
    error('Property .numChecks must be a number or 1x2 vector of numbers > 0.')
end

if ~(isOneNum(phase) && any(phase == [0 1]))
    error('Property .phase must be 0 or 1.')
end
if ~(isOneNum(meanIntensity) && meanIntensity >= 0 && meanIntensity <= 1)
    error('Property .meanIntensity must be a number between 0-1.')
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

if ~(isOneNum(flickerFrequency) && flickerFrequency >= 0)
    error('Property .flickerFrequency must be a number >= 0.')
end
%---


%User sets amplitude OR contrast (amplitude/mean)
if ~isempty(contrast)
    %Calculate amplitude from contrast cause used below
    amplitude = contrast*meanIntensity;
end

%Calculate maximum amplitude, contrast before intensity would clip at 0 or 1, for experiment results output
maxAmplitude = min(1-meanIntensity, meanIntensity-0);
maxContrast = maxAmplitude/meanIntensity;
    if amplitude > maxAmplitude
        error('Intensity is clipped at 0 or 1. See record properties .maxAmplitude, .maxContrast for maximum amplitude/contrast at set mean intensity.')
    end


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
data = element_doShared(@makeDisplayData, siz, numChecks, phase, meanIntensity, amplitude, color, flickerFrequency);
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




function data = makeDisplayData(siz, numChecks, phase, meanIntensity, amplitude, color, flickerFrequency) %local function


%Round dims to nearest odd integers, then center area on a coordinate grid of size = dims with one 0 pixel at center, dims = 2*radius+1.
siz = round(siz);
siz = siz-1+mod(siz, 2);
radius = (siz-1)/2;
[xx, yy] = meshgrid(-radius(1):radius(1), -radius(2):radius(2));

%Spatial frequency(s)
frequency = numChecks/2./siz;

%0/1 = dark/light in immediate quadrant 1
phase = (phase+1)/2;

%Grating snapped to 0/1
    gratings{1} = ceil(sin(2*pi*(frequency(1)*xx + phase)).*sin(2*pi*(frequency(2)*yy))/2)*2-1;
if flickerFrequency > 0
    %Make two opposite gratings for flicker
    gratings{2} = -gratings{1};
end

    color = repmat(reshape(color, [1 1 3]), flip(siz));
    data = cell(size(gratings));
for i = 1:numel(gratings)
    gratings{i} = gratings{i}*amplitude + meanIntensity;
    
    %Apply color
    data{i} = repmat(gratings{i}, [1 1 3]).*color; %#ok<*AGROW>
end

    
end %makeDisplayData