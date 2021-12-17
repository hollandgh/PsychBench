%PREPROCESS INPUT PROPERTIES FOR DATA TYPE, UNITS
%---
%Convert deg units to px
this.diameter = element_deg2px(this.diameter);
this.radialFrequency = element_deg2px(this.radialFrequency, -1);
%---


diameter = this.diameter;
radialFrequency = this.radialFrequency;
radialPhase = this.radialPhase;
angularFrequency = this.angularFrequency;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
contrast = this.contrast;
color = this.color;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(diameter) && diameter > 0)
    error('Property .diameter must be a number > 0.')
end
if ~(isOneNum(radialFrequency) && radialFrequency >= 0)
    error('Property .radialFrequency must be a number >= 0.')
end
if ~(isOneNum(radialPhase) && any(radialPhase == [0 0.5]))
    error('Property .radialPhase must be 0 or 0.5.')
end
if ~(isOneNum(angularFrequency) && isIntegerVal(angularFrequency) && angularFrequency >= 0)
    error('Property .angularFrequency must be an integer >= 0.')
end
if ~(isOneNum(meanIntensity) && meanIntensity >= 0 && meanIntensity <= 1)
    error('Property .meanIntensity must be a number between 0-1.')
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

if ~(isRowNum(color) && numel(color) == 3 && all(color >= 0 & color <= 1))
    error('Property .color must be a 1x3 vector with numbers between 0-1.')
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
%Maybe slow, so encapsulate in a function and share so only computes once for
%all objects of the class with the same function input values.
%---
data = element_doShared(@makeDisplayData, diameter, radialFrequency, radialPhase, angularFrequency, meanIntensity, amplitude, color);
%---


this.amplitude = amplitude;
this.maxAmplitude = maxAmplitude;
this.maxContrast = maxContrast;
%data is large, so set shared so only holds one value in memory for all objects
%of the class with the same index property values.
%---
this = element_setShared(this, 'data', data, {'diameter' 'radialFrequency' 'radialPhase' 'angularFrequency' 'meanIntensity' 'amplitude' 'color'});
%---


%end script




function data = makeDisplayData(diameter, radialFrequency, radialPhase, angularFrequency, meanIntensity, amplitude, color) %local function


%Round diameter down to nearest odd integer, then center disc on a coordinate grid of size = diameter with one 0 pixel at center, diameter = 2*radius+1.
diameter = floor(diameter);
diameter = diameter-1+mod(diameter, 2);
radius = (diameter-1)/2;
[xx, yy] = meshgrid(-radius:radius, -radius:radius);

%Radial grating clipped to +/-1
radialGrating = floor(0.5*sin(2*pi*radialFrequency*(xx.^2 + yy.^2).^(1/2) + radialPhase*2*pi))*2+1;
%Remove edge effect at r = 0 for radial phase = n*pi
radialGrating(radius+1,radius+1) = radialGrating(radius+1,radius+2);

%Angular grating clipped to +/-1
angularGrating = floor(0.5*sin(atan2(yy, xx)*angularFrequency))*2+1;

%Full grating clipped to +/-1
grating = radialGrating.*angularGrating;
%Grating clipped to +/-amplitude, mean at meanIntensity
grating = grating*amplitude + meanIntensity;

%Apply grating to color
data = repmat(reshape(color, [1 1 3]), [diameter diameter 1]);
data = repmat(grating, [1 1 3]).*data;

%Transparent outside disc
alpha = ones(diameter, diameter);
alpha((xx.^2+yy.^2).^(1/2) > radius) = 0;
data(:,:,4) = alpha;

    
end %makeDisplayData