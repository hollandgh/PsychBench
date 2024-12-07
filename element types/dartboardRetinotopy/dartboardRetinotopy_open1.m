%Giles Holland 2022-24


        %(Handle deprecated)
        %---
        if isfield(this, 'wedgeVelocity')
            if ~isempty(this.wedgeVelocity)
                if isfield(this, 'apertureStepSize') && ~isempty(this.apertureStepSize)
                    apertureStepSize = this.apertureStepSize;
                else
                    apertureStepSize = 1;
                end
                this.showWedges = true;
                this.apertureStep = sign(this.wedgeVelocity)*apertureStepSize;
                this.apertureInterval = apertureStepSize/abs(this.wedgeVelocity);
            %else default values in showWedges, apertureStep, apertureInterval
            end
        end
        if isfield(this, 'ringVelocity')
            if ~isempty(this.ringVelocity)
                if isfield(this, 'apertureStepSize') && ~isempty(this.apertureStepSize)
                    apertureStepSize = this.apertureStepSize;
                else
                    apertureStepSize = 1;
                end
                this.showRings = true;
                this.apertureStep = sign(this.ringVelocity)*apertureStepSize;
                this.apertureInterval = apertureStepSize/abs(this.ringVelocity);
            %else default values in showWedges, apertureStep, apertureInterval
            end
        end
        %---


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
angularTemporalFrequency = this.angularTemporalFrequency;
radialTemporalFrequency = this.radialTemporalFrequency;
angularTemporalFrequencyBalanced = this.angularTemporalFrequencyBalanced;
radialTemporalFrequencyBalanced = this.radialTemporalFrequencyBalanced;
fps = this.fps;
showWedges = this.showWedges;
showRings = this.showRings;
apertureSize = this.apertureSize;
apertureStep = this.apertureStep;
apertureInterval = this.apertureInterval;
aperturePhase = this.aperturePhase;
maxNumLoops = this.maxNumLoops;


%BASIC ERROR CHECK/FORMAT INPUT PROPERTIES
%---
if ~(isOneNum(diameter) && diameter > 0)
    error('Property .diameter must be a number > 0.')
end
if ~(isOneNum(centerDiameter) && centerDiameter >= 0)
    error('Property .centerDiameter must be a number >= 0.')
end
if ~(isOneNum(numAngularChecks) && numAngularChecks > 0)
    error('Property .numAngularChecks must be a number > 0.')
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
if ~isOneNum(angularTemporalFrequency)
    error('Property .angularTemporalFrequency must be a number.')
end
if ~isOneNum(radialTemporalFrequency)
    error('Property .radialTemporalFrequency must be a number.')
end
if ~isOneNum(angularTemporalFrequencyBalanced)
    error('Property .angularTemporalFrequencyBalanced must be a number.')
end
if ~isOneNum(radialTemporalFrequencyBalanced)
    error('Property .radialTemporalFrequencyBalanced must be a number.')
end
if ~(numel(find([flickerFrequency > 0 angularTemporalFrequency ~= 0 radialTemporalFrequency ~= 0 angularTemporalFrequencyBalanced ~= 0 radialTemporalFrequencyBalanced ~= 0])) <= 1)
    error('Only one of properties .flickerFrequency, .angularTemporalFrequency, .radialTemporalFrequency, .angularTemporalFrequencyBalanced, .radialTemporalFrequencyBalanced can be set.')
end
if ~(isOneNum(fps) && fps > 0)
    error('Property .fps must be a number > 0.')
end

if ~is01(showWedges)
    error('Property .showWedges must be true/false.')
end
if ~is01(showRings)
    error('Property .showRings must be true/false.')
end
if ~(~showWedges || ~showRings)
    error('Only one of properties .showWedges and .showRings can = true.')
end
if      showWedges
    if ~(isOneNum(apertureSize) && apertureSize > 0 && apertureSize < numAngularChecks)
        error('If property .showWedges is set, .apertureSize must be a number > 0 and < .numAngularChecks.')
    end    
    if ~isOneNum(apertureStep)
        error('Property .apertureStep must be a number.')
    end
    if ~(isOneNum(apertureInterval) && apertureInterval > 0)
        error('Property .apertureInterval must be a number > 0.')
    end
    if ~isOneNum(aperturePhase)
        error('Property .aperturePhase must be a number.')
    end
    if ~(isOneNum(maxNumLoops) && maxNumLoops > 0)
        error('Property .maxNumLoops must be a number > 0.')
    end
    
elseif  showRings
    if ~(isOneNum(apertureSize) && apertureSize > 0 && apertureSize < numRadialChecks)
        error('If property .showRings is set, .apertureSize must be a number > 0 and < .numRadialChecks.')
    end    
    if ~isOneNum(apertureStep)
        error('Property .apertureStep must be a number.')
    end
    if ~(isOneNum(apertureInterval) && apertureInterval > 0)
        error('Property .apertureInterval must be a number > 0.')
    end
    if ~(isOneNum(maxNumLoops) && maxNumLoops > 0)
        error('Property .maxNumLoops must be a number > 0.')
    end
    
end
%---


if ~isempty(radialScale)
    %Normalize radial scale factors -> mean = 1
    radialScale = radialScale/mean(radialScale);
end


if      radialTemporalFrequency ~= 0
    %Number of images to make for radial phase drift display
    numImages = ceil(fps/abs(radialTemporalFrequency));
elseif  angularTemporalFrequencyBalanced ~= 0
    %Number of images to make for angular phase drift balanced display
    numImages = ceil(fps/abs(angularTemporalFrequencyBalanced));
elseif  radialTemporalFrequencyBalanced ~= 0
    %Number of images to make for radial phase drift balanced display
    numImages = ceil(fps/abs(radialTemporalFrequencyBalanced));
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
    
    
this.radialScale = radialScale;
this.numImages = numImages;
this.amplitude = amplitude;
this.maxAmplitude = maxAmplitude;
this.maxContrast = maxContrast;