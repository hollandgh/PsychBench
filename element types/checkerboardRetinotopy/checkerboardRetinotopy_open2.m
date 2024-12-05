siz = this.size;
numChecks = this.numChecks;
orientation = this.orientation;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
color = this.color;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;
temporalFrequencyBalanced = this.temporalFrequencyBalanced;
showBars = this.showBars;
apertureSize = this.apertureSize;
apertureStep = this.apertureStep;
numImages = this.numImages;
backColor = this.backColor;


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[checkerboardData, frequency, apertureData, rect_display, siz] = element_doShared(@makeDisplayData, siz, numChecks, orientation, phase, meanIntensity, amplitude, color, flickerFrequency, temporalFrequency, temporalFrequencyBalanced, showBars, apertureSize, apertureStep, numImages, backColor);
%---


%Convert image data to textures
    nn_checkerboardTextures = zeros(size(checkerboardData));
for i = 1:numel(checkerboardData)
    nn_checkerboardTextures(i) = element_openTexture([], [], checkerboardData{i}); %#ok<*SAGROW>
end
    nn_apertureTextures = zeros(size(apertureData));
for i = 1:numel(apertureData)
    nn_apertureTextures(i) = element_openTexture([], [], apertureData{i}); %#ok<*SAGROW>
end
%Open texture to build total display on each frame.
%Sized to display size.
    n_texture = element_openTexture(siz);


this.size = siz;
this.frequency = frequency;
this.rect_display = rect_display;
this.nn_checkerboardTextures = nn_checkerboardTextures;
this.nn_apertureTextures = nn_apertureTextures;
this.n_texture = n_texture;


%end script




function [checkerboardData, frequency, apertureData, rect_display, displaySize] = makeDisplayData(siz, numChecks, theta, phase, meanIntensity, amplitude, color, flickerFrequency, temporalFrequency, temporalFrequencyBalanced, showBars, apertureSize, apertureStep, numImages, backColor) %local function


%Need to be careful with below to avoid being off by 1 px, especialling with phase shift and apertures...

%Get frequencies (x, y).
%Round frequency to nearest integer 1/2 period (px) to ensure equal check widths/heights when quantized into pixels, assuming orthogonal to pixels at least.
%Then also correct display area to preserve number of cycles in it.
checkSize = round(siz./numChecks);
period = 2*checkSize;
frequency = 1./period;
siz = numChecks/2.*period;

if any(temporalFrequency ~= 0) || any(temporalFrequencyBalanced ~= 0)
    %Pad with spatial period on each side so when occluded to display area later, appears to drift smoothly.
    %Equal on each edge so phase at center unchanged.
    %max to allow for orientation ~= 0.
    padding = max(period);
    siz = siz+2*padding;
else
    padding = 0;
end

%Get coordinate grid xx, yy (px).
%Center coordinate grid about 0 for perfect symmetry about center.
%Avoid 0 cause of its asymmetry for snapped sin/cos: has to either fall on +/-1 side.
%Max 0.5 px off at each edge.
radius = siz/2;
r = round(radius)-0.5;
[xx, yy] = meshgrid(-r(1):r(1), -r(2):r(2));
siz = flip(size(xx));
%Rect of checkerboard on visible display, for use later if phase drift
rect_display = [0 0 siz]-padding;
displaySize = siz-2*padding;


        %0/1 = dark/light in immediate quadrant 1
        phase = (phase+1)/2;

        color = repmat(reshape(color, [1 1 3]), size(xx));
        
if any(temporalFrequencyBalanced ~= 0)
    %---
    %Phase drift balanced.
    %Make two gratings interleaved and oppositely shifted.
    %Could be done by drawing to experiment window interleaved and shifted but that can cause alpha blending artifacts at interleave edges, so make single images instead...
    
    %Horz, Vert gratings snapped to +/-1.
    %-> phase drifts.
    if temporalFrequencyBalanced(1) ~= 0
            gratings{1} = zeros([size(xx) numImages]);
        for i = 1:numImages
            gratings{1}(:,:,i) = ceil(sin(2*pi*(frequency(1)*( xx*cosd(theta) + yy*sind(theta)) + phase - sign(temporalFrequencyBalanced(1))*(i-1)/numImages))/2)*2-1;
        end
        
            gratings{2}        = ceil(sin(2*pi*(frequency(2)*(-xx*sind(theta) + yy*cosd(theta))                                                             ))/2)*2-1;
    else
            gratings{1} = zeros([size(xx) numImages]);
        for i = 1:numImages
            gratings{1}(:,:,i) = ceil(sin(2*pi*(frequency(2)*(-xx*sind(theta) + yy*cosd(theta))         - sign(temporalFrequencyBalanced(2))*(i-1)/numImages))/2)*2-1;
        end
        
            gratings{2}        = ceil(sin(2*pi*(frequency(1)*( xx*cosd(theta) + yy*sind(theta)) + phase                                                     ))/2)*2-1;
    end
            gratings{1} = reshape(gratings{1}, [], numImages);
            gratings{2} = reshape(gratings{2}, [], 1);
    tff = gratings{2} == 1;
        
        checkerboardData = cell(1, numImages);
    for i = 1:numImages
        checkerboard = zeros(numel(xx), 1);
        checkerboard( tff) = -gratings{1}( tff,i);
        %Start at opposite phase -> -/+grating
        %Opposite phase drift -> numImages+1-n
        checkerboard(~tff) = +gratings{1}(~tff,numImages+1-i);
        
        %Apply amplitude, offset, Clip to 0/1, Apply color
        checkerboard = checkerboard*amplitude + meanIntensity; %#ok<*AGROW>
        checkerboard = min(max(checkerboard, 0), 1);
        checkerboard = reshape(checkerboard, size(xx));

        checkerboardData{i} = repmat(checkerboard, [1 1 3]).*color;
    end
    %---

else
    %---
    %Static, Flicker, Phase drift
    
        %Checkerboard snapped to +/-1
        checkerboards{1} = ceil(sin(2*pi*(frequency(1)*(xx*cosd(theta) + yy*sind(theta)) + phase)).*sin(2*pi*(frequency(2)*(-xx*sind(theta) + yy*cosd(theta))))/2)*2-1;
    if flickerFrequency > 0
        %Make two opposite checkerboards that will alternate for flicker
        checkerboards{2} = -checkerboards{1};
    end
    for i = 1:numel(checkerboards)
        %Apply amplitude, offset, Clip to 0/1, Apply color
        checkerboards{i} = checkerboards{i}*amplitude + meanIntensity;
        checkerboards{i} = min(max(checkerboards{i}, 0), 1);
        checkerboardData{i} = repmat(checkerboards{i}, [1 1 3]).*color; %#ok<*AGROW>
    end
    %---

end


if showBars
    %---
    %Bars
    
    %Number of bars.
    %First one has leading edge 1 aperture size in from checkerboard edge.
    %Last one has leading edge < 1 aperture STEP size before first one's leading edge.
    %Don't show a partial bar or bar split between edges at wrap.
    %Can still do apertureStep < apertureSize, just won't include the partial one at the end.
    if apertureStep == 0
        numApertures = 1;
    else
        numApertures = 1+floor((numChecks(1)-apertureSize)/abs(apertureStep));
    end
    
    %Bar size, step, phase -> rad
    apertureSize = apertureSize*checkSize(1);
    apertureStep = apertureStep*checkSize(1);

    %Bar apertures.
    %1xm cell array, m = number of bars.
    %x1 = left border outside, x2 = right border inside.
    %Object background color (left at default opaque), then punch transparent within aperture.
        apertureData = cell(1, numApertures);
        [apertureData{:}] = deal(repmat(reshape(backColor, [1 1 4]), [size(xx) 1]));
    if apertureStep >= 0
        %Start at left edge of checkerboard
        x1 = -radius(1)+padding-apertureStep;
    else
        %Start at right edge of checkerboard
        x1 = radius(1)-padding-apertureSize-apertureStep;
    end
        x2 = x1+apertureSize;
    alpha = ones(size(xx));
    for i = 1:numApertures
        x1 = x1+apertureStep;
        x2 = x2+apertureStep;

        aa = alpha;
        %Decrease by 1 px on each side to avoid blending artifacts leaking next row/column for apertures aligned with rows/columns and e.g. display rotated
        aa(xx > x1+1 & xx <= x2-1) = 0;
        apertureData{i}(:,:,4) = aa;
    end
    %---

else
    %No apertures, just full checkerboard
        apertureData = [];
end

    
end %makeDisplayData