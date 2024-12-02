shape = this.shape;
siz = this.size;
frequency = this.frequency;
orientation = this.orientation;
phase = this.phase;
meanIntensity = this.meanIntensity;
amplitude = this.amplitude;
color = this.color;
flickerFrequency = this.flickerFrequency;
temporalFrequency = this.temporalFrequency;


%Make display data.
%Maybe slow, so encapsulate in a function and do shared so only computes once 
%for all objects of this type with the same function input values.
%---
[data, frequency, rect_display, siz] = element_doShared(@makeDisplayData, shape, siz, frequency, orientation, phase, meanIntensity, amplitude, color, flickerFrequency, temporalFrequency);
%---


%Convert image data to textures
for i = 1:numel(data)
    nn_gratingTextures(i) = element_openTexture([], [], data{i}); %#ok<*SAGROW>
end
if temporalFrequency ~= 0
    %Open texture to build total display on each frame.
    %Sized to display size.
    n_texture = element_openTexture(siz);
else
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
this.n_texture = n_texture;


%end script




function [data, frequency, rect_display, displaySize] = makeDisplayData(shape, siz, frequency, theta, phase, meanIntensity, amplitude, color, flickerFrequency, temporalFrequency) %local function


%Need to be careful with below to avoid being off by 1 px, especialling with phase drift...

if strcmpi(shape, 'rectangle')
    %Round frequency to nearest integer 1/2 period (px) to ensure equal bar sizes when quantized into pixels, assuming orthogonal to pixels at least.
    %Then also correct display area to preserve number of cycles in it.
    siz_periods = siz/(1/frequency);
    period = 2*round(1/frequency/2);
    frequency = 1/period;
    siz = siz_periods*period;
else
    period = 1/frequency;
end

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
if strcmpi(shape, 'rectangle')
    data{1} = ceil(sin(2*pi*(frequency*(xx*cosd(theta) + yy*sind(theta)) + phase))/2)*2-1;
else %'sine'
    data{1} = sin(2*pi*(frequency*(xx*cosd(theta) + yy*sind(theta)) + phase));
end
if flickerFrequency > 0
    %Make two opposite gratings that will alternate for flicker
    data{2} = -data{1};
end
    color = repmat(reshape(color, [1 1 3]), size(xx));
for i = 1:numel(data)
    %Apply amplitude, offset, Clip to 0/1, Apply color
    data{i} = data{i}*amplitude + meanIntensity;    
    data{i} = min(max(data{i}, 0), 1);
    data{i} = repmat(data{i}, [1 1 3]).*color; %#ok<*AGROW>
end

    
end %makeDisplayData