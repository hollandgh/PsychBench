siz = this.size;
frequency = this.frequency;
orientation = this.orientation;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
sigma = this.sigma;
color = this.color;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[gratingData, frequency, envelopeData, rect_display, siz] = element_doShared(@makeDisplayData, siz, frequency, orientation, phase, meanIntensity, amplitude, sigma, color, flickerFrequency, temporalFrequency);
%---


%Convert image data to textures
for i = 1:numel(gratingData)
    nn_gratingTextures(i) = element_openTexture([], [], gratingData{i}); %#ok<*SAGROW>
end
if temporalFrequency ~= 0
    n_envelopeTexture = element_openTexture([], [], envelopeData);
    
    %Open texture to build total display on each frame.
    %Sized to display size.
    n_texture = element_openTexture(siz);
else
    n_envelopeTexture = [];
    n_texture = [];
end

if flickerFrequency == 0 && temporalFrequency == 0
    %Static display with image ready here so can predraw to minimize latency at first draw during frames
    this = element_predraw(this, nn_gratingTextures(1));
end


this.size = siz;
this.frequency = frequency;
this.rect_display = rect_display;
this.nn_gratingTextures = nn_gratingTextures;
this.n_envelopeTexture = n_envelopeTexture;
this.n_texture = n_texture;


%end script




function [gratingData, frequency, envelopeData, rect_display, displaySize] = makeDisplayData(siz, frequency, theta, phase, meanIntensity, amplitude, sigma, color, flickerFrequency, temporalFrequency) %local function


%Need to be careful with below to avoid being off by 1 px, especialling with phase drift...

%Round frequency to nearest integer period (px) to ensure equal cycle sizes across display pixels.
%Basically nearest frequency that can be accurately resolved at this resolution.
%Otherwise can get visible artifacts, especially with phase drift.
%Then also correct display area to preserve number of cycles in it.
numCycles = siz/(1/frequency);
period = round(1/frequency);
frequency = 1/period;
siz = numCycles*period;

if temporalFrequency ~= 0
    %Pad with spatial period on each side so when occluded to display area later, appears to drift smoothly.
    %Equal on each edge so phase at center unchanged.
    padding = period;
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

        %Grating snapped to +/-1
        gratings{1} = sin(2*pi*(frequency*(xx*cosd(theta) + yy*sind(theta)) + phase));
if flickerFrequency > 0
        %Make two opposite gratings that will alternate for flicker
        gratings{2} = -gratings{1};
end

    color = repmat(reshape(color, [1 1 3]), size(xx));

    %Gaussian envelope 0-1
    a = cosd(theta)^2/(2*sigma(1)^2) + sind(theta)^2/(2*sigma(2)^2);
    b = sind(2*theta)/(4*sigma(1)^2) - sind(2*theta)/(4*sigma(2)^2);
    c = sind(theta)^2/(2*sigma(1)^2) + cosd(theta)^2/(2*sigma(2)^2);
    envelope = exp(-(a*xx.^2 + 2*b*xx.*yy + c*yy.^2));
    
if temporalFrequency ~= 0
    for i = 1:numel(gratings)
        %Apply amplitude, offset, Clip to 0/1, Apply color
        gratings{i} = gratings{i}*amplitude + meanIntensity;
        gratings{i} = min(max(gratings{i}, 0), 1);
        gratingData{i} = repmat(gratings{i}, [1 1 3]).*color; %#ok<*AGROW>
    end
    
    %Envelope to layer on separately.
    %Like mask: Transparent in middle to show grating, fades into grating back color at edges.
    envelopeData = meanIntensity;
    envelopeData = min(max(envelopeData, 0), 1);
    envelopeData = envelopeData*color;
    envelopeData(:,:,4) = 1-envelope;
else
    for i = 1:numel(gratings)
        %Apply amplitude, offset, Clip to 0/1, Apply color.
        %Build in envelope since won't need to layer it separately if no phase drift.
        gratings{i} = gratings{i}*amplitude.*envelope + meanIntensity;
        gratings{i} = min(max(gratings{i}, 0), 1);
        gratingData{i} = repmat(gratings{i}, [1 1 3]).*color; %#ok<*AGROW>
    end
    
    envelopeData = [];
end

    
end %makeDisplayData