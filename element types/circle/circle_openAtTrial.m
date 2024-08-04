colors = this.color;
borderWidths = this.borderWidth;
borderColors = this.borderColor;
numCircles = this.numCircles;
rects_texture = this.rects_texture;
textureSize = this.textureSize;
centerOffset = this.centerOffset;


%Make object display on a texture.
%In openAtTrial instead of open cause textures Psychtoolbox holds can use
%significant memory, so only hold for each object during its trial instead of
%for all objects at same time at experiment startup.

%Open texture for drawing, sized to fit display, with object background color (users can set in .backColor, default = transparent)
n_texture = element_openTexture(textureSize);

%Draw display centered on texture using PTB FillOval, FrameOval.
%For multiple shapes maybe overlapping draw with first above last to match convention for property .depth (+ = behind).
%Keep each fill + border together, draw border above fill.
for n = numCircles:-1:1
    if colors(4,n) > 0
        Screen('FillOval', n_texture, colors(:,n), rects_texture(:,n))    
    end
    if borderWidths(n) > 0 && borderColors(4,n) > 0
        Screen('FrameOval', n_texture, borderColors(:,n), rects_texture(:,n), borderWidths(:,n))
    end
end

%We have first image ready here so can predraw to minimize latency at first draw during frames
this = element_predraw(this, n_texture, [], [], centerOffset);


this.n_texture = n_texture;