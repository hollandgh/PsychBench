%Giles Holland 2022-24


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
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;


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

if ~(isOneNum(flickerFrequency) && flickerFrequency >= 0)
    error('Property .flickerFrequency must be a number >= 0.')
end
if ~isOneNum(temporalFrequency)
    error('Property .temporalFrequency must be a number.')
end
if ~(flickerFrequency == 0 || temporalFrequency == 0)
    error('Only one of properties .flickerFrequency and .temporalFrequency can be set.')
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


this.amplitude = amplitude;
this.maxAmplitude = maxAmplitude;
this.maxContrast = maxContrast;