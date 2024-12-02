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
angularTemporalFrequency = this.angularTemporalFrequency;
radialTemporalFrequency = this.radialTemporalFrequency;
angularTemporalFrequencyBalanced = this.angularTemporalFrequencyBalanced;
radialTemporalFrequencyBalanced = this.radialTemporalFrequencyBalanced;
numImages = this.numImages;
backColor = this.backColor;


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[data, diameter] = element_doShared(@makeDisplayData, diameter, centerDiameter, numAngularChecks, numRadialChecks, radialScale, phase, meanIntensity, amplitude, color, flickerFrequency, radialTemporalFrequency, angularTemporalFrequencyBalanced, radialTemporalFrequencyBalanced, numImages, backColor);
%---


%Convert image data to textures
    nn_dartboardTextures = zeros(size(data));
for i = 1:numel(data)
    nn_dartboardTextures(i) = element_openTexture([], [], data{i}); %#ok<*SAGROW>
end
if angularTemporalFrequency ~= 0
    %Open texture to build total display on each frame
    siz = [diameter diameter];
    n_texture = element_openTexture(siz);
else
    n_texture = [];
end

if flickerFrequency == 0 && angularTemporalFrequency == 0 && radialTemporalFrequency == 0 && angularTemporalFrequencyBalanced == 0 && radialTemporalFrequencyBalanced == 0
    %Static display with image ready here so can predraw to minimize latency at first draw during frames
    this = element_predraw(this, nn_dartboardTextures(1));
end


this.diameter = diameter;
this.nn_dartboardTextures = nn_dartboardTextures;
this.n_texture = n_texture;


%end script




function [data, diameter] = makeDisplayData(diameter, centerDiameter, numAngularChecks, numRadialChecks, radialScale, phase, meanIntensity, amplitude, color, flickerFrequency, radialTemporalFrequency, angularTemporalFrequencyBalanced, radialTemporalFrequencyBalanced, numImages, backColor) %local function


%Need to be careful with below to avoid being off by 1 px, especialling with phase drift...

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
%ceil makes sure always big enough to contain disc curve--will use alpha on actual drawn dartboard anyway.
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
    
        data = cell(1, numImages);
    for i = 1:numImages
        %Dartboard snapped to +/-1
        dartboard = radialGratings(:,i).*angularGrating;
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboard = dartboard*amplitude + meanIntensity; %#ok<*AGROW>
        dartboard = min(max(dartboard, 0), 1);
        data{i}( tff_dartboard,1:3) = dartboard(tff_dartboard)*color;
        data{i}(~tff_dartboard,1:3) = background;
        data{i} = reshape(data{i}, [size(xx) 3]);
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

        data = cell(1, numImages);
    for i = 1:numImages
        dartboard = zeros(numel(xx), 1);
        dartboard( tff_rings) = -angularGratings( tff_rings,i);
        %Start at opposite phase -> -/+grating
        %Opposite phase drift -> numImages+1-n
        dartboard(~tff_rings) = +angularGratings(~tff_rings,numImages+1-i);
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboard = dartboard*amplitude + meanIntensity; %#ok<*AGROW>
        dartboard = min(max(dartboard, 0), 1);
        data{i}( tff_dartboard,1:3) = dartboard(tff_dartboard)*color;
        data{i}(~tff_dartboard,1:3) = background;
        data{i} = reshape(data{i}, [size(xx) 3]);
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

        data = cell(1, numImages);
    for i = 1:numImages
        dartboard = zeros(numel(xx), 1);
        dartboard( tff_wedges) = -radialGratings( tff_wedges,i);
        %Start at opposite phase -> -/+grating
        %Opposite phase drift -> numImages+1-n
        dartboard(~tff_wedges) = +radialGratings(~tff_wedges,numImages+1-i);
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        dartboard = dartboard*amplitude + meanIntensity; %#ok<*AGROW>
        dartboard = min(max(dartboard, 0), 1);
        data{i}( tff_dartboard,1:3) = dartboard(tff_dartboard)*color;
        data{i}(~tff_dartboard,1:3) = background;
        data{i} = reshape(data{i}, [size(xx) 3]);
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
        data{i}( tff_dartboard,1:3) = dartboards{i}(tff_dartboard)*color;
        data{i}(~tff_dartboard,1:3) = background;
        data{i} = reshape(data{i}, [size(xx) 3]);
    end
    %---
    
end

    
end %makeDisplayData