colors = this.color;
borderWidths = this.borderWidth;
borderColors = this.borderColor;
numCircles = this.numCircles;
rects_texture = this.rects_texture;
textureSize = this.textureSize;
centerOffset = this.centerOffset;


%Make object display on a texture

%Request object background color = transparent.
%Transparent version of shape color prevents artifacts if adjacent pixels are blended, e.g. if rotation.
if numCircles == 1
    if borderWidths > 0 && borderColors(4) > 0
        c = [borderColors(1:3) 0];
    else
        c = [colors(1:3) 0];
    end
else
        %Maybe multiple colors--just use mean color 0.5
        c = [0.5 0.5 0.5 0];
end
this = element_setBackColor(this, c);

%Open texture for drawing, sized to fit display, background = object background color
n_texture = element_openTexture(textureSize);

%Draw display centered on texture using PTB FillOval, FrameOval.
%For multiple shapes maybe overlapping draw with first above last to match convention for property .depth (+ = behind).
%Keep each fill + border together, draw border above fill.
colors = transpose(colors);
borderColors = transpose(borderColors);
rects_texture = transpose(rects_texture);
for n = numCircles:-1:1
    if colors(4,n) > 0
        Screen('FillOval', n_texture, colors(:,n), rects_texture(:,n))    
    end
    if borderWidths(n) > 0 && borderColors(4,n) > 0
        Screen('FrameOval', n_texture, borderColors(:,n), rects_texture(:,n), borderWidths(:,n))
    end
end

%Static display with image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], [], centerOffset);


this.n_texture = n_texture;