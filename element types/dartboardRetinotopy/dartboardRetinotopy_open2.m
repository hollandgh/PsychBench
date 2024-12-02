diameter = this.diameter;
centerDiameter = this.centerDiameter;
numAngularChecks = this.numAngularChecks;
numRadialChecks = this.numRadialChecks;
radialScale = this.radialScale;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
color = this.color;
flickerFrequency = this.flickerFrequency;
radialTemporalFrequency = this.radialTemporalFrequency;
angularTemporalFrequencyBalanced = this.angularTemporalFrequencyBalanced;
radialTemporalFrequencyBalanced = this.radialTemporalFrequencyBalanced;
showWedges = this.showWedges;
showRings = this.showRings;
apertureSize = this.apertureSize;
apertureStep = this.apertureStep;
aperturePhase = this.aperturePhase;
numImages = this.numImages;
backColor = this.backColor;


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[dartboardData, apertureData, diameter] = element_doShared(@makeDisplayData, diameter, centerDiameter, numAngularChecks, numRadialChecks, radialScale, phase, meanIntensity, amplitude, color, flickerFrequency, radialTemporalFrequency, angularTemporalFrequencyBalanced, radialTemporalFrequencyBalanced, numImages, showWedges, showRings, apertureSize, apertureStep, aperturePhase, backColor);
%---


%Convert image data to textures
    nn_dartboardTextures = zeros(size(dartboardData));
for i = 1:numel(dartboardData)
    nn_dartboardTextures(i) = element_openTexture([], [], dartboardData{i}); %#ok<*SAGROW>
end
    nn_apertureTextures = zeros(size(apertureData));
for i = 1:numel(apertureData)
    nn_apertureTextures(i) = element_openTexture([], [], apertureData{i}); %#ok<*SAGROW>
end
%Open texture to build total display on each frame
    siz = [diameter diameter];
    n_texture = element_openTexture(siz);


this.diameter = diameter;
this.nn_dartboardTextures = nn_dartboardTextures;
this.nn_apertureTextures = nn_apertureTextures;
this.n_texture = n_texture;


%end script




function [dartboardData, apertureData, diameter] = makeDisplayData(diameter, centerDiameter, numAngularChecks, numRadialChecks, radialScale, phase, meanIntensity, amplitude, color, flickerFrequency, radialTemporalFrequency, angularTemporalFrequencyBalanced, radialTemporalFrequencyBalanced, numImages, showWedges, showRings, apertureSize, apertureStep, aperturePhase, backColor) %local function


%Need to be careful with below to avoid being off by 1 px, especialling with phase drift...

    angularCheckSize = 2*pi/numAngularChecks;

%Calculate radial check sizes (px) from set diameter and number of radial checks
    radius = diameter/2;
    centerRadius = centerDiameter/2;
if isempty(radialScale)
    %Uniform radial grating
    
    %Round radial frequency to nearest integer 1/2 period (px) to ensure equal check widths/heights where orthogonal to pixels.
    %Then also correct display area to preserve number of cycles in it.
    radialCheckSize = round((radius-centerRadius)/numRadialChecks);
    radius = centerRadius+numRadialChecks*radialCheckSize;
    
    radialCheckSizes = repmat(radialCheckSize, 1, ceil(numRadialChecks));
else
    %Radial grating scaled to factors
    radialCheckSizes = (radius-centerRadius)/numRadialChecks*radialScale;
end

%Get coordinate grid xx, yy (px), radii (px), polar angles (-pi ... pi rad).
%Center coordinate grid about 0 for perfect symmetry about center and perfect rotation about center for angular phase drift.
%Avoid 0 cause of its asymmetry for snapped sin/cos: has to either fall on +/-1 side.
%ceil makes sure always big enough to contain curve--will use alpha on actual drawn dartboard anyway.
%Max 0.5 px too big at each edge.
r = ceil(radius)-0.5;
[xx, yy] = meshgrid(-r:r, -r:r);
rr = (xx.^2 + yy.^2).^(1/2);
hh = atan2(yy, xx);
%Wrap to 0 ... 2*pi cause will also need to wrap other arbitrary angles below
hh = mod(hh, 2*pi);
diameter = size(xx, 1);


        %Object background color in center and outside dartboard
        tff_dartboard = rr > centerRadius & rr <= radius;
        tff_dartboard = tff_dartboard(:);
        background = ones(numel(find(~tff_dartboard)), 1)*backColor(1:3);
        
if      radialTemporalFrequency ~= 0
    %---
    %Radial phase drift.
    %Cannot be done by rotation or translation at draw to experiment window so need to make an image movie...
    
    %Angular grating snapped to +/-1
        angularGrating = ceil(sin(hh*numAngularChecks/2)/2)*2-1;
        angularGrating = reshape(angularGrating, [], 1);
        
    %Radial gratings snapped to +/-1, 0 in center and outside dartboard.
    %-> phase drifts.
    %Overall phase 0/1 = dark/light in immediate quadrant 1.
    %Do manually with for loop so works with non-equal radial check sizes.
        ss = [0 radialCheckSizes 0 0];
    for i = 1:numImages
        drift = (numImages-i+1)/numImages*2;
        drift = [min(drift, 1) max(drift-1, 0)];
        
            radialGrating = zeros(size(xx));
            r1 = centerRadius;
            p1 = centerRadius;
            g = -(phase*2-1);
        
        for i_s = 2:numel(ss)
            g = -g;
            radialGrating(rr > p1) = g;
            r1 = r1+ss(i_s);
            p1 = r1-drift(1)*ss(i_s)-drift(2)*ss(i_s-1);
        end
            radialGrating(rr > radius) = 0;
            
        radialGratings(:,:,i) = radialGrating;
    end
    if radialTemporalFrequency < 0
        radialGratings(:,:,2:end) = flip(radialGratings(:,:,2:end), 3);
    end
        radialGratings = reshape(radialGratings, [], numImages);
    
        dartboardData = cell(1, numImages);
    for i = 1:numImages
        %Dartboard snapped to +/-1
        dartboard = radialGratings(:,i).*angularGrating;
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboard = dartboard*amplitude + meanIntensity; %#ok<*AGROW>
        dartboard = min(max(dartboard, 0), 1);
        dartboardData{i}( tff_dartboard,1:3) = dartboard(tff_dartboard)*color;
        dartboardData{i}(~tff_dartboard,1:3) = background;
        dartboardData{i} = reshape(dartboardData{i}, [size(xx) 3]);
    end
    %---
        
elseif  angularTemporalFrequencyBalanced ~= 0
    %---
    %Angular phase drift balanced.
    %Make two angular gratings that will draw interleaved and oppositely phase shifted.
    %Could be done by drawing to experiment window interleaved and rotated but that can cause alpha blending artifacts at interleave edges, so make single images instead...
    
    %Angular gratings snapped to +/-1.
    %-> phase drifts.
        angularGratings = zeros([size(xx) numImages]);
    for i = 1:numImages
        angularGratings(:,:,i) = ceil(sin(hh*numAngularChecks/2 - sign(angularTemporalFrequencyBalanced)*(i-1)/numImages*2*pi)/2)*2-1;
    end
        angularGratings = reshape(angularGratings, [], numImages);
            
    %Radial grating snapped to +/-1, 0 in center and outside dartboard.
    %Overall phase 0/1 = dark/light in immediate quadrant 1.
    %Do manually with for loop so works with non-equal radial check sizes.
        radialGrating = zeros(size(xx));
        r1 = centerRadius;
        g = -(phase*2-1);
    for s = radialCheckSizes
        g = -g;
        radialGrating(rr > r1) = g;
        r1 = r1+s;
    end
        radialGrating(rr > r1) = 0;
        radialGrating = reshape(radialGrating, [], 1);
        tff_rings = radialGrating == 1;

        dartboardData = cell(1, numImages);
    for i = 1:numImages
        dartboard = zeros(numel(xx), 1);
        dartboard( tff_rings) = -angularGratings( tff_rings,i);
        %Start at opposite phase -> -/+grating
        %Opposite phase drift -> numImages+1-n
        dartboard(~tff_rings) = +angularGratings(~tff_rings,numImages+1-i);
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboard = dartboard*amplitude + meanIntensity; %#ok<*AGROW>
        dartboard = min(max(dartboard, 0), 1);
        dartboardData{i}( tff_dartboard,1:3) = dartboard(tff_dartboard)*color;
        dartboardData{i}(~tff_dartboard,1:3) = background;
        dartboardData{i} = reshape(dartboardData{i}, [size(xx) 3]);
    end
    %---
        
elseif  radialTemporalFrequencyBalanced ~= 0
    %---
    %Radial phase drift balanced.
    %Make two radial gratings that will draw interleaved and oppositely phase shifted.
    %Cannot be done by rotation or translation at draw to experiment window so need to make an image movie...
    
    %Angular grating snapped to +/-1
        angularGrating = ceil(sin(hh*numAngularChecks/2)/2)*2-1;
        angularGrating = reshape(angularGrating, [], 1);
        tff_wedges = angularGrating == 1;
            
    %Radial gratings snapped to +/-1, 0 in center and outside dartboard.
    %-> phase drifts.
    %Overall phase 0/1 = dark/light in immediate quadrant 1.
    %Do manually with for loop so works with non-equal radial check sizes.
        radialGratings = zeros([size(xx) numImages]);
        ss = [0 radialCheckSizes 0 0];
    for i = 1:numImages
        drift = (numImages-i+1)/numImages*2;
        drift = [min(drift, 1) max(drift-1, 0)];
        
            radialGrating = zeros(size(xx));
            r1 = centerRadius;
            p1 = centerRadius;
            g = -(phase*2-1);
        
        for i_s = 2:numel(ss)
            g = -g;
            radialGrating(rr > p1) = g;
            r1 = r1+ss(i_s);
            p1 = r1-drift(1)*ss(i_s)-drift(2)*ss(i_s-1);
        end
            radialGrating(rr > radius) = 0;
            
        radialGratings(:,:,i) = radialGrating;
    end
    if radialTemporalFrequencyBalanced < 0
        radialGratings(:,:,2:end) = flip(radialGratings(:,:,2:end), 3);
    end
        radialGratings = reshape(radialGratings, [], numImages);

        dartboardData = cell(1, numImages);
    for i = 1:numImages
        dartboard = zeros(numel(xx), 1);
        dartboard( tff_wedges) = -radialGratings( tff_wedges,i);
        %Start at opposite phase -> -/+grating
        %Opposite phase drift -> numImages+1-n
        dartboard(~tff_wedges) = +radialGratings(~tff_wedges,numImages+1-i);
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboard = dartboard*amplitude + meanIntensity; %#ok<*AGROW>
        dartboard = min(max(dartboard, 0), 1);
        dartboardData{i}( tff_dartboard,1:3) = dartboard(tff_dartboard)*color;
        dartboardData{i}(~tff_dartboard,1:3) = background;
        dartboardData{i} = reshape(dartboardData{i}, [size(xx) 3]);
    end
    %---

else
    %---
    %Static, Flicker, Angular phase drift
    
        %Angular grating snapped to +/-1
        angularGrating = ceil(sin(hh*numAngularChecks/2)/2)*2-1;
        angularGrating = reshape(angularGrating, [], 1);

    %Radial grating snapped to +/-1, 0 in center and outside dartboard.
    %Phase 0/1 = dark/light in immediate quadrant 1.
    %Do manually with for loop so works with non-equal radial check sizes.
        radialGrating = zeros(size(xx));
        r1 = centerRadius;
        g = -(phase*2-1);
    for s = radialCheckSizes
        g = -g;
        radialGrating(rr > r1) = g;
        r1 = r1+s;
    end
        radialGrating(rr > r1) = 0;
        radialGrating = reshape(radialGrating, [], 1);

        %Dartboard snapped to +/-1
        dartboards{1} = radialGrating.*angularGrating;
    if flickerFrequency > 0
        %Make two opposite dartboards that will alternate for flicker
        dartboards{2} = -dartboards{1};
    end
    for i = 1:numel(dartboards)
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboards{i} = dartboards{i}*amplitude + meanIntensity; %#ok<*AGROW>
        dartboards{i} = min(max(dartboards{i}, 0), 1);
        dartboardData{i}( tff_dartboard,1:3) = dartboards{i}(tff_dartboard)*color;
        dartboardData{i}(~tff_dartboard,1:3) = background;
        dartboardData{i} = reshape(dartboardData{i}, [size(xx) 3]);
    end
    %---
    
end
        

if      showWedges
    %---
    %Wedges
    
    %Number of wedges.
    %First one has leading edge 1 aperture size past 0 (or phase).
    %Last one has leading edge < 1 aperture STEP size past first one's leading edge.
    %Allows smooth coverage of whole dartboard, e.g. if apertureSize = 2, apertureStep = 1.
    if apertureStep == 0
        numApertures = 1;
    else
        numApertures = ceil(numAngularChecks/abs(apertureStep));
    end
    
    %Wedge size, step, phase -> rad
    apertureSize = apertureSize*angularCheckSize;
    apertureStep = apertureStep*angularCheckSize;
    aperturePhase = aperturePhase*angularCheckSize;    

    %Wedge apertures.
    %1xm cell array, m = number of wedges.
    %Object background color (left at default opaque), then punch transparent within aperture.
        apertureData = cell(1, numApertures);
        [apertureData{:}] = deal(repmat(reshape(backColor, [1 1 4]), [size(xx) 1]));
        %Start at first wedge in front of aperture phase angle
    if apertureStep >= 0
        h1 = mod(aperturePhase, 2*pi)-apertureStep;
        h2 = mod(aperturePhase+apertureSize, 2*pi)-apertureStep;
    else
        h1 = mod(aperturePhase-apertureSize, 2*pi)-apertureStep;
        h2 = mod(aperturePhase, 2*pi)-apertureStep;
    end
    alpha = ones(size(xx));
    for i = 1:numApertures
        h1 = mod(h1+apertureStep, 2*pi);
        h2 = mod(h2+apertureStep, 2*pi);

            aa = alpha;
            %Can't decrease by 1 px on each side cause would lose perfect straight line of 0 deg
        if h2 > h1
            aa(hh > h1 & hh <= h2) = 0;
        else
            aa(hh > h1 | hh <= h2) = 0;
        end
        apertureData{i}(:,:,4) = aa;
    end
    %---

elseif  showRings
    %---
    %Rings
    
    %Number of rings.
    %Same as for wedges except don't show a partial ring or ring split between center/radius at wrap.
    %Can still do apertureStep < apertureSize, just won't include the partial one at the end.
    if apertureStep == 0
        numApertures = 1;
    else
        numApertures = 1+floor((numRadialChecks-apertureSize)/abs(apertureStep));
    end
    
    %Aperture phase not used for rings cause not symmetrical
        
    %Ring apertures.
    %1xm cell array, m = number of rings.
    %Object background color (left at default opaque), then punch transparent within aperture.
        apertureData = cell(1, numApertures);
        [apertureData{:}] = deal(repmat(reshape(backColor, [1 1 4]), [size(xx) 1]));
    if apertureStep >= 0
        %Start at inner ring with inner edge at r = 0
        n1 = 1-apertureStep;
        n2 = apertureSize-apertureStep;
    else
        %Start at outer ring with outer edge at r = radius
        n1 = numRadialChecks-apertureSize+1-apertureStep;
        n2 = numRadialChecks-apertureStep;
    end
    alpha = ones(size(xx));
    for i = 1:numApertures
        n1 = n1+apertureStep;
        n2 = n2+apertureStep;
        n1f = floor(n1);
        n2c = ceil(n2);
        r1 = centerRadius+sum(radialCheckSizes(1:n1f-1))+(n1-n1f)*radialCheckSizes(n1f);
        r2 = radius-sum(radialCheckSizes(n2c+1:end))-(n2c-n2)*radialCheckSizes(n2c);

        aa = alpha;
        %Decrease by 1 px on each side to avoid blending artifacts leaking next radial check in for apertures aligned with radial checks
        aa(rr > r1+1 & rr <= r2-1) = 0;
        apertureData{i}(:,:,4) = aa;
    end
    %---

else
    %No apertures, just full dartboard
        apertureData = [];
end

    
end %makeDisplayData