%Giles Holland 2023, 24


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
%---


siz = this.size;
numChecks = this.numChecks;
orientation = this.orientation;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
color = this.color;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;
temporalFrequencyBalanced = this.temporalFrequencyBalanced;
fps = this.fps;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if numel(siz) == 1
    siz = [siz siz];
end
if ~(isRowNum(siz) && all(siz > 0))
    error('Property .size must be a number or 1x2 vector of numbers > 0.')
end
this.size = siz;

if numel(numChecks) == 1
    numChecks = [numChecks numChecks];
end
%>= 2 cause checkerboard always centered at boundary between checks
if ~(isRowNum(numChecks) && all(numChecks >= 2))
    error('Property .numChecks must be a number or 1x2 vector of numbers >= 2.')
end
this.numChecks = numChecks;

if ~isOneNum(orientation)
    error('Property .orientation must be a number.')
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
if ~(isRowNum(temporalFrequency) && numel(temporalFrequency) == 2)
    error('Property .temporalFrequency must be a 1x2 vector.')
end
if ~any(temporalFrequency == 0)
    error('Only one number in property .temporalFrequency can be set not = 0.')
end
if ~(isRowNum(temporalFrequencyBalanced) && numel(temporalFrequencyBalanced) == 2)
    error('Property .temporalFrequencyBalanced must be a 1x2 vector.')
end
if ~any(temporalFrequencyBalanced == 0)
    error('Only one number in property .temporalFrequencyBalanced can be set not = 0.')
end
if ~(numel(find([flickerFrequency > 0 any(temporalFrequency ~= 0) any(temporalFrequencyBalanced ~= 0)])) <= 1)
    error('Only one of properties .flickerFrequency, .temporalFrequency, .temporalFrequencyBalanced can be set.')
end
if ~(isOneNum(fps) && fps > 0)
    error('Property .fps must be a number > 0.')
end
%---


if any(temporalFrequencyBalanced ~= 0)
    %Number of images to make for phase drift balanced display
    tf = temporalFrequencyBalanced ~= 0;
    numImages = ceil(fps/abs(temporalFrequencyBalanced(tf)));
else
    numImages = [];
end


%User sets amplitude OR contrast (amplitude/mean)
if ~isempty(contrast)
    %Calculate amplitude from contrast cause used below
    amplitude = contrast*meanIntensity;
end

%Calculate maximum amplitude, contrast before intensity would clip at 0 or 1, for experiment results output
maxAmplitude = min(1-meanIntensity, meanIntensity-0);
maxContrast = maxAmplitude/meanIntensity;


this.numImages = numImages;
this.amplitude = amplitude;
this.maxAmplitude = maxAmplitude;
this.maxContrast = maxContrast;