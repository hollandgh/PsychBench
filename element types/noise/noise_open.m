%Giles Holland 2022, 23


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.size = element_deg2px(this.size);
this.maxFrequency = element_deg2px(this.maxFrequency, -1);
%---


siz = this.size;
maxFrequency = this.maxFrequency;
meanIntensity = this.meanIntensity;
sigma = this.sigma;
numLevels = this.numLevels;
color = this.color;
temporalFrequency = this.temporalFrequency;
repeatInterval = this.repeatInterval;
seed = this.seed;
addDisplay = this.addDisplay;
windowSize = devices.screen.windowSize;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---    
if ~(isOneNum(siz) && siz == inf) && numel(siz) == 1
    %Square
    siz = repmat(siz, 1, 2);
end
if ~(isRowNum(siz) && (numel(siz) == 2 && all(siz > 0 & siz < inf) || numel(siz) == 1 && siz == inf))
    error('Property .size must be a number or 1x2 vector of numbers > 0, or the number inf.')
end
this.size = siz;

if ~(isOneNum(maxFrequency) && maxFrequency > 0)
    error('Property .maxFrequency must be a number > 0.')
end
if ~isOneNum(meanIntensity)
    error('Property .meanIntensity must be a number > 0.')
end

if ~(isOneNum(sigma) && sigma >= 0)
    error('Property .sigma must be a number >= 0.')
end
if addDisplay && sigma == inf
    error('If property .addDisplay = true, .sigma must be <= inf.')
end

if ~(isOneNum(numLevels) && isIntegerVal(numLevels) && numLevels > 0)
    error('Property .numLevels must be an integer > 0.')
end

if ~isRgb1(color)
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
end

if ~(isOneNum(temporalFrequency) && temporalFrequency >= 0)
    error('Property .temporalFrequency must be a number >= 0.')
end
if ~(isOneNum(repeatInterval) && repeatInterval > 0)
    error('Property .repeatInterval must be a number > 0.')
end

%Value for seed checked at use in openAtTrial
if ~isempty(seed) && ~(temporalFrequency == 0 || repeatInterval < inf)
    error('If property .seed is set, .temporalFrequency must = 0 or .repeatInterval must be < inf.')
end
%---


if numel(siz) == 1 && siz == inf
    %Size = whole window
    siz = windowSize;
end
%Texture pixel (1/2 spatial cycle) size in screen pixels
pixelSize = 1/maxFrequency/2;
textureSize = round(siz/pixelSize);
textureDims = flip(textureSize);

%Temporal frequency limited by experiment frame rate
temporalFrequency = min(temporalFrequency, experiment.frameRate);


this.size = siz;
this.temporalFrequency = temporalFrequency;
this.textureDims = textureDims;

%Initialize some record properties for first iteration of runFrame
this.t_next = [];