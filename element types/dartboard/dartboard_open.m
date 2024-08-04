%Giles Holland 2023


%PREPROCESS INPUT PROPERTIES FOR DISTANCE UNITS, STRING DATA TYPE
%---
%Convert deg and other distance units to px on screen
this.diameter = element_deg2px(this.diameter);
this.centerDiameter = element_deg2px(this.centerDiameter);
%---


diameter = this.diameter;
centerDiameter = this.centerDiameter;
numAngularChecks = this.numAngularChecks;
numRadialChecks = this.numRadialChecks;
radialScale = this.radialScale;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
color = this.color;
flickerFrequency = this.flickerFrequency;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(diameter) && diameter > 0)
    error('Property .diameter must be a number > 0.')
end
if ~(isOneNum(centerDiameter) && centerDiameter >= 0)
    error('Property .centerDiameter must be a number >= 0.')
end
if ~(isOneNum(numAngularChecks) && isIntegerVal(numAngularChecks) && numAngularChecks > 0)
    error('Property .numAngularChecks must be an integer > 0.')
end
if ~(isOneNum(numRadialChecks) && numRadialChecks > 0)
    error('Property .numRadialChecks must be a number > 0.')
end

radialScale = row(radialScale);
if ~(isa(radialScale, 'numeric') && all(radialScale > 0) && numel(radialScale) == numRadialChecks || isempty(radialScale))
    error('Property .radialScale must be a vector with numbers > 0 and size = .numRadialChecks, or [].')
end
this.radialScale = radialScale;

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


if ~isempty(radialScale)
    %Normalize radial scale factors -> mean = 1
    radialScale = radialScale/mean(radialScale);
end


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
data = element_doShared(@makeDisplayData, diameter, centerDiameter, numRadialChecks, numAngularChecks, radialScale, phase, meanIntensity, amplitude, color, flickerFrequency);
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




function data = makeDisplayData(diameter, centerDiameter, numRadialChecks, numAngularChecks, radialScale, phase, meanIntensity, amplitude, color, flickerFrequency) %local function


%Don't use square() to generate a square wave cause requires Signal Processing Toolbox


%Calculate radial check sizes (px) from set diameter and number of radial checks
    radius = diameter/2;
    centerRadius = centerDiameter/2;
if isempty(radialScale)
    %Uniform radial grating
    radialCheckSizes = (radius-centerRadius)/numRadialChecks*ones(1, numRadialChecks);
else
    %Radial grating scaled to factors
    radialCheckSizes = (radius-centerRadius)/numRadialChecks*radialScale;
end

%Calculate actual diameter (px) to fit number of radial checks.
%Diameter = odd integer with one 0 pixel at center, diameter = 2*radius+1.
%Integers cause used as inputs to meshgrid(), ones(), repmat() below.
centerRadius = round(centerRadius);
radius = round(centerRadius+sum(radialCheckSizes));
diameter = 2*radius+1;

%Generate coordinate space (px), radii (px), polar angles (-pi ... pi rad).
%Wrap to 0 ... 2*pi cause will also need to wrap other arbitrary angles below.
[xx, yy] = meshgrid(-radius:radius, -radius:radius);
rr = (xx.^2 + yy.^2).^(1/2);
hh = atan2(yy, xx);
hh = mod(hh, 2*pi);
    

%Radial grating snapped to +/-1.
%0/1 = dark/light in immediate quadrant 1.
    radialGrating = ones(diameter, diameter);
    g = -(phase*2-1);
    r2 = centerRadius;
for s = radialCheckSizes
    r1 = r2;
    r2 = r1+s;
    g = -g;
    radialGrating(rr > r1 & rr <= r2) = g;
end
    radialGrating(rr > r2) = g;

if numAngularChecks == 1
    %Avoid 0 deg -> -1 line for concentric rings
    angularGrating = ones(diameter, diameter);
else
    %Angular grating snapped to +/-1.
    %ceil -1: = 0 deg -> -1, > 0 deg -> +1.
    angularGrating = ceil(sin(hh*numAngularChecks/2)/2)*2-1;
end

    %Full grating snapped to +/-1
    gratings{1} = radialGrating.*angularGrating;
if flickerFrequency > 0
    %Make two opposite gratings for flicker
    gratings{2} = -gratings{1};
end

    %Transparent in center and outside disc
    alpha = ones(diameter, diameter);
    alpha(rr <= centerRadius | rr > radius) = 0;
    color = repmat(reshape(color, [1 1 3]), [diameter diameter 1]);
    data = cell(size(gratings));
for i = 1:numel(gratings)
    %Grating snapped to +/-amplitude, mean at meanIntensity
    gratings{i} = gratings{i}*amplitude + meanIntensity; %#ok<*AGROW>

    %Apply color, alpha
    data{i} = repmat(gratings{i}, [1 1 3]).*color;
    data{i}(:,:,4) = alpha;
end

    %nx1 cell array of full checker discs, n = 1 for no flicker / 2 for flicker
    data = transpose(data);

    
end %makeDisplayData